//  JPEngine.m
//  JSPatch
//
//  Created by bang on 15/4/30.
//  Copyright (c) 2015 bang. All rights reserved.
//

#import "VKJPEngine.h"
#import <objc/runtime.h>
#import <objc/message.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIApplication.h>
#endif

@interface VKJPBoxing : NSObject
@property (nonatomic) id obj;
@property (nonatomic) void *pointer;
@property (nonatomic) Class cls;
@property (nonatomic, weak) id weakObj;
@property (nonatomic, assign) id assignObj;
- (id)unbox;
- (void *)unboxPointer;
- (Class)unboxClass;
@end

@implementation VKJPBoxing

#define VKJPBOXING_GEN(_name, _prop, _type) \
+ (instancetype)_name:(_type)obj  \
{   \
    VKJPBoxing *boxing = [[VKJPBoxing alloc] init]; \
    boxing._prop = obj;   \
    return boxing;  \
}

VKJPBOXING_GEN(boxObj, obj, id)
VKJPBOXING_GEN(boxPointer, pointer, void *)
VKJPBOXING_GEN(boxClass, cls, Class)
VKJPBOXING_GEN(boxWeakObj, weakObj, id)
VKJPBOXING_GEN(boxAssignObj, assignObj, id)

- (id)unbox
{
    if (self.obj) return self.obj;
    if (self.weakObj) return self.weakObj;
    if (self.assignObj) return self.assignObj;
    return self;
}
- (void *)unboxPointer
{
    return self.pointer;
}
- (Class)unboxClass
{
    return self.cls;
}
@end

static JSContext *_vkcontext;
static __weak id _vktarget;
static NSString *_vkregexStr = @"(?<!\\\\)\\.\\s*(\\w+)\\s*\\(";
static NSString *_vkreplaceStr = @".__c(\"$1\")(";
static NSRegularExpression* _vkregex;
static NSObject *_vknullObj;
static NSObject *_vknilObj;
static NSMutableDictionary *_vkregisteredStruct;
static NSString *_vkcurrInvokeSuperClsName;
static char *vkkPropAssociatedObjectKey;
static BOOL _vkautoConvert;
static BOOL _vkconvertOCNumberToString;
static NSString *_vkscriptRootDir;
static NSMutableSet *_vkrunnedScript;

static NSMutableDictionary *_vkJSOverideMethods;
static NSMutableDictionary *_vkTMPMemoryPool;
static NSMutableDictionary *_vkpropKeys;
static NSMutableDictionary *_vkJSMethodSignatureCache;
static NSLock              *_vkJSMethodSignatureLock;
static NSRecursiveLock     *_vkJSMethodForwardCallLock;
static NSMutableDictionary *_vkprotocolTypeEncodeDict;
static NSMutableArray      *_vkpointersToRelease;

void (^_vkexceptionBlock)(NSString *log) = ^void(NSString *log) {
    NSCAssert(NO, log);
};

void (^_vkLogBlock)(NSString *log) = ^void(NSString *log) {
//    NSCAssert(NO, log);
};


@implementation VKJPEngine

#pragma mark - APIS

+ (void)startEngine
{
    if (![JSContext class] || _vkcontext) {
        return;
    }
    
    JSContext *context = [[JSContext alloc] init];
    
    context[@"_OC_defineClass"] = ^(NSString *classDeclaration, JSValue *instanceMethods, JSValue *classMethods) {
        return vkdefineClass(classDeclaration, instanceMethods, classMethods);
    };

    context[@"_OC_defineProtocol"] = ^(NSString *protocolDeclaration, JSValue *instProtocol, JSValue *clsProtocol) {
        return vkdefineProtocol(protocolDeclaration, instProtocol,clsProtocol);
    };
    
    context[@"_OC_callI"] = ^id(JSValue *obj, NSString *selectorName, JSValue *arguments, BOOL isSuper) {
        return vkcallSelector(nil, selectorName, arguments, obj, isSuper);
    };
    context[@"_OC_callC"] = ^id(NSString *className, NSString *selectorName, JSValue *arguments) {
        return vkcallSelector(className, selectorName, arguments, nil, NO);
    };
    context[@"_OC_formatJSToOC"] = ^id(JSValue *obj) {
        return vkformatJSToOC(obj);
    };
    
    context[@"_OC_formatOCToJS"] = ^id(JSValue *obj) {
        return vkformatOCToJS([obj toObject]);
    };
    
    context[@"_OC_getCustomProps"] = ^id(JSValue *obj) {
        id realObj = vkformatJSToOC(obj);
        return objc_getAssociatedObject(realObj, vkkPropAssociatedObjectKey);
    };
    
    context[@"_OC_setCustomProps"] = ^(JSValue *obj, JSValue *val) {
        id realObj = vkformatJSToOC(obj);
        objc_setAssociatedObject(realObj, vkkPropAssociatedObjectKey, val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    };
    
    context[@"__weak"] = ^id(JSValue *jsval) {
        id obj = vkformatJSToOC(jsval);
        return [[JSContext currentContext][@"_formatOCToJS"] callWithArguments:@[vkformatOCToJS([VKJPBoxing boxWeakObj:obj])]];
    };

    context[@"__strong"] = ^id(JSValue *jsval) {
        id obj = vkformatJSToOC(jsval);
        return [[JSContext currentContext][@"_formatOCToJS"] callWithArguments:@[vkformatOCToJS(obj)]];
    };
    
    context[@"_OC_superClsName"] = ^(NSString *clsName) {
        Class cls = NSClassFromString(clsName);
        return NSStringFromClass([cls superclass]);
    };
    
    context[@"autoConvertOCType"] = ^(BOOL autoConvert) {
        _vkautoConvert = autoConvert;
    };

    context[@"convertOCNumberToString"] = ^(BOOL convertOCNumberToString) {
        _vkconvertOCNumberToString = convertOCNumberToString;
    };
    
    context[@"include"] = ^(NSString *filePath) {
        NSString *absolutePath = [_vkscriptRootDir stringByAppendingPathComponent:filePath];
        if (!_vkrunnedScript) {
            _vkrunnedScript = [[NSMutableSet alloc] init];
        }
        if (absolutePath && ![_vkrunnedScript containsObject:absolutePath]) {
            [VKJPEngine _evaluateScriptWithPath:absolutePath];
            [_vkrunnedScript addObject:absolutePath];
        }
    };
    
    context[@"resourcePath"] = ^(NSString *filePath) {
        return [_vkscriptRootDir stringByAppendingPathComponent:filePath];
    };

    context[@"dispatch_after"] = ^(double time, JSValue *func) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [func callWithArguments:nil];
        });
    };
    
    context[@"dispatch_async_main"] = ^(JSValue *func) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [func callWithArguments:nil];
        });
    };
    
    context[@"dispatch_sync_main"] = ^(JSValue *func) {
        if ([NSThread currentThread].isMainThread) {
            [func callWithArguments:nil];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [func callWithArguments:nil];
            });
        }
    };
    
    context[@"dispatch_async_global_queue"] = ^(JSValue *func) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [func callWithArguments:nil];
        });
    };
    
    context[@"releaseTmpObj"] = ^void(JSValue *jsVal) {
        if ([[jsVal toObject] isKindOfClass:[NSDictionary class]]) {
            void *pointer =  [(VKJPBoxing *)([jsVal toObject][@"__obj"]) unboxPointer];
            id obj = *((__unsafe_unretained id *)pointer);
            @synchronized(_vkTMPMemoryPool) {
                [_vkTMPMemoryPool removeObjectForKey:[NSNumber numberWithInteger:[(NSObject*)obj hash]]];
            }
        }
    };
    
    context[@"_OC_log"] = ^() {
        NSArray *args = [JSContext currentArguments];
        for (JSValue *jsVal in args) {
            id obj = vkformatJSToOC(jsVal);
            NSLog(@"JSPatch.log: %@", obj == _vknilObj ? nil : (obj == _vknullObj ? [NSNull null]: obj));
            NSString *logmsg = [NSString stringWithFormat:@"Console.log: %@", obj == _vknilObj ? nil : (obj == _vknullObj ? [NSNull null]: obj)];
            _vkLogBlock(logmsg);
        }
    };
    
    context[@"_OC_catch"] = ^(JSValue *msg, JSValue *stack) {
        _vkexceptionBlock([NSString stringWithFormat:@"js exception, \nmsg: %@, \nstack: \n %@", [msg toObject], [stack toObject]]);
    };
    
    context[@"target"] = ^(JSValue *msg, JSValue *stack) {
        return vkformatOCToJS(_vktarget);
    };
    
    context.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        _vkexceptionBlock([NSString stringWithFormat:@"js exception: %@", exception]);
    };
    
    _vknullObj = [[NSObject alloc] init];
    context[@"_OC_null"] = vkformatOCToJS(_vknullObj);
    
    _vkcontext = context;
    
    _vknilObj = [[NSObject alloc] init];
    _vkJSMethodSignatureLock = [[NSLock alloc] init];
    _vkJSMethodForwardCallLock = [[NSRecursiveLock alloc] init];
    _vkregisteredStruct = [[NSMutableDictionary alloc] init];
    
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"VKJSPatch" ofType:@"js"];
    if (!path) _vkexceptionBlock(@"can't find JSPatch.js");
    NSString *jsCore = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    
    if ([_vkcontext respondsToSelector:@selector(evaluateScript:withSourceURL:)]) {
        [_vkcontext evaluateScript:jsCore withSourceURL:[NSURL URLWithString:@"VKJSPatch.js"]];
    } else {
        [_vkcontext evaluateScript:jsCore];
    }
}

+(void)setScriptWeakTarget:(__weak id)target
{
    __weak typeof(target) weaktarget = target;
    _vktarget = weaktarget;
}

+ (JSValue *)evaluateScript:(NSString *)script
{
    return [self _evaluateScript:script withSourceURL:[NSURL URLWithString:@"main.js"]];
}

+ (JSValue *)evaluateScriptWithPath:(NSString *)filePath
{
    _vkscriptRootDir = [filePath stringByDeletingLastPathComponent];
    return [self _evaluateScriptWithPath:filePath];
}

+ (JSValue *)_evaluateScriptWithPath:(NSString *)filePath
{
    NSString *script = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return [self _evaluateScript:script withSourceURL:[NSURL URLWithString:[filePath lastPathComponent]]];
}

+ (JSValue *)_evaluateScript:(NSString *)script withSourceURL:(NSURL *)resourceURL
{
    if (!script || ![JSContext class]) {
        _vkexceptionBlock(@"script is nil");
        return nil;
    }
    [self startEngine];
    
    if (!_vkregex) {
        _vkregex = [NSRegularExpression regularExpressionWithPattern:_vkregexStr options:0 error:nil];
    }
    NSString *formatedScript = [NSString stringWithFormat:@";(function(){try{%@}catch(e){_OC_catch(e.message, e.stack)}})();", [_vkregex stringByReplacingMatchesInString:script options:0 range:NSMakeRange(0, script.length) withTemplate:_vkreplaceStr]];
    @try {
        if ([_vkcontext respondsToSelector:@selector(evaluateScript:withSourceURL:)]) {
            return [_vkcontext evaluateScript:formatedScript withSourceURL:resourceURL];
        } else {
            return [_vkcontext evaluateScript:formatedScript];
        }
    }
    @catch (NSException *exception) {
        _vkexceptionBlock([NSString stringWithFormat:@"%@", exception]);
    }
    return nil;
}

+ (JSContext *)context
{
    return _vkcontext;
}

+ (void)addExtensions:(NSArray *)extensions
{
    if (![JSContext class]) {
        return;
    }
    if (!_vkcontext) _vkexceptionBlock(@"please call [JPEngine startEngine]");
    for (NSString *className in extensions) {
        Class extCls = NSClassFromString(className);
        [extCls main:_vkcontext];
    }
}

+ (void)defineStruct:(NSDictionary *)defineDict
{
    @synchronized (_vkcontext) {
        [_vkregisteredStruct setObject:defineDict forKey:defineDict[@"name"]];
    }
}

+ (void)handleMemoryWarning {
    [_vkJSMethodSignatureLock lock];
    _vkJSMethodSignatureCache = nil;
    [_vkJSMethodSignatureLock unlock];
}

+ (void)handleException:(void (^)(NSString *msg))exceptionBlock
{
    _vkexceptionBlock = [exceptionBlock copy];
}

+ (void)handleLog:(void (^)(NSString *msg))logBlock
{
    _vkLogBlock = [logBlock copy];
}



#pragma mark - Implements

static const void *vkpropKey(NSString *propName) {
    if (!_vkpropKeys) _vkpropKeys = [[NSMutableDictionary alloc] init];
    id key = _vkpropKeys[propName];
    if (!key) {
        key = [propName copy];
        [_vkpropKeys setObject:key forKey:propName];
    }
    return (__bridge const void *)(key);
}
static id vkgetPropIMP(id slf, SEL selector, NSString *propName) {
    return objc_getAssociatedObject(slf, vkpropKey(propName));
}
static void vksetPropIMP(id slf, SEL selector, id val, NSString *propName) {
    objc_setAssociatedObject(slf, vkpropKey(propName), val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char *vkmethodTypesInProtocol(NSString *protocolName, NSString *selectorName, BOOL isInstanceMethod, BOOL isRequired)
{
    Protocol *protocol = objc_getProtocol([vktrim(protocolName) cStringUsingEncoding:NSUTF8StringEncoding]);
    unsigned int selCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, isRequired, isInstanceMethod, &selCount);
    for (int i = 0; i < selCount; i ++) {
        if ([selectorName isEqualToString:NSStringFromSelector(methods[i].name)]) {
            char *types = malloc(strlen(methods[i].types) + 1);
            strcpy(types, methods[i].types);
            free(methods);
            return types;
        }
    }
    free(methods);
    return NULL;
}

static void vkdefineProtocol(NSString *protocolDeclaration, JSValue *instProtocol, JSValue *clsProtocol)
{
    const char *protocolName = [protocolDeclaration UTF8String];
    Protocol* newprotocol = objc_allocateProtocol(protocolName);
    if (newprotocol) {
        vkaddGroupMethodsToProtocol(newprotocol, instProtocol, YES);
        vkaddGroupMethodsToProtocol(newprotocol, clsProtocol, NO);
        objc_registerProtocol(newprotocol);
    }
}

static void vkaddGroupMethodsToProtocol(Protocol* protocol,JSValue *groupMethods,BOOL isInstance)
{
    NSDictionary *groupDic = [groupMethods toDictionary];
    for (NSString *jpSelector in groupDic.allKeys) {
        NSDictionary *methodDict = groupDic[jpSelector];
        NSString *paraString = methodDict[@"paramsType"];
        NSString *returnString = methodDict[@"returnType"] && [methodDict[@"returnType"] length] > 0 ? methodDict[@"returnType"] : @"void";
        NSString *typeEncode = methodDict[@"typeEncode"];
        
        NSArray *argStrArr = [paraString componentsSeparatedByString:@","];
        NSString *selectorName = vkconvertJPSelectorString(jpSelector);
        
        if ([selectorName componentsSeparatedByString:@":"].count - 1 < argStrArr.count) {
            selectorName = [selectorName stringByAppendingString:@":"];
        }

        if (typeEncode) {
            vkaddMethodToProtocol(protocol, selectorName, typeEncode, isInstance);
            
        } else {
            if (!_vkprotocolTypeEncodeDict) {
                _vkprotocolTypeEncodeDict = [[NSMutableDictionary alloc] init];
                #define VKJP_DEFINE_TYPE_ENCODE_CASE(_type) \
                    [_vkprotocolTypeEncodeDict setObject:[NSString stringWithUTF8String:@encode(_type)] forKey:@#_type];\

                VKJP_DEFINE_TYPE_ENCODE_CASE(id);
                VKJP_DEFINE_TYPE_ENCODE_CASE(BOOL);
                VKJP_DEFINE_TYPE_ENCODE_CASE(int);
                VKJP_DEFINE_TYPE_ENCODE_CASE(void);
                VKJP_DEFINE_TYPE_ENCODE_CASE(char);
                VKJP_DEFINE_TYPE_ENCODE_CASE(short);
                VKJP_DEFINE_TYPE_ENCODE_CASE(unsigned short);
                VKJP_DEFINE_TYPE_ENCODE_CASE(unsigned int);
                VKJP_DEFINE_TYPE_ENCODE_CASE(long);
                VKJP_DEFINE_TYPE_ENCODE_CASE(unsigned long);
                VKJP_DEFINE_TYPE_ENCODE_CASE(long long);
                VKJP_DEFINE_TYPE_ENCODE_CASE(float);
                VKJP_DEFINE_TYPE_ENCODE_CASE(double);
                VKJP_DEFINE_TYPE_ENCODE_CASE(CGFloat);
                VKJP_DEFINE_TYPE_ENCODE_CASE(CGSize);
                VKJP_DEFINE_TYPE_ENCODE_CASE(CGRect);
                VKJP_DEFINE_TYPE_ENCODE_CASE(CGPoint);
                VKJP_DEFINE_TYPE_ENCODE_CASE(CGVector);
                VKJP_DEFINE_TYPE_ENCODE_CASE(NSRange);
                VKJP_DEFINE_TYPE_ENCODE_CASE(NSInteger);
                VKJP_DEFINE_TYPE_ENCODE_CASE(Class);
                VKJP_DEFINE_TYPE_ENCODE_CASE(SEL);
                VKJP_DEFINE_TYPE_ENCODE_CASE(void*);
#if TARGET_OS_IPHONE
                VKJP_DEFINE_TYPE_ENCODE_CASE(UIEdgeInsets);
#else
                VKJP_DEFINE_TYPE_ENCODE_CASE(NSEdgeInsets);
#endif

                [_vkprotocolTypeEncodeDict setObject:@"@?" forKey:@"block"];
                [_vkprotocolTypeEncodeDict setObject:@"^@" forKey:@"id*"];
            }
            
            NSString *returnEncode = _vkprotocolTypeEncodeDict[returnString];
            if (returnEncode.length > 0) {
                NSMutableString *encode = [returnEncode mutableCopy];
                [encode appendString:@"@:"];
                for (NSInteger i = 0; i < argStrArr.count; i++) {
                    NSString *argStr = vktrim([argStrArr objectAtIndex:i]);
                    NSString *argEncode = _vkprotocolTypeEncodeDict[argStr];
                    if (!argEncode) {
                        NSString *argClassName = vktrim([argStr stringByReplacingOccurrencesOfString:@"*" withString:@""]);
                        if (NSClassFromString(argClassName) != NULL) {
                            argEncode = @"@";
                        } else {
                            _vkexceptionBlock([NSString stringWithFormat:@"unreconized type %@", argStr]);
                            return;
                        }
                    }
                    [encode appendString:argEncode];
                }
                vkaddMethodToProtocol(protocol, selectorName, encode, isInstance);
            }
        }
    }
}

static void vkaddMethodToProtocol(Protocol* protocol, NSString *selectorName, NSString *typeencoding, BOOL isInstance)
{
    SEL sel = NSSelectorFromString(selectorName);
    const char* type = [typeencoding UTF8String];
    protocol_addMethodDescription(protocol, sel, type, YES, isInstance);
}

static NSDictionary *vkdefineClass(NSString *classDeclaration, JSValue *instanceMethods, JSValue *classMethods)
{
    NSScanner *scanner = [NSScanner scannerWithString:classDeclaration];
    
    NSString *className;
    NSString *superClassName;
    NSString *protocolNames;
    [scanner scanUpToString:@":" intoString:&className];
    if (!scanner.isAtEnd) {
        scanner.scanLocation = scanner.scanLocation + 1;
        [scanner scanUpToString:@"<" intoString:&superClassName];
        if (!scanner.isAtEnd) {
            scanner.scanLocation = scanner.scanLocation + 1;
            [scanner scanUpToString:@">" intoString:&protocolNames];
        }
    }
    
    if (!superClassName) superClassName = @"NSObject";
    className = vktrim(className);
    superClassName = vktrim(superClassName);
    
    NSArray *protocols = [protocolNames length] ? [protocolNames componentsSeparatedByString:@","] : nil;
    
    Class cls = NSClassFromString(className);
    if (!cls) {
        Class superCls = NSClassFromString(superClassName);
        if (!superCls) {
            _vkexceptionBlock([NSString stringWithFormat:@"can't find the super class %@", superClassName]);
            return @{@"cls": className};
        }
        cls = objc_allocateClassPair(superCls, className.UTF8String, 0);
        objc_registerClassPair(cls);
    }
    
    if (protocols.count > 0) {
        for (NSString* protocolName in protocols) {
            Protocol *protocol = objc_getProtocol([vktrim(protocolName) cStringUsingEncoding:NSUTF8StringEncoding]);
            class_addProtocol (cls, protocol);
        }
    }
    
    for (int i = 0; i < 2; i ++) {
        BOOL isInstance = i == 0;
        JSValue *jsMethods = isInstance ? instanceMethods: classMethods;
        
        Class currCls = isInstance ? cls: objc_getMetaClass(className.UTF8String);
        NSDictionary *methodDict = [jsMethods toDictionary];
        for (NSString *jsMethodName in methodDict.allKeys) {
            JSValue *jsMethodArr = [jsMethods valueForProperty:jsMethodName];
            int numberOfArg = [jsMethodArr[0] toInt32];
            NSString *selectorName = vkconvertJPSelectorString(jsMethodName);
            
            if ([selectorName componentsSeparatedByString:@":"].count - 1 < numberOfArg) {
                selectorName = [selectorName stringByAppendingString:@":"];
            }
            
            JSValue *jsMethod = jsMethodArr[1];
            if (class_respondsToSelector(currCls, NSSelectorFromString(selectorName))) {
                vkoverrideMethod(currCls, selectorName, jsMethod, !isInstance, NULL);
            } else {
                BOOL overrided = NO;
                for (NSString *protocolName in protocols) {
                    char *types = vkmethodTypesInProtocol(protocolName, selectorName, isInstance, YES);
                    if (!types) types = vkmethodTypesInProtocol(protocolName, selectorName, isInstance, NO);
                    if (types) {
                        vkoverrideMethod(currCls, selectorName, jsMethod, !isInstance, types);
                        free(types);
                        overrided = YES;
                        break;
                    }
                }
                if (!overrided) {
                    if (![[jsMethodName substringToIndex:1] isEqualToString:@"_"]) {
                        NSMutableString *typeDescStr = [@"@@:" mutableCopy];
                        for (int i = 0; i < numberOfArg; i ++) {
                            [typeDescStr appendString:@"@"];
                        }
                        vkoverrideMethod(currCls, selectorName, jsMethod, !isInstance, [typeDescStr cStringUsingEncoding:NSUTF8StringEncoding]);
                    }
                }
            }
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    class_addMethod(cls, @selector(getProp:), (IMP)vkgetPropIMP, "@@:@");
    class_addMethod(cls, @selector(setProp:forKey:), (IMP)vksetPropIMP, "v@:@@");
#pragma clang diagnostic pop

    return @{@"cls": className, @"superCls": superClassName};
}

static JSValue* vkgetJSFunctionInObjectHierachy(id slf, NSString *selectorName)
{
    Class cls = object_getClass(slf);
    if (_vkcurrInvokeSuperClsName) {
        cls = NSClassFromString(_vkcurrInvokeSuperClsName);
        selectorName = [selectorName stringByReplacingOccurrencesOfString:@"_JPSUPER_" withString:@"_JP"];
    }
    JSValue *func = _vkJSOverideMethods[cls][selectorName];
    while (!func) {
        cls = class_getSuperclass(cls);
        if (!cls) {
            _vkexceptionBlock([NSString stringWithFormat:@"warning can not find selector %@", selectorName]);
            return nil;
        }
        func = _vkJSOverideMethods[cls][selectorName];
    }
    return func;
}

#pragma clang diagnostic pop

static void vkJPForwardInvocation(__unsafe_unretained id assignSlf, SEL selector, NSInvocation *invocation)
{
    BOOL deallocFlag = NO;
    id slf = assignSlf;
    NSMethodSignature *methodSignature = [invocation methodSignature];
    NSInteger numberOfArguments = [methodSignature numberOfArguments];
    
    NSString *selectorName = NSStringFromSelector(invocation.selector);
    NSString *JPSelectorName = [NSString stringWithFormat:@"_JP%@", selectorName];
    SEL JPSelector = NSSelectorFromString(JPSelectorName);
    
    if (!class_respondsToSelector(object_getClass(slf), JPSelector)) {
        vkJPExcuteORIGForwardInvocation(slf, selector, invocation);
        return;
    }
    
    NSMutableArray *argList = [[NSMutableArray alloc] init];
    if ([slf class] == slf) {
        [argList addObject:[JSValue valueWithObject:@{@"__clsName": NSStringFromClass([slf class])} inContext:_vkcontext]];
    } else if ([selectorName isEqualToString:@"dealloc"]) {
        [argList addObject:[VKJPBoxing boxAssignObj:slf]];
        deallocFlag = YES;
    } else {
        [argList addObject:[VKJPBoxing boxWeakObj:slf]];
    }
    
    for (NSUInteger i = 2; i < numberOfArguments; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        switch(argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
        
            #define VKJP_FWD_ARG_CASE(_typeChar, _type) \
            case _typeChar: {   \
                _type arg;  \
                [invocation getArgument:&arg atIndex:i];    \
                [argList addObject:@(arg)]; \
                break;  \
            }
            VKJP_FWD_ARG_CASE('c', char)
            VKJP_FWD_ARG_CASE('C', unsigned char)
            VKJP_FWD_ARG_CASE('s', short)
            VKJP_FWD_ARG_CASE('S', unsigned short)
            VKJP_FWD_ARG_CASE('i', int)
            VKJP_FWD_ARG_CASE('I', unsigned int)
            VKJP_FWD_ARG_CASE('l', long)
            VKJP_FWD_ARG_CASE('L', unsigned long)
            VKJP_FWD_ARG_CASE('q', long long)
            VKJP_FWD_ARG_CASE('Q', unsigned long long)
            VKJP_FWD_ARG_CASE('f', float)
            VKJP_FWD_ARG_CASE('d', double)
            VKJP_FWD_ARG_CASE('B', BOOL)
            case '@': {
                __unsafe_unretained id arg;
                [invocation getArgument:&arg atIndex:i];
                if ([arg isKindOfClass:NSClassFromString(@"NSBlock")]) {
                    [argList addObject:(arg ? [arg copy]: _vknilObj)];
                } else {
                    [argList addObject:(arg ? arg: _vknilObj)];
                }
                break;
            }
            case '{': {
                NSString *typeString = vkextractStructName([NSString stringWithUTF8String:argumentType]);
                #define VKJP_FWD_ARG_STRUCT(_type, _transFunc) \
                if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                    _type arg; \
                    [invocation getArgument:&arg atIndex:i];    \
                    [argList addObject:[JSValue _transFunc:arg inContext:_vkcontext]];  \
                    break; \
                }
                VKJP_FWD_ARG_STRUCT(CGRect, valueWithRect)
                VKJP_FWD_ARG_STRUCT(CGPoint, valueWithPoint)
                VKJP_FWD_ARG_STRUCT(CGSize, valueWithSize)
                VKJP_FWD_ARG_STRUCT(NSRange, valueWithRange)
                
                @synchronized (_vkcontext) {
                    NSDictionary *structDefine = _vkregisteredStruct[typeString];
                    if (structDefine) {
                        size_t size = vksizeOfStructTypes(structDefine[@"types"]);
                        if (size) {
                            void *ret = malloc(size);
                            [invocation getArgument:ret atIndex:i];
                            NSDictionary *dict = vkgetDictOfStruct(ret, structDefine);
                            [argList addObject:[JSValue valueWithObject:dict inContext:_vkcontext]];
                            free(ret);
                            break;
                        }
                    }
                }
                
                break;
            }
            case ':': {
                SEL selector;
                [invocation getArgument:&selector atIndex:i];
                NSString *selectorName = NSStringFromSelector(selector);
                [argList addObject:(selectorName ? selectorName: _vknilObj)];
                break;
            }
            case '^':
            case '*': {
                void *arg;
                [invocation getArgument:&arg atIndex:i];
                [argList addObject:[VKJPBoxing boxPointer:arg]];
                break;
            }
            case '#': {
                Class arg;
                [invocation getArgument:&arg atIndex:i];
                [argList addObject:[VKJPBoxing boxClass:arg]];
                break;
            }
            default: {
                NSLog(@"error type %s", argumentType);
                break;
            }
        }
    }
    
    if (_vkcurrInvokeSuperClsName) {
        Class cls = NSClassFromString(_vkcurrInvokeSuperClsName);
        NSString *tmpSelectorName = [[selectorName stringByReplacingOccurrencesOfString:@"_JPSUPER_" withString:@"_JP"] stringByReplacingOccurrencesOfString:@"SUPER_" withString:@"_JP"];
        if (!_vkJSOverideMethods[cls][tmpSelectorName]) {
            NSString *ORIGSelectorName = [selectorName stringByReplacingOccurrencesOfString:@"SUPER_" withString:@"ORIG"];
            [argList removeObjectAtIndex:0];
            id retObj = vkcallSelector(_vkcurrInvokeSuperClsName, ORIGSelectorName, [JSValue valueWithObject:argList inContext:_vkcontext], [JSValue valueWithObject:@{@"__obj": slf, @"__realClsName": @""} inContext:_vkcontext], NO);
            id __autoreleasing ret = vkformatJSToOC([JSValue valueWithObject:retObj inContext:_vkcontext]);
            [invocation setReturnValue:&ret];
            return;
        }
    }
    
    NSArray *params = _vkformatOCToJSList(argList);
    const char *returnType = [methodSignature methodReturnType];

    switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {
        #define VKJP_FWD_RET_CALL_JS \
            JSValue *fun = vkgetJSFunctionInObjectHierachy(slf, JPSelectorName); \
            JSValue *jsval; \
            [_vkJSMethodForwardCallLock lock];   \
            jsval = [fun callWithArguments:params]; \
            [_vkJSMethodForwardCallLock unlock]; \
            while (![jsval isNull] && ![jsval isUndefined] && [jsval hasProperty:@"__isPerformInOC"]) { \
                NSArray *args = nil;  \
                JSValue *cb = jsval[@"cb"]; \
                if ([jsval hasProperty:@"sel"]) {   \
                    id callRet = vkcallSelector(![jsval[@"clsName"] isUndefined] ? [jsval[@"clsName"] toString] : nil, [jsval[@"sel"] toString], jsval[@"args"], ![jsval[@"obj"] isUndefined] ? jsval[@"obj"] : nil, NO);  \
                    args = @[[_vkcontext[@"_formatOCToJS"] callWithArguments:callRet ? @[callRet] : _vkformatOCToJSList(@[_vknilObj])]];  \
                }   \
                [_vkJSMethodForwardCallLock lock];    \
                jsval = [cb callWithArguments:args];  \
                [_vkJSMethodForwardCallLock unlock];  \
            }

        #define VKJP_FWD_RET_CASE_RET(_typeChar, _type, _retCode)   \
            case _typeChar : { \
                VKJP_FWD_RET_CALL_JS \
                _retCode \
                [invocation setReturnValue:&ret];\
                break;  \
            }

        #define VKJP_FWD_RET_CASE(_typeChar, _type, _typeSelector)   \
            VKJP_FWD_RET_CASE_RET(_typeChar, _type, _type ret = [[jsval toObject] _typeSelector];)   \

        #define VKJP_FWD_RET_CODE_ID \
            id __autoreleasing ret = vkformatJSToOC(jsval); \
            if (ret == _vknilObj ||   \
                ([ret isKindOfClass:[NSNumber class]] && strcmp([ret objCType], "c") == 0 && ![ret boolValue])) ret = nil;  \

        #define VKJP_FWD_RET_CODE_POINTER    \
            void *ret; \
            id obj = vkformatJSToOC(jsval); \
            if ([obj isKindOfClass:[VKJPBoxing class]]) { \
                ret = [((VKJPBoxing *)obj) unboxPointer]; \
            }

        #define VKJP_FWD_RET_CODE_CLASS    \
            Class ret;   \
            id obj = vkformatJSToOC(jsval); \
            if ([obj isKindOfClass:[VKJPBoxing class]]) { \
                ret = [((VKJPBoxing *)obj) unboxClass]; \
            }

        #define VKJP_FWD_RET_CODE_SEL    \
            SEL ret;   \
            id obj = vkformatJSToOC(jsval); \
            if ([obj isKindOfClass:[NSString class]]) { \
                ret = NSSelectorFromString(obj); \
            }

        VKJP_FWD_RET_CASE_RET('@', id, VKJP_FWD_RET_CODE_ID)
        VKJP_FWD_RET_CASE_RET('^', void*, VKJP_FWD_RET_CODE_POINTER)
        VKJP_FWD_RET_CASE_RET('*', void*, VKJP_FWD_RET_CODE_POINTER)
        VKJP_FWD_RET_CASE_RET('#', Class, VKJP_FWD_RET_CODE_CLASS)
        VKJP_FWD_RET_CASE_RET(':', SEL, VKJP_FWD_RET_CODE_SEL)

        VKJP_FWD_RET_CASE('c', char, charValue)
        VKJP_FWD_RET_CASE('C', unsigned char, unsignedCharValue)
        VKJP_FWD_RET_CASE('s', short, shortValue)
        VKJP_FWD_RET_CASE('S', unsigned short, unsignedShortValue)
        VKJP_FWD_RET_CASE('i', int, intValue)
        VKJP_FWD_RET_CASE('I', unsigned int, unsignedIntValue)
        VKJP_FWD_RET_CASE('l', long, longValue)
        VKJP_FWD_RET_CASE('L', unsigned long, unsignedLongValue)
        VKJP_FWD_RET_CASE('q', long long, longLongValue)
        VKJP_FWD_RET_CASE('Q', unsigned long long, unsignedLongLongValue)
        VKJP_FWD_RET_CASE('f', float, floatValue)
        VKJP_FWD_RET_CASE('d', double, doubleValue)
        VKJP_FWD_RET_CASE('B', BOOL, boolValue)

        case 'v': {
            VKJP_FWD_RET_CALL_JS
            break;
        }
        
        case '{': {
            NSString *typeString = vkextractStructName([NSString stringWithUTF8String:returnType]);
            #define VKJP_FWD_RET_STRUCT(_type, _funcSuffix) \
            if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                VKJP_FWD_RET_CALL_JS \
                _type ret = [jsval _funcSuffix]; \
                [invocation setReturnValue:&ret];\
                break;  \
            }
            VKJP_FWD_RET_STRUCT(CGRect, toRect)
            VKJP_FWD_RET_STRUCT(CGPoint, toPoint)
            VKJP_FWD_RET_STRUCT(CGSize, toSize)
            VKJP_FWD_RET_STRUCT(NSRange, toRange)
            
            @synchronized (_vkcontext) {
                NSDictionary *structDefine = _vkregisteredStruct[typeString];
                if (structDefine) {
                    size_t size = vksizeOfStructTypes(structDefine[@"types"]);
                    VKJP_FWD_RET_CALL_JS
                    void *ret = malloc(size);
                    NSDictionary *dict = vkformatJSToOC(jsval);
                    vkgetStructDataWithDict(ret, dict, structDefine);
                    [invocation setReturnValue:ret];
                    free(ret);
                }
            }
            break;
        }
        default: {
            break;
        }
    }
    
    if (_vkpointersToRelease) {
        for (NSValue *val in _vkpointersToRelease) {
            void *pointer = NULL;
            [val getValue:&pointer];
            CFRelease(pointer);
        }
        _vkpointersToRelease = nil;
    }
    
    if (deallocFlag) {
        slf = nil;
        Class instClass = object_getClass(assignSlf);
        Method deallocMethod = class_getInstanceMethod(instClass, NSSelectorFromString(@"ORIGdealloc"));
        void (*originalDealloc)(__unsafe_unretained id, SEL) = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
        originalDealloc(assignSlf, NSSelectorFromString(@"dealloc"));
    }
}

static void vkJPExcuteORIGForwardInvocation(id slf, SEL selector, NSInvocation *invocation)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL origForwardSelector = @selector(ORIGforwardInvocation:);
#pragma clang diagnostic pop
    
    if ([slf respondsToSelector:origForwardSelector]) {
        
        NSMethodSignature *methodSignature = [slf methodSignatureForSelector:origForwardSelector];
        if (!methodSignature) {
            _vkexceptionBlock([NSString stringWithFormat:@"unrecognized selector -ORIGforwardInvocation: for instance %@", slf]);
            return;
        }
        NSInvocation *forwardInv= [NSInvocation invocationWithMethodSignature:methodSignature];
        [forwardInv setTarget:slf];
        [forwardInv setSelector:origForwardSelector];
        [forwardInv setArgument:&invocation atIndex:2];
        [forwardInv invoke];
        
    } else {
        NSString *superForwardName = @"JPSUPER_ForwardInvocation";
        SEL superForwardSelector = NSSelectorFromString(superForwardName);
        
        if (![slf respondsToSelector:superForwardSelector]) {
            Class superCls = [[slf class] superclass];
            Method superForwardMethod = class_getInstanceMethod(superCls, @selector(forwardInvocation:));
            IMP superForwardIMP = method_getImplementation(superForwardMethod);
            class_addMethod([slf class], superForwardSelector, superForwardIMP, method_getTypeEncoding(superForwardMethod));
        }
        
        NSMethodSignature *methodSignature = [slf methodSignatureForSelector:@selector(forwardInvocation:)];
        NSInvocation *forwardInv= [NSInvocation invocationWithMethodSignature:methodSignature];
        [forwardInv setTarget:slf];
        [forwardInv setSelector:superForwardSelector];
        [forwardInv setArgument:&invocation atIndex:2];
        [forwardInv invoke];
    }
}

static void _vkinitJPOverideMethods(Class cls) {
    if (!_vkJSOverideMethods) {
        _vkJSOverideMethods = [[NSMutableDictionary alloc] init];
    }
    if (!_vkJSOverideMethods[cls]) {
        _vkJSOverideMethods[(id<NSCopying>)cls] = [[NSMutableDictionary alloc] init];
    }
}

static void vkoverrideMethod(Class cls, NSString *selectorName, JSValue *function, BOOL isClassMethod, const char *typeDescription)
{
    SEL selector = NSSelectorFromString(selectorName);
    
    if (!typeDescription) {
        Method method = class_getInstanceMethod(cls, selector);
        typeDescription = (char *)method_getTypeEncoding(method);
    }
    
    IMP originalImp = class_respondsToSelector(cls, selector) ? class_getMethodImplementation(cls, selector) : NULL;
    
    IMP msgForwardIMP = _objc_msgForward;
    #if !defined(__arm64__)
        if (typeDescription[0] == '{') {
            //In some cases that returns struct, we should use the '_stret' API:
            //http://sealiesoftware.com/blog/archive/2008/10/30/objc_explain_objc_msgSend_stret.html
            //NSMethodSignature knows the detail but has no API to return, we can only get the info from debugDescription.
            NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:typeDescription];
            if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
                msgForwardIMP = (IMP)_objc_msgForward_stret;
            }
        }
    #endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if (class_getMethodImplementation(cls, @selector(forwardInvocation:)) != (IMP)vkJPForwardInvocation) {
        IMP originalForwardImp = class_replaceMethod(cls, @selector(forwardInvocation:), (IMP)vkJPForwardInvocation, "v@:@");
        class_addMethod(cls, @selector(ORIGforwardInvocation:), originalForwardImp, "v@:@");
    }
#pragma clang diagnostic pop

    if (class_respondsToSelector(cls, selector)) {
        NSString *originalSelectorName = [NSString stringWithFormat:@"ORIG%@", selectorName];
        SEL originalSelector = NSSelectorFromString(originalSelectorName);
        if(!class_respondsToSelector(cls, originalSelector)) {
            class_addMethod(cls, originalSelector, originalImp, typeDescription);
        }
    }
    
    NSString *JPSelectorName = [NSString stringWithFormat:@"_JP%@", selectorName];
    SEL JPSelector = NSSelectorFromString(JPSelectorName);

    _vkinitJPOverideMethods(cls);
    _vkJSOverideMethods[cls][JPSelectorName] = function;
    
    class_addMethod(cls, JPSelector, msgForwardIMP, typeDescription);

    // Replace the original secltor at last, preventing threading issus when
    // the selector get called during the execution of `vkoverrideMethod`
    class_replaceMethod(cls, selector, msgForwardIMP, typeDescription);
}

#pragma mark -

static id vkcallSelector(NSString *className, NSString *selectorName, JSValue *arguments, JSValue *instance, BOOL isSuper)
{
    NSString *realClsName = [[instance valueForProperty:@"__realClsName"] toString];
   
    if (instance) {
        instance = vkformatJSToOC(instance);
        if (!instance || instance == _vknilObj || [instance isKindOfClass:[VKJPBoxing class]]) return @{@"__isNil": @(YES)};
    }
    id argumentsObj = vkformatJSToOC(arguments);
    
    if (instance && [selectorName isEqualToString:@"toJS"]) {
        if ([instance isKindOfClass:[NSString class]] || [instance isKindOfClass:[NSDictionary class]] || [instance isKindOfClass:[NSArray class]] || [instance isKindOfClass:[NSDate class]]) {
            return _vkunboxOCObjectToJS(instance);
        }
    }

    Class cls = instance ? [instance class] : NSClassFromString(className);
    SEL selector = NSSelectorFromString(selectorName);
    
    NSString *superClassName = nil;
    if (isSuper) {
        NSString *superSelectorName = [NSString stringWithFormat:@"SUPER_%@", selectorName];
        SEL superSelector = NSSelectorFromString(superSelectorName);
        
        Class superCls;
        if (realClsName.length) {
            Class defineClass = NSClassFromString(realClsName);
            superCls = defineClass ? [defineClass superclass] : [cls superclass];
        } else {
            superCls = [cls superclass];
        }
        
        Method superMethod = class_getInstanceMethod(superCls, selector);
        IMP superIMP = method_getImplementation(superMethod);
        
        class_addMethod(cls, superSelector, superIMP, method_getTypeEncoding(superMethod));
        
        NSString *JPSelectorName = [NSString stringWithFormat:@"_JP%@", selectorName];
        JSValue *overideFunction = _vkJSOverideMethods[superCls][JPSelectorName];
        if (overideFunction) {
            vkoverrideMethod(cls, superSelectorName, overideFunction, NO, NULL);
        }
        
        selector = superSelector;
        superClassName = NSStringFromClass(superCls);
    }
    
    
    NSMutableArray *_markArray;
    
    NSInvocation *invocation;
    NSMethodSignature *methodSignature;
    if (!_vkJSMethodSignatureCache) {
        _vkJSMethodSignatureCache = [[NSMutableDictionary alloc]init];
    }
    if (instance) {
        [_vkJSMethodSignatureLock lock];
        if (!_vkJSMethodSignatureCache[cls]) {
            _vkJSMethodSignatureCache[(id<NSCopying>)cls] = [[NSMutableDictionary alloc]init];
        }
        methodSignature = _vkJSMethodSignatureCache[cls][selectorName];
        if (!methodSignature) {
            methodSignature = [cls instanceMethodSignatureForSelector:selector];
            _vkJSMethodSignatureCache[cls][selectorName] = methodSignature;
        }
        [_vkJSMethodSignatureLock unlock];
        if (!methodSignature) {
            _vkexceptionBlock([NSString stringWithFormat:@"unrecognized selector %@ for instance %@", selectorName, instance]);
            return nil;
        }
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:instance];
    } else {
        methodSignature = [cls methodSignatureForSelector:selector];
        if (!methodSignature) {
            _vkexceptionBlock([NSString stringWithFormat:@"unrecognized selector %@ for class %@", selectorName, className]);
            return nil;
        }
        invocation= [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:cls];
    }
    [invocation setSelector:selector];
    
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    NSInteger inputArguments = [(NSArray *)argumentsObj count];
    if (inputArguments > numberOfArguments - 2) {
        // calling variable argument method, only support parameter type `id` and return type `id`
        id sender = instance != nil ? instance : cls;
        id result = vkinvokeVariableParameterMethod(argumentsObj, methodSignature, sender, selector);
        return vkformatOCToJS(result);
    }
    
    for (NSUInteger i = 2; i < numberOfArguments; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i];
        id valObj = argumentsObj[i-2];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                
                #define JP_CALL_ARG_CASE(_typeString, _type, _selector) \
                case _typeString: {                              \
                    _type value = [valObj _selector];                     \
                    [invocation setArgument:&value atIndex:i];\
                    break; \
                }
                
                JP_CALL_ARG_CASE('c', char, charValue)
                JP_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
                JP_CALL_ARG_CASE('s', short, shortValue)
                JP_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
                JP_CALL_ARG_CASE('i', int, intValue)
                JP_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
                JP_CALL_ARG_CASE('l', long, longValue)
                JP_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
                JP_CALL_ARG_CASE('q', long long, longLongValue)
                JP_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
                JP_CALL_ARG_CASE('f', float, floatValue)
                JP_CALL_ARG_CASE('d', double, doubleValue)
                JP_CALL_ARG_CASE('B', BOOL, boolValue)
                
            case ':': {
                SEL value = nil;
                if (valObj != _vknilObj) {
                    value = NSSelectorFromString(valObj);
                }
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case '{': {
                NSString *typeString = vkextractStructName([NSString stringWithUTF8String:argumentType]);
                JSValue *val = arguments[i-2];
                #define JP_CALL_ARG_STRUCT(_type, _methodName) \
                if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                    _type value = [val _methodName];  \
                    [invocation setArgument:&value atIndex:i];  \
                    break; \
                }
                JP_CALL_ARG_STRUCT(CGRect, toRect)
                JP_CALL_ARG_STRUCT(CGPoint, toPoint)
                JP_CALL_ARG_STRUCT(CGSize, toSize)
                JP_CALL_ARG_STRUCT(NSRange, toRange)
                @synchronized (_vkcontext) {
                    NSDictionary *structDefine = _vkregisteredStruct[typeString];
                    if (structDefine) {
                        size_t size = vksizeOfStructTypes(structDefine[@"types"]);
                        void *ret = malloc(size);
                        vkgetStructDataWithDict(ret, valObj, structDefine);
                        [invocation setArgument:ret atIndex:i];
                        free(ret);
                        break;
                    }
                }
                
                break;
            }
            case '*':
            case '^': {
                if ([valObj isKindOfClass:[VKJPBoxing class]]) {
                    void *value = [((VKJPBoxing *)valObj) unboxPointer];
                    
                    if (argumentType[1] == '@') {
                        if (!_vkTMPMemoryPool) {
                            _vkTMPMemoryPool = [[NSMutableDictionary alloc] init];
                        }
                        if (!_markArray) {
                            _markArray = [[NSMutableArray alloc] init];
                        }
                        memset(value, 0, sizeof(id));
                        [_markArray addObject:valObj];
                    }
                    
                    [invocation setArgument:&value atIndex:i];
                    break;
                }
            }
            case '#': {
                if ([valObj isKindOfClass:[VKJPBoxing class]]) {
                    Class value = [((VKJPBoxing *)valObj) unboxClass];
                    [invocation setArgument:&value atIndex:i];
                    break;
                }
            }
            default: {
                if (valObj == _vknullObj) {
                    valObj = [NSNull null];
                    [invocation setArgument:&valObj atIndex:i];
                    break;
                }
                if (valObj == _vknilObj ||
                    ([valObj isKindOfClass:[NSNumber class]] && strcmp([valObj objCType], "c") == 0 && ![valObj boolValue])) {
                    valObj = nil;
                    [invocation setArgument:&valObj atIndex:i];
                    break;
                }
                if ([(JSValue *)arguments[i-2] hasProperty:@"__isBlock"]) {
                    __autoreleasing id cb = vkgenCallbackBlock(arguments[i-2]);
                    [invocation setArgument:&cb atIndex:i];
                } else {
                    [invocation setArgument:&valObj atIndex:i];
                }
            }
        }
    }
    
    if (superClassName) _vkcurrInvokeSuperClsName = superClassName;
    [invocation invoke];
    if (superClassName) _vkcurrInvokeSuperClsName = nil;
    if ([_markArray count] > 0) {
        for (VKJPBoxing *box in _markArray) {
            void *pointer = [box unboxPointer];
            id obj = *((__unsafe_unretained id *)pointer);
            if (obj) {
                @synchronized(_vkTMPMemoryPool) {
                    [_vkTMPMemoryPool setObject:obj forKey:[NSNumber numberWithInteger:[(NSObject*)obj hash]]];
                }
            }
        }
    }
    const char *returnType = [methodSignature methodReturnType];
    id returnValue;
    if (strncmp(returnType, "v", 1) != 0) {
        if (strncmp(returnType, "@", 1) == 0) {
            void *result;
            [invocation getReturnValue:&result];
            
            //For performance, ignore the other methods prefix with alloc/new/copy/mutableCopy
            if ([selectorName isEqualToString:@"alloc"] || [selectorName isEqualToString:@"new"] ||
                [selectorName isEqualToString:@"copy"] || [selectorName isEqualToString:@"mutableCopy"]) {
                returnValue = (__bridge_transfer id)result;
            } else {
                returnValue = (__bridge id)result;
            }
            return vkformatOCToJS(returnValue);
            
        } else {
            switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {
                    
                #define VKJP_CALL_RET_CASE(_typeString, _type) \
                case _typeString: {                              \
                    _type tempResultSet; \
                    [invocation getReturnValue:&tempResultSet];\
                    returnValue = @(tempResultSet); \
                    break; \
                }
                    
                VKJP_CALL_RET_CASE('c', char)
                VKJP_CALL_RET_CASE('C', unsigned char)
                VKJP_CALL_RET_CASE('s', short)
                VKJP_CALL_RET_CASE('S', unsigned short)
                VKJP_CALL_RET_CASE('i', int)
                VKJP_CALL_RET_CASE('I', unsigned int)
                VKJP_CALL_RET_CASE('l', long)
                VKJP_CALL_RET_CASE('L', unsigned long)
                VKJP_CALL_RET_CASE('q', long long)
                VKJP_CALL_RET_CASE('Q', unsigned long long)
                VKJP_CALL_RET_CASE('f', float)
                VKJP_CALL_RET_CASE('d', double)
                VKJP_CALL_RET_CASE('B', BOOL)

                case '{': {
                    NSString *typeString = vkextractStructName([NSString stringWithUTF8String:returnType]);
                    #define VKJP_CALL_RET_STRUCT(_type, _methodName) \
                    if ([typeString rangeOfString:@#_type].location != NSNotFound) {    \
                        _type result;   \
                        [invocation getReturnValue:&result];    \
                        return [JSValue _methodName:result inContext:_vkcontext];    \
                    }
                    VKJP_CALL_RET_STRUCT(CGRect, valueWithRect)
                    VKJP_CALL_RET_STRUCT(CGPoint, valueWithPoint)
                    VKJP_CALL_RET_STRUCT(CGSize, valueWithSize)
                    VKJP_CALL_RET_STRUCT(NSRange, valueWithRange)
                    @synchronized (_vkcontext) {
                        NSDictionary *structDefine = _vkregisteredStruct[typeString];
                        if (structDefine) {
                            size_t size = vksizeOfStructTypes(structDefine[@"types"]);
                            void *ret = malloc(size);
                            [invocation getReturnValue:ret];
                            NSDictionary *dict = vkgetDictOfStruct(ret, structDefine);
                            free(ret);
                            return dict;
                        }
                    }
                    break;
                }
                case '*':
                case '^': {
                    void *result;
                    [invocation getReturnValue:&result];
                    returnValue = vkformatOCToJS([VKJPBoxing boxPointer:result]);
                    if (strncmp(returnType, "^{CG", 4) == 0) {
                        if (!_vkpointersToRelease) {
                            _vkpointersToRelease = [[NSMutableArray alloc] init];
                        }
                        [_vkpointersToRelease addObject:[NSValue valueWithPointer:result]];
                        CFRetain(result);
                    }
                    break;
                }
                case '#': {
                    Class result;
                    [invocation getReturnValue:&result];
                    returnValue = vkformatOCToJS([VKJPBoxing boxClass:result]);
                    break;
                }
            }
            return returnValue;
        }
    }
    return nil;
}

id (*vknew_msgSend1)(id, SEL, id,...) = (id (*)(id, SEL, id,...)) objc_msgSend;
id (*vknew_msgSend2)(id, SEL, id, id,...) = (id (*)(id, SEL, id, id,...)) objc_msgSend;
id (*vknew_msgSend3)(id, SEL, id, id, id,...) = (id (*)(id, SEL, id, id, id,...)) objc_msgSend;
id (*vknew_msgSend4)(id, SEL, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id,...)) objc_msgSend;
id (*vknew_msgSend5)(id, SEL, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id,...)) objc_msgSend;
id (*vknew_msgSend6)(id, SEL, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id,...)) objc_msgSend;
id (*vknew_msgSend7)(id, SEL, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id,id,...)) objc_msgSend;
id (*vknew_msgSend8)(id, SEL, id, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id, id, id,...)) objc_msgSend;
id (*vknew_msgSend9)(id, SEL, id, id, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id, id, id, id, ...)) objc_msgSend;
id (*vknew_msgSend10)(id, SEL, id, id, id, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id, id, id, id, id,...)) objc_msgSend;

static id vkinvokeVariableParameterMethod(NSMutableArray *origArgumentsList, NSMethodSignature *methodSignature, id sender, SEL selector) {
    
    NSInteger inputArguments = [(NSArray *)origArgumentsList count];
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    
    NSMutableArray *argumentsList = [[NSMutableArray alloc] init];
    for (NSUInteger j = 0; j < inputArguments; j++) {
        NSInteger index = MIN(j + 2, numberOfArguments - 1);
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:index];
        id valObj = origArgumentsList[j];
        char argumentTypeChar = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];
        if (argumentTypeChar == '@') {
            [argumentsList addObject:valObj];
        } else {
            return nil;
        }
    }
    
    id results = nil;
    numberOfArguments = numberOfArguments - 2;
    
    //If you want to debug the macro code below, replace it to the expanded code:
    //https://gist.github.com/bang590/ca3720ae1da594252a2e
    #define VKJP_G_ARG(_idx) vkgetArgument(argumentsList[_idx])
    #define VKJP_CALL_MSGSEND_ARG1(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0));
    #define VKJP_CALL_MSGSEND_ARG2(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1));
    #define VKJP_CALL_MSGSEND_ARG3(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1), VKJP_G_ARG(2));
    #define VKJP_CALL_MSGSEND_ARG4(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1), VKJP_G_ARG(2), VKJP_G_ARG(3));
    #define VKJP_CALL_MSGSEND_ARG5(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1), VKJP_G_ARG(2), VKJP_G_ARG(3), VKJP_G_ARG(4));
    #define VKJP_CALL_MSGSEND_ARG6(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1), VKJP_G_ARG(2), VKJP_G_ARG(3), VKJP_G_ARG(4), VKJP_G_ARG(5));
    #define VKJP_CALL_MSGSEND_ARG7(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1), VKJP_G_ARG(2), VKJP_G_ARG(3), VKJP_G_ARG(4), VKJP_G_ARG(5), VKJP_G_ARG(6));
    #define VKJP_CALL_MSGSEND_ARG8(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1), VKJP_G_ARG(2), VKJP_G_ARG(3), VKJP_G_ARG(4), VKJP_G_ARG(5), VKJP_G_ARG(6), VKJP_G_ARG(7));
    #define VKJP_CALL_MSGSEND_ARG9(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1), VKJP_G_ARG(2), VKJP_G_ARG(3), VKJP_G_ARG(4), VKJP_G_ARG(5), VKJP_G_ARG(6), VKJP_G_ARG(7), VKJP_G_ARG(8));
    #define VKJP_CALL_MSGSEND_ARG10(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1), VKJP_G_ARG(2), VKJP_G_ARG(3), VKJP_G_ARG(4), VKJP_G_ARG(5), VKJP_G_ARG(6), VKJP_G_ARG(7), VKJP_G_ARG(8), VKJP_G_ARG(9));
    #define VKJP_CALL_MSGSEND_ARG11(_num) results = vknew_msgSend##_num(sender, selector, VKJP_G_ARG(0), VKJP_G_ARG(1), VKJP_G_ARG(2), VKJP_G_ARG(3), VKJP_G_ARG(4), VKJP_G_ARG(5), VKJP_G_ARG(6), VKJP_G_ARG(7), VKJP_G_ARG(8), VKJP_G_ARG(9), VKJP_G_ARG(10));
        
    #define VKJP_IF_REAL_ARG_COUNT(_num) if([argumentsList count] == _num)

    #define VKJP_DEAL_MSGSEND(_realArgCount, _defineArgCount) \
        if(numberOfArguments == _defineArgCount) { \
            VKJP_CALL_MSGSEND_ARG##_realArgCount(_defineArgCount) \
        }
    
    VKJP_IF_REAL_ARG_COUNT(1) { VKJP_CALL_MSGSEND_ARG1(1) }
    VKJP_IF_REAL_ARG_COUNT(2) { VKJP_DEAL_MSGSEND(2, 1) VKJP_DEAL_MSGSEND(2, 2) }
    VKJP_IF_REAL_ARG_COUNT(3) { VKJP_DEAL_MSGSEND(3, 1) VKJP_DEAL_MSGSEND(3, 2) VKJP_DEAL_MSGSEND(3, 3) }
    VKJP_IF_REAL_ARG_COUNT(4) { VKJP_DEAL_MSGSEND(4, 1) VKJP_DEAL_MSGSEND(4, 2) VKJP_DEAL_MSGSEND(4, 3) VKJP_DEAL_MSGSEND(4, 4) }
    VKJP_IF_REAL_ARG_COUNT(5) { VKJP_DEAL_MSGSEND(5, 1) VKJP_DEAL_MSGSEND(5, 2) VKJP_DEAL_MSGSEND(5, 3) VKJP_DEAL_MSGSEND(5, 4) VKJP_DEAL_MSGSEND(5, 5) }
    VKJP_IF_REAL_ARG_COUNT(6) { VKJP_DEAL_MSGSEND(6, 1) VKJP_DEAL_MSGSEND(6, 2) VKJP_DEAL_MSGSEND(6, 3) VKJP_DEAL_MSGSEND(6, 4) VKJP_DEAL_MSGSEND(6, 5) VKJP_DEAL_MSGSEND(6, 6) }
    VKJP_IF_REAL_ARG_COUNT(7) { VKJP_DEAL_MSGSEND(7, 1) VKJP_DEAL_MSGSEND(7, 2) VKJP_DEAL_MSGSEND(7, 3) VKJP_DEAL_MSGSEND(7, 4) VKJP_DEAL_MSGSEND(7, 5) VKJP_DEAL_MSGSEND(7, 6) VKJP_DEAL_MSGSEND(7, 7) }
    VKJP_IF_REAL_ARG_COUNT(8) { VKJP_DEAL_MSGSEND(8, 1) VKJP_DEAL_MSGSEND(8, 2) VKJP_DEAL_MSGSEND(8, 3) VKJP_DEAL_MSGSEND(8, 4) VKJP_DEAL_MSGSEND(8, 5) VKJP_DEAL_MSGSEND(8, 6) VKJP_DEAL_MSGSEND(8, 7) VKJP_DEAL_MSGSEND(8, 8) }
    VKJP_IF_REAL_ARG_COUNT(9) { VKJP_DEAL_MSGSEND(9, 1) VKJP_DEAL_MSGSEND(9, 2) VKJP_DEAL_MSGSEND(9, 3) VKJP_DEAL_MSGSEND(9, 4) VKJP_DEAL_MSGSEND(9, 5) VKJP_DEAL_MSGSEND(9, 6) VKJP_DEAL_MSGSEND(9, 7) VKJP_DEAL_MSGSEND(9, 8) VKJP_DEAL_MSGSEND(9, 9) }
    VKJP_IF_REAL_ARG_COUNT(10) { VKJP_DEAL_MSGSEND(10, 1) VKJP_DEAL_MSGSEND(10, 2) VKJP_DEAL_MSGSEND(10, 3) VKJP_DEAL_MSGSEND(10, 4) VKJP_DEAL_MSGSEND(10, 5) VKJP_DEAL_MSGSEND(10, 6) VKJP_DEAL_MSGSEND(10, 7) VKJP_DEAL_MSGSEND(10, 8) VKJP_DEAL_MSGSEND(10, 9) VKJP_DEAL_MSGSEND(10, 10) }
    
    return results;
}

static id vkgetArgument(id valObj){
    if (valObj == _vknilObj ||
        ([valObj isKindOfClass:[NSNumber class]] && strcmp([valObj objCType], "c") == 0 && ![valObj boolValue])) {
        return nil;
    }
    return valObj;
}

#pragma mark -

static id vkgenCallbackBlock(JSValue *jsVal)
{
    #define VKBLK_TRAITS_ARG(_idx, _paramName) \
    if (_idx < argTypes.count) { \
        if (vkblockTypeIsObject(vktrim(argTypes[_idx]))) {  \
            [list addObject:vkformatOCToJS((__bridge id)_paramName)]; \
        } else {  \
            [list addObject:vkformatOCToJS([NSNumber numberWithLongLong:(long long)_paramName])]; \
        }   \
    }

    NSArray *argTypes = [[jsVal[@"args"] toString] componentsSeparatedByString:@","];
    id cb = ^id(void *p0, void *p1, void *p2, void *p3, void *p4, void *p5) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        VKBLK_TRAITS_ARG(0, p0)
        VKBLK_TRAITS_ARG(1, p1)
        VKBLK_TRAITS_ARG(2, p2)
        VKBLK_TRAITS_ARG(3, p3)
        VKBLK_TRAITS_ARG(4, p4)
        VKBLK_TRAITS_ARG(5, p5)
        JSValue *ret = [jsVal[@"cb"] callWithArguments:list];
        return vkformatJSToOC(ret);
    };
    
    return cb;
}

#pragma mark - Struct

static int vksizeOfStructTypes(NSString *structTypes)
{
    const char *types = [structTypes cStringUsingEncoding:NSUTF8StringEncoding];
    int index = 0;
    int size = 0;
    while (types[index]) {
        switch (types[index]) {
            #define VKJP_STRUCT_SIZE_CASE(_typeChar, _type)   \
            case _typeChar: \
                size += sizeof(_type);  \
                break;
                
            VKJP_STRUCT_SIZE_CASE('c', char)
            VKJP_STRUCT_SIZE_CASE('C', unsigned char)
            VKJP_STRUCT_SIZE_CASE('s', short)
            VKJP_STRUCT_SIZE_CASE('S', unsigned short)
            VKJP_STRUCT_SIZE_CASE('i', int)
            VKJP_STRUCT_SIZE_CASE('I', unsigned int)
            VKJP_STRUCT_SIZE_CASE('l', long)
            VKJP_STRUCT_SIZE_CASE('L', unsigned long)
            VKJP_STRUCT_SIZE_CASE('q', long long)
            VKJP_STRUCT_SIZE_CASE('Q', unsigned long long)
            VKJP_STRUCT_SIZE_CASE('f', float)
            VKJP_STRUCT_SIZE_CASE('F', CGFloat)
            VKJP_STRUCT_SIZE_CASE('N', NSInteger)
            VKJP_STRUCT_SIZE_CASE('U', NSUInteger)
            VKJP_STRUCT_SIZE_CASE('d', double)
            VKJP_STRUCT_SIZE_CASE('B', BOOL)
            VKJP_STRUCT_SIZE_CASE('*', void *)
            VKJP_STRUCT_SIZE_CASE('^', void *)
            
            default:
                break;
        }
        index ++;
    }
    return size;
}

static void vkgetStructDataWithDict(void *structData, NSDictionary *dict, NSDictionary *structDefine)
{
    NSArray *itemKeys = structDefine[@"keys"];
    const char *structTypes = [structDefine[@"types"] cStringUsingEncoding:NSUTF8StringEncoding];
    int position = 0;
    for (int i = 0; i < itemKeys.count; i ++) {
        switch(structTypes[i]) {
            #define VKJP_STRUCT_DATA_CASE(_typeStr, _type, _transMethod) \
            case _typeStr: { \
                int size = sizeof(_type);    \
                _type val = [dict[itemKeys[i]] _transMethod];   \
                memcpy(structData + position, &val, size);  \
                position += size;    \
                break;  \
            }
                
            VKJP_STRUCT_DATA_CASE('c', char, charValue)
            VKJP_STRUCT_DATA_CASE('C', unsigned char, unsignedCharValue)
            VKJP_STRUCT_DATA_CASE('s', short, shortValue)
            VKJP_STRUCT_DATA_CASE('S', unsigned short, unsignedShortValue)
            VKJP_STRUCT_DATA_CASE('i', int, intValue)
            VKJP_STRUCT_DATA_CASE('I', unsigned int, unsignedIntValue)
            VKJP_STRUCT_DATA_CASE('l', long, longValue)
            VKJP_STRUCT_DATA_CASE('L', unsigned long, unsignedLongValue)
            VKJP_STRUCT_DATA_CASE('q', long long, longLongValue)
            VKJP_STRUCT_DATA_CASE('Q', unsigned long long, unsignedLongLongValue)
            VKJP_STRUCT_DATA_CASE('f', float, floatValue)
            VKJP_STRUCT_DATA_CASE('d', double, doubleValue)
            VKJP_STRUCT_DATA_CASE('B', BOOL, boolValue)
            VKJP_STRUCT_DATA_CASE('N', NSInteger, integerValue)
            VKJP_STRUCT_DATA_CASE('U', NSUInteger, unsignedIntegerValue)
            
            case 'F': {
                int size = sizeof(CGFloat);
                CGFloat val;
                #if CGFLOAT_IS_DOUBLE
                val = [dict[itemKeys[i]] doubleValue];
                #else
                val = [dict[itemKeys[i]] floatValue];
                #endif
                memcpy(structData + position, &val, size);
                position += size;
                break;
            }
            
            case '*':
            case '^': {
                int size = sizeof(void *);
                void *val = [(VKJPBoxing *)dict[itemKeys[i]] unboxPointer];
                memcpy(structData + position, &val, size);
                break;
            }
            
        }
    }
}

static NSDictionary *vkgetDictOfStruct(void *structData, NSDictionary *structDefine)
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *itemKeys = structDefine[@"keys"];
    const char *structTypes = [structDefine[@"types"] cStringUsingEncoding:NSUTF8StringEncoding];
    int position = 0;
    
    for (int i = 0; i < itemKeys.count; i ++) {
        switch(structTypes[i]) {
            #define VKJP_STRUCT_DICT_CASE(_typeName, _type)   \
            case _typeName: { \
                size_t size = sizeof(_type); \
                _type *val = malloc(size);   \
                memcpy(val, structData + position, size);   \
                [dict setObject:@(*val) forKey:itemKeys[i]];    \
                free(val);  \
                position += size;   \
                break;  \
            }
            VKJP_STRUCT_DICT_CASE('c', char)
            VKJP_STRUCT_DICT_CASE('C', unsigned char)
            VKJP_STRUCT_DICT_CASE('s', short)
            VKJP_STRUCT_DICT_CASE('S', unsigned short)
            VKJP_STRUCT_DICT_CASE('i', int)
            VKJP_STRUCT_DICT_CASE('I', unsigned int)
            VKJP_STRUCT_DICT_CASE('l', long)
            VKJP_STRUCT_DICT_CASE('L', unsigned long)
            VKJP_STRUCT_DICT_CASE('q', long long)
            VKJP_STRUCT_DICT_CASE('Q', unsigned long long)
            VKJP_STRUCT_DICT_CASE('f', float)
            VKJP_STRUCT_DICT_CASE('F', CGFloat)
            VKJP_STRUCT_DICT_CASE('N', NSInteger)
            VKJP_STRUCT_DICT_CASE('U', NSUInteger)
            VKJP_STRUCT_DICT_CASE('d', double)
            VKJP_STRUCT_DICT_CASE('B', BOOL)
            
            case '*':
            case '^': {
                size_t size = sizeof(void *);
                void *val = malloc(size);
                memcpy(val, structData + position, size);
                [dict setObject:[VKJPBoxing boxPointer:val] forKey:itemKeys[i]];
                position += size;
                break;
            }
            
        }
    }
    return dict;
}

static NSString *vkextractStructName(NSString *typeEncodeString)
{
    NSArray *array = [typeEncodeString componentsSeparatedByString:@"="];
    NSString *typeString = array[0];
    int firstValidIndex = 0;
    for (int i = 0; i< typeString.length; i++) {
        char c = [typeString characterAtIndex:i];
        if (c == '{' || c=='_') {
            firstValidIndex++;
        }else {
            break;
        }
    }
    return [typeString substringFromIndex:firstValidIndex];
}

#pragma mark - Utils

static NSString *vktrim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

static BOOL vkblockTypeIsObject(NSString *typeString)
{
    return [typeString rangeOfString:@"*"].location != NSNotFound || [typeString isEqualToString:@"id"];
}

static NSString *vkconvertJPSelectorString(NSString *selectorString)
{
    NSString *tmpJSMethodName = [selectorString stringByReplacingOccurrencesOfString:@"__" withString:@"-"];
    NSString *selectorName = [tmpJSMethodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
    return [selectorName stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
}

#pragma mark - Object format

static id vkformatOCToJS(id obj)
{
    if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSDate class]]) {
        return _vkautoConvert ? obj: _vkwrapObj([VKJPBoxing boxObj:obj]);
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        return _vkconvertOCNumberToString ? [(NSNumber*)obj stringValue] : obj;
    }
    if ([obj isKindOfClass:NSClassFromString(@"NSBlock")] || [obj isKindOfClass:[JSValue class]]) {
        return obj;
    }
    return _vkwrapObj(obj);
}

static id vkformatJSToOC(JSValue *jsval)
{
    id obj = [jsval toObject];
    if (!obj || [obj isKindOfClass:[NSNull class]]) return _vknilObj;
    
    if ([obj isKindOfClass:[VKJPBoxing class]]) return [obj unbox];
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [(NSArray*)obj count]; i ++) {
            [newArr addObject:vkformatJSToOC(jsval[i])];
        }
        return newArr;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        if (obj[@"__obj"]) {
            id ocObj = [obj objectForKey:@"__obj"];
            if ([ocObj isKindOfClass:[VKJPBoxing class]]) return [ocObj unbox];
            return ocObj;
        }
        if (obj[@"__isBlock"]) {
            return vkgenCallbackBlock(jsval);
        }
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in [obj allKeys]) {
            [newDict setObject:vkformatJSToOC(jsval[key]) forKey:key];
        }
        return newDict;
    }
    return obj;
}

static id _vkformatOCToJSList(NSArray *list)
{
    NSMutableArray *arr = [NSMutableArray new];
    for (id obj in list) {
        [arr addObject:vkformatOCToJS(obj)];
    }
    return arr;
}

static NSDictionary *_vkwrapObj(id obj)
{
    if (!obj || obj == _vknilObj) {
        return @{@"__isNil": @(YES)};
    }
    return @{@"__obj": obj, @"__clsName": NSStringFromClass([obj isKindOfClass:[VKJPBoxing class]] ? [[((VKJPBoxing *)obj) unbox] class]: [obj class])};
}

static id _vkunboxOCObjectToJS(id obj)
{
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [(NSArray*)obj count]; i ++) {
            [newArr addObject:_vkunboxOCObjectToJS(obj[i])];
        }
        return newArr;
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
        for (NSString *key in [obj allKeys]) {
            [newDict setObject:_vkunboxOCObjectToJS(obj[key]) forKey:key];
        }
        return newDict;
    }
    if ([obj isKindOfClass:[NSString class]] ||[obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:NSClassFromString(@"NSBlock")] || [obj isKindOfClass:[NSDate class]]) {
        return obj;
    }
    return _vkwrapObj(obj);
}
@end


@implementation VKJPExtension

+ (void)main:(JSContext *)context{}

+ (void *)formatPointerJSToOC:(JSValue *)val
{
    id obj = [val toObject];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        if (obj[@"__obj"] && [obj[@"__obj"] isKindOfClass:[VKJPBoxing class]]) {
            return [(VKJPBoxing *)(obj[@"__obj"]) unboxPointer];
        } else {
            return NULL;
        }
    } else if (![val toBool]) {
        return NULL;
    } else{
        return [((VKJPBoxing *)[val toObject]) unboxPointer];
    }
}

+ (id)formatRetainedCFTypeOCToJS:(CFTypeRef)CF_CONSUMED type
{
    return vkformatOCToJS([VKJPBoxing boxPointer:(void *)type]);
}

+ (id)formatPointerOCToJS:(void *)pointer
{
    return vkformatOCToJS([VKJPBoxing boxPointer:pointer]);
}

+ (id)formatJSToOC:(JSValue *)val
{
    if (![val toBool]) {
        return nil;
    }
    return vkformatJSToOC(val);
}

+ (id)formatOCToJS:(id)obj
{
    return [[JSContext currentContext][@"_formatOCToJS"] callWithArguments:@[vkformatOCToJS(obj)]];
}

+ (int)sizeOfStructTypes:(NSString *)structTypes
{
    return vksizeOfStructTypes(structTypes);
}

+ (void)getStructDataWidthDict:(void *)structData dict:(NSDictionary *)dict structDefine:(NSDictionary *)structDefine
{
    return vkgetStructDataWithDict(structData, dict, structDefine);
}

+ (NSDictionary *)getDictOfStruct:(void *)structData structDefine:(NSDictionary *)structDefine
{
    return vkgetDictOfStruct(structData, structDefine);
}

+ (NSMutableDictionary *)registeredStruct
{
    return _vkregisteredStruct;
}

+ (NSDictionary *)overideMethods
{
    return _vkJSOverideMethods;
}

+ (NSMutableSet *)includedScriptPaths
{
    return _vkrunnedScript;
}

@end

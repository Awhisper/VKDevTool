//
//  VKURLProtocol.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/18.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKURLProtocol.h"
#import "VKNetworkLogger.h"
#import "VKDevToolDefine.h"

static NSString * const VKURLProtocolHandledKey = @"VKURLProtocolHandledKey";

@interface VKURLProtocol ()<NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation VKURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
#ifdef VKDevMode
    if (![VKNetworkLogger singleton].enableHook) {
        return NO;
    }
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if ( ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
          [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame))
    {
        if ([VKNetworkLogger singleton].hostFilter && [VKNetworkLogger singleton].hostFilter.length > 0) {
            
            NSString *url = [[request URL] absoluteString];
            if ([url rangeOfString:[VKNetworkLogger singleton].hostFilter].location != NSNotFound) {
                //看看是否已经处理过了，防止无限循环
                if ([NSURLProtocol propertyForKey:VKURLProtocolHandledKey inRequest:request]) {
                    return NO;
                }
            }
        }else{
            //看看是否已经处理过了，防止无限循环
            if ([NSURLProtocol propertyForKey:VKURLProtocolHandledKey inRequest:request]) {
                return NO;
            }
        }
        return YES;
    }
#endif
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+(BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

-(void)startLoading{
    //打标签，防止无限循环
    
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    
    [NSURLProtocol setProperty:@YES forKey:VKURLProtocolHandledKey inRequest:mutableReqeust];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
#pragma clang diagnostic pop
}

-(void)stopLoading{
    [self.connection cancel];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self
            didFailWithError:error];
}
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response != nil)
    {
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return YES;
}
- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.client URLProtocol:self
didReceiveAuthenticationChallenge:challenge];
}
- (void)connection:(NSURLConnection *)connection
didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self.client URLProtocol:self
didCancelAuthenticationChallenge:challenge];
}
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [VKNetworkLogger VKNetworkResponseLog:response];
    [self.client URLProtocol:self
          didReceiveResponse:response
          cacheStoragePolicy:(NSURLCacheStoragePolicy)[[self request] cachePolicy]];
}
- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [VKNetworkLogger VKNetworkResponseDataLog:data];
    [self.client URLProtocol:self
                 didLoadData:data];
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}
@end

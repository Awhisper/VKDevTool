//
//  ViewController.m
//  VKScriptConsole_Proj
//
//  Created by Awhisper on 16/5/20.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "ViewController.h"
#import "VKDevToolDefine.h"
#import "VKNetworkLogger.h"
@interface ViewController ()

@property (nonatomic,strong) NSString * name;

@property (nonatomic,assign) NSInteger  age;

@property (nonatomic,strong) UILabel * label;

@property (nonatomic,strong) UIButton *bt;

@property (nonatomic,strong) UIView *v;

@property (nonatomic,strong) NSArray * data;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"测试界面";
    
    NSLog(@"abc = %@",@"1");
    
    self.name = @"味精";
    self.age = 18;
    
    self.data = @[@"111",@"222",@"333",@"444",@"555"];
    
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 1000, 50)];
    self.label.font = [UIFont systemFontOfSize:20];
    self.label.text = @"测试文案";
    [self.view addSubview:self.label];
    
    
    
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(150, 300, 100, 100)];
    [self.view addSubview:v];
    v.backgroundColor = [UIColor greenColor];
    self.v = v;
    
    
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    NSLog(@"111 ===== 111");
    
    NSError *error = [NSError errorWithDomain:@"aaaaahahhaa" code:1 userInfo:nil];
    
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timertimer) userInfo:nil repeats:YES];
//     Do any additional setup after loading the view, typically from a nib.
    [VKNetworkLogger singleton].hostFilter = @"appwk.baidu.com";
    // 快捷方式获得session对象
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://appwk.baidu.com/naapi/iap/userbankinfo?uid=bd_0&from=ios_appstore&app_ua=Simulator&ua=bd_1334_750_Simulator_3.4.9_9.2&fr=2&pid=1&bid=2&Bdi_bear=wifi&app_ver=3.4.9&sys_ver=9.2&cuid=50c78ca9f3c39a34c963de578bef1d8c7aecc087&sessid=1471498926&screen=750_1334&opid=wk_na&ydvendor=84942C9A-E479-4856-945A-D55FBCDF4D57"];
    // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
    NSURLSessionTask *task = [session dataTaskWithURL:url
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if (data) {
                                            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
                                        }
                                        
                                    }];
    
    NSURLSessionTask *task1 = [session dataTaskWithURL:url
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if (data) {
                                            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
                                        }
                                    }];
//
    NSURLSessionTask *task2 = [session dataTaskWithURL:url
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if (data) {
                                            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
                                        }
                                    }];
    // 启动任务
    [task resume];
    [task2 resume];
    [task1 resume];
}

-(void)timertimer{
    NSLog(@"111 ===== 111");
   
    NSError *error =[NSError errorWithDomain:@"woshige erro" code:1 userInfo:nil];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://appwk.baidu.com/naapi/iap/userbankinfo?uid=bd_0&from=ios_appstore&app_ua=Simulator&ua=bd_1334_750_Simulator_3.4.9_9.2&fr=2&pid=1&bid=2&Bdi_bear=wifi&app_ver=3.4.9&sys_ver=9.2&cuid=50c78ca9f3c39a34c963de578bef1d8c7aecc087&sessid=1471498926&screen=750_1334&opid=wk_na&ydvendor=84942C9A-E479-4856-945A-D55FBCDF4D57"];
    // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
    NSURLSessionTask *task = [session dataTaskWithURL:url
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if (data) {
                                            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
                                        }
                                    }];
    [task resume];
}


-(void)setlabelname
{
    NSString *txt = [NSString stringWithFormat:@"我叫：%@，哇哈哈 永远 %@",self.name,@(self.age)];
    self.label.text = txt;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma clang diagnostic pop
@end

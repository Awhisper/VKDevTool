//
//  ViewController.m
//  VKScriptConsole_Proj
//
//  Created by Awhisper on 16/5/20.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "ViewController.h"
#import "VKScriptConsole.h"

#import "VKDebugConsole.h"
@interface ViewController ()

@property (nonatomic,strong) NSString * name;

@property (nonatomic,assign) NSInteger  age;

@property (nonatomic,strong) UILabel * label;

@property (nonatomic,strong) UIButton *bt;

@property (nonatomic,strong) UIView *v;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"测试界面";
    
    self.name = @"味精";
    self.age = 28;
    
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 1000, 50)];
    self.label.font = [UIFont systemFontOfSize:20];
    self.label.text = @"测试文案";
    [self.view addSubview:self.label];
    
    
    
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(150, 300, 100, 100)];
    [self.view addSubview:v];
    v.backgroundColor = [UIColor greenColor];
    self.v = v;
    
    [VKDebugConsole showBt];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)setlabelname
{
    NSString *txt = [NSString stringWithFormat:@"我叫：%@，哇哈哈 %@",self.name,@(self.age)];
    self.label.text = txt;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

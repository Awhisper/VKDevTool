//
//  VKNetworkConsoleView.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/18.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKNetworkConsoleView.h"
#import "VKNetworkLogger.h"
#import "VKUIKitMarco.h"
#import "VKDevToolDefine.h"
@interface VKNetworkConsoleView ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) UITableView *requestTable;

@property (nonatomic,strong) NSMutableArray *requestDataArr;

@property (nonatomic,strong) NSMutableArray *requestArr;

@property (nonatomic,strong) NSString *pasteboardString;


@end

@implementation VKNetworkConsoleView


-(UITableView *)requestTable
{
    if (!_requestTable) {
#ifdef VKDevMode
        _requestTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, VK_AppScreenWidth, VK_AppScreenHeight - 20)];
        _requestTable.delegate = self;
        _requestTable.dataSource = self;
        _requestTable.backgroundColor = [UIColor clearColor];
        [self addSubview:_requestTable];
#endif
    }
    return _requestTable;
}


-(void)showConsole{
#ifdef VKDevMode
    [super showConsole];
    [self addLogNotificationObserver];
    [self showLogManagerOldLog];
#endif
}

-(void)hideConsole
{
#ifdef VKDevMode
    [super hideConsole];
    [self removeLogNotificationObserver];
#endif
}

-(void)showLogManagerOldLog
{
#ifdef VKDevMode
    self.requestDataArr = [[NSMutableArray alloc]initWithArray:[VKNetworkLogger singleton].logDataArray];
    self.requestArr = [[NSMutableArray alloc]initWithArray:[VKNetworkLogger singleton].logReqArray];
    [self.requestTable reloadData];
#endif
}

-(void)addLogNotificationObserver
{
#ifdef VKDevMode
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logNotificationDataGet:) name:VKNetDataLogNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logNotificationGet:) name:VKNetReqLogNotification object:nil];
#endif
}

-(void)removeLogNotificationObserver
{
#ifdef VKDevMode
    [[NSNotificationCenter defaultCenter]removeObserver:self];
#endif
}

-(void)logNotificationGet:(NSNotification *)noti
{
#ifdef VKDevMode
    NSURLRequest * request = noti.object;
    if (request) {
        [self.requestArr addObject:request];
    }
#endif
}

-(void)logNotificationDataGet:(NSNotification *)noti
{
#ifdef VKDevMode
    NSURLRequest * request = noti.object;
    if (request) {
        [self.requestDataArr addObject:request];
    }
    [self.requestTable reloadData];
#endif
}

#pragma mark  tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.requestDataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *requestID = @"VKRequestID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:requestID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:requestID];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    if (indexPath.row < self.requestArr.count) {
        NSURLRequest *req = self.requestArr[indexPath.row];
        cell.textLabel.text = req.URL.absoluteString;
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef VKDevMode
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSURLRequest *req = self.requestArr[indexPath.row];
    NSString *strurl = req.URL.absoluteString;
    
    NSData *reqData = self.requestDataArr[indexPath.row];
    NSString *strdata = [[NSJSONSerialization JSONObjectWithData:reqData options:kNilOptions error:nil] description];
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"返回数据" message:strdata delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"复制", nil];
    [alert show];
    
    NSString *pasteboardstr = [NSString stringWithFormat:@"URL: %@ \n\n Data: %@",strurl,strdata];
    self.pasteboardString = pasteboardstr;
#endif
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#ifdef VKDevMode
    if (buttonIndex == 1) {//复制
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.pasteboardString;
        self.pasteboardString = nil;
    }
#endif
}
#pragma clang diagnostic pop
@end

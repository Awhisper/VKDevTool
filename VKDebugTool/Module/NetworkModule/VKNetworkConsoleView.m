//
//  VKNetworkConsoleView.m
//  VKDebugToolDemo
//
//  Created by Awhisper on 16/8/18.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "VKNetworkConsoleView.h"
#import "VKNetworkLogger.h"
@interface VKNetworkConsoleView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *requestTable;

@property (nonatomic,strong) NSMutableArray *requestData;


@end

@implementation VKNetworkConsoleView


-(UITableView *)requestTable
{
    if (!_requestTable) {
        _requestTable = [[UITableView alloc]initWithFrame:self.bounds];
        _requestTable.delegate = self;
        _requestTable.dataSource = self;
        _requestTable.backgroundColor = [UIColor clearColor];
        [self addSubview:_requestTable];
    }
    return _requestTable;
}


-(void)showConsole{
    [super showConsole];
    [self addLogNotificationObserver];
    [self showLogManagerOldLog];
}

-(void)hideConsole
{
    [super hideConsole];
    [self removeLogNotificationObserver];
}

-(void)showLogManagerOldLog
{
    self.requestData = [[NSMutableArray alloc]initWithArray:[VKNetworkLogger singleton].logDataArray];
    [self.requestTable reloadData];
}

-(void)addLogNotificationObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logNotificationGet:) name:VKNetLogNotification object:nil];
}

-(void)removeLogNotificationObserver
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)logNotificationGet:(NSNotification *)noti
{
    NSURLRequest * request = noti.object;
    if (request) {
        [self.requestData addObject:request];
    }
    [self.requestTable reloadData];
}

#pragma mark  tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.requestData.count;
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
    }
    if (indexPath.row < self.requestData.count) {
        NSURLRequest *req = self.requestData[indexPath.row];
        cell.textLabel.text = req.URL.absoluteString;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

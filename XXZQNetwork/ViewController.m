//
//  ViewController.m
//  XXZQNetwork
//
//  Created by XXXBryant on 16/7/22.
//  Copyright © 2016年 张琦. All rights reserved.
//

#import "ViewController.h"
#import "XXZQNetwork.h"

#define URLString @"http"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *buttongetdata = [[UIButton alloc] initWithFrame:CGRectMake(30, 100, 60, 30)];
    [self.view addSubview:buttongetdata];
    buttongetdata.backgroundColor = [UIColor redColor];
    [buttongetdata addTarget:self action:@selector(getNetWorkData) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttongetdata1 = [[UIButton alloc] initWithFrame:CGRectMake(30, 200, 60, 30)];
    [self.view addSubview:buttongetdata1];
    buttongetdata1.backgroundColor = [UIColor redColor];
    [buttongetdata1 addTarget:self action:@selector(getNetWorkData1) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void) getNetWorkData
{
    [[XXZQNetwork sharedInstance] getWithURLString:URLString
                                        parameters:nil
                                           success:^(id responseObject) {
                                NSLog(@"%@",responseObject);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    [[XXZQNetwork sharedInstance] postWithURLString:URLString
                                        parameters:nil
                                           success:^(id responseObject) {
                                               NSLog(@"%@",responseObject);
                                           } failure:^(NSError *error) {
                                               NSLog(@"%@",error);
                                           }];
    
}

- (void)getNetWorkData1 {
    
    [[XXZQNetwork sharedInstance] cancelAllRequest];
}

@end

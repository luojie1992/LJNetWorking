//
//  ViewController.m
//  test
//
//  Created by jie jie on 2017/12/22.
//  Copyright © 2017年 jie jie. All rights reserved.
//

#import "ViewController.h"
#import "LJNetWorking.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [LJNetWorking getWithUrl:@"https://tm.dgzq.com.cn/app/portfolio/recommend" refreshRequest:YES cache:YES params:nil progressBlock:^(int64_t bytesRead, int64_t totalBytes) {
        
    } succesBlock:^(id response) {
        NSLog(@"%@",response) ;
    } failBlcok:^(NSError *error) {
        NSLog(@"%@",error) ;
    }] ;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

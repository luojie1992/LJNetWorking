//
//  LJNetWorking+RequestManager.m
//  LJNetWorking
//
//  Created by jie jie on 2017/12/22.
//  Copyright © 2017年 jie jie. All rights reserved.
//

#import "LJNetWorking+RequestManager.h"
#import "LJNetWorking.h"
#import "AFNetworking.h"

@interface NSURLRequest (decide)

//判断是否是同一个请求（依据是请求url和参数是否相同）
- (BOOL)LJ_isTheSameRequest:(NSURLRequest *)request;

@end

@implementation NSURLRequest (decide)

- (BOOL)LJ_isTheSameRequest:(NSURLRequest *)request {
    if ([self.HTTPMethod isEqualToString:request.HTTPMethod]) {
        if ([self.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
            if ([self.HTTPMethod isEqualToString:@"GET"]||[self.HTTPBody isEqualToData:request.HTTPBody]) {
                return YES;
            }
        }
    }
    return NO;
}

@end


@implementation LJNetWorking (RequestManager)

+ (BOOL)haveSameRequestInTasksPool:(LJURLSessionTask *)task {
    __block BOOL isSame = NO ;
    [[self allTasks] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LJURLSessionTask *session =    (LJURLSessionTask*)obj ;
        if ([task.originalRequest LJ_isTheSameRequest:session.originalRequest]) {
            isSame = YES ;
            *stop = YES ;
        }
    }] ;
    
    return  isSame  ;
}

+ (LJURLSessionTask *)cancleSameRequestInTasksPool:(LJURLSessionTask *)task {
    __block LJURLSessionTask *oldTask = nil;
    [[self currentRunningTasks] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LJURLSessionTask *session =    (LJURLSessionTask*)obj ;
        if ([task.originalRequest LJ_isTheSameRequest:session.originalRequest]) {
            if (session.state == NSURLSessionTaskStateRunning) {
                [session cancel] ;
                oldTask = session ;
            }
            *stop = YES ;
        }
    }] ;
    

    return  oldTask ;
}


@end



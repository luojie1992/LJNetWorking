//
//  LJNetWorking+RequestManager.h
//  LJNetWorking
//
//  Created by jie jie on 2017/12/22.
//  Copyright © 2017年 jie jie. All rights reserved.
//

#import "LJNetWorking.h"

@interface LJNetWorking (RequestManager)

+ (BOOL)haveSameRequestInTasksPool:(LJURLSessionTask *)task;

+ (LJURLSessionTask *)cancleSameRequestInTasksPool:(LJURLSessionTask *)task;


@end

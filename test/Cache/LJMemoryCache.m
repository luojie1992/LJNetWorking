//
//  LJMemoryCache.m
//  LJNetWorking
//
//  Created by jie jie on 2017/12/22.
//  Copyright © 2017年 jie jie. All rights reserved.
//

#import "LJMemoryCache.h"
#import <UIKit/UIKit.h>

static NSCache *shareCache;


@implementation LJMemoryCache

+ (NSCache *)shareCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (shareCache == nil) shareCache = [[NSCache alloc] init];
    });
    
    //当收到内存警报时，清空内存缓存
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [shareCache removeAllObjects];
    }];
    
    return shareCache;
}

+ (void)writeData:(id)data forKey:(NSString *)key {
    assert(data);
    
    assert(key);
    
    NSCache *cache = [LJMemoryCache shareCache];
    
    [cache setObject:data forKey:key];
    
}

+ (id)readDataWithKey:(NSString *)key {
    assert(key);
    
    id data = nil;
    
    NSCache *cache = [LJMemoryCache shareCache];
    
    data = [cache objectForKey:key];
    
    
    return data;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}


@end

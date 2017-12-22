//
//  LJNetWorking.m
//  LJNetWorking
//
//  Created by jie jie on 2017/12/22.
//  Copyright © 2017年 jie jie. All rights reserved.
//

#import "LJNetWorking.h"
#import "AFNetworking.h"
#import "LJNetWorking+RequestManager.h"
#import "LJCacheManager.h"

#define LJ_ERROR_INFOMATION  @"network error"

static NSMutableArray *requestTaskPool ;
static NSDictionary *headersDictionarys ;
static LJNetWorkingStatus netWorkStatus ;
static NSTimeInterval requestTimeOut = 30.0f ;

@implementation LJNetWorking

+ (AFHTTPSessionManager *)initManager {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager] ;
    // 默认解析方式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer] ;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer ] ;
    
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer] ;
    [serializer setRemovesKeysWithNullValues:YES] ;
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding ;
    manager.requestSerializer.timeoutInterval = requestTimeOut ; // 请求超时时间
    
    
    // 设置请求头
    for (NSString *key in headersDictionarys.allKeys) {
        if (headersDictionarys[key] != nil) {
            [manager.responseSerializer setValue:headersDictionarys[key] forKey:key] ;
            
        }
    }
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*",
                                                                              @"application/octet-stream",
                                                                              @"application/zip"]];
    
    
    
    [self chectNetWorkStatus] ;
    return manager ;
}

+ (void)chectNetWorkStatus {
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                netWorkStatus = LJNetWorkingStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusUnknown:
                netWorkStatus = LJNetWorkingStatusUnknown;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                netWorkStatus = LJNetWorkingStatusViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                netWorkStatus = LJNetWorkingStatusViaWiFi;
                break;
            default:
                netWorkStatus = LJNetWorkingStatusUnknown;
                break;
        }
        
    }];
    
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (requestTaskPool == nil) {
            requestTaskPool = [NSMutableArray array];
            
        }
    });
    
    return requestTaskPool;
}

+ (LJURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                   progressBlock:(LJDownLoadProgress)progressBlock
                     succesBlock:(LJReponseSuccessBlock)succesBlock
                       failBlcok:(LJReponseErrorBlock)errorBlcok  {
    __block LJURLSessionTask *session = nil  ;
    AFHTTPSessionManager *manager = [self initManager] ;
    if (netWorkStatus == LJNetWorkingStatusNotReachable) {
        if (errorBlcok) {
            errorBlcok([NSError errorWithDomain:@"error" code:-9999 userInfo:@{NSLocalizedDescriptionKey:LJ_ERROR_INFOMATION}]) ;
            return session ;
        }
    }
    id responseObj = [[LJCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    
    if (responseObj && cache) {
        if (succesBlock) { succesBlock(responseObj);
        }
    }
    
    session  = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount,downloadProgress.totalUnitCount) ;
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (succesBlock) {
            succesBlock(responseObject) ;
        }
        if (cache) {
            [[LJCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
        }
        [[self allTasks] removeObject:session] ;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (errorBlcok) {
            errorBlcok(error) ;
        }
        [[self allTasks] removeObject:session] ;
        
        
    }];
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        [session cancel] ;
        return  session  ;
    }else {
        //无论是否有旧请求，先执行取消旧请求，反正都需要刷新请求
        LJURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
    
    
    return  session ;
}

+ (LJURLSessionTask *)postWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                    progressBlock:(LJDownLoadProgress)progressBlock
                      succesBlock:(LJReponseSuccessBlock)succesBlock
                        failBlcok:(LJReponseErrorBlock)errorBlcok  {
    
    __block LJURLSessionTask *session = nil  ;
    AFHTTPSessionManager *manager = [self initManager] ;
    if (netWorkStatus == LJNetWorkingStatusNotReachable) {
        if (errorBlcok) {
            errorBlcok([NSError errorWithDomain:@"error" code:-9999 userInfo:@{NSLocalizedDescriptionKey:LJ_ERROR_INFOMATION}]) ;
            return session ;
        }
    }
    id responseObj = [[LJCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    
    if (responseObj && cache) {
        if (succesBlock) { succesBlock(responseObj);
        }
    }
    
    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            progressBlock(uploadProgress.completedUnitCount,uploadProgress.totalUnitCount) ;
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (succesBlock) succesBlock(responseObject);
        
        if (cache) [[LJCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
        
        if ([[self allTasks] containsObject:session]) {
            [[self allTasks] removeObject:session];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) errorBlcok(error);
        [[self allTasks] removeObject:session];
    }] ;
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        [session cancel] ;
        return  session  ;
    }else {
        //无论是否有旧请求，先执行取消旧请求，反正都需要刷新请求
        LJURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
    }
    
    
    return  session ;
}

+ (LJURLSessionTask *)uploadFileWithUrl:(NSString *)url
                               fileData:(NSData *)data
                                   type:(NSString *)type
                                   name:(NSString *)name
                               mimeType:(NSString *)mimeType
                          progressBlock:(LJUploadProgressBlock)progressBlock
                           successBlock:(LJReponseSuccessBlock)successBlock
                              failBlock:(LJReponseErrorBlock)failBlock {
    
    __block LJURLSessionTask *session = nil;
    
    AFHTTPSessionManager *manager = [self initManager];
    
    if (netWorkStatus == LJNetWorkingStatusNotReachable) {
        
        return session;
    }
    
    session = [manager POST:url
                 parameters:nil
  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
      NSString *fileName = nil;
      
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = @"yyyyMMddHHmmss";
      
      NSString *day = [formatter stringFromDate:[NSDate date]];
      
      fileName = [NSString stringWithFormat:@"%@.%@",day,type];
      
      [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
      
  } progress:^(NSProgress * _Nonnull uploadProgress) {
      if (progressBlock) progressBlock (uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
      
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      if (successBlock) successBlock(responseObject);
      [[self allTasks] removeObject:session];
      
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      if (failBlock) failBlock(error);
      [[self allTasks] removeObject:session];
      
  }];
    
    
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
    
}

+ (LJURLSessionTask *)downloadWithUrl:(NSString *)url
                        progressBlock:(LJDownLoadProgress)progressBlock
                         successBlock:(LJReponseSuccessBlock)successBlock
                            failBlock:(LJReponseErrorBlock)failBlock {
    
    NSString *type = nil;
    NSArray *subStringArr = nil;
    __block LJURLSessionTask *session = nil;
    
    NSURL *fileUrl = [[LJCacheManager shareManager] getDownloadDataFromCacheWithRequestUrl:url];
    
    if (fileUrl) {
        if (successBlock) successBlock(fileUrl);
        return nil;
    }
    
    if (url) {
        subStringArr = [url componentsSeparatedByString:@"."];
        if (subStringArr.count > 0) {
            type = subStringArr[subStringArr.count - 1];
        }
    }
    
    AFHTTPSessionManager *manager = [self initManager];
    //响应内容序列化为二进制
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    session = [manager GET:url
                parameters:nil
                  progress:^(NSProgress * _Nonnull downloadProgress) {
                      if (progressBlock) progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                      
                  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      if (successBlock) {
                          NSData *dataObj = (NSData *)responseObject;
                          
                          [[LJCacheManager shareManager] storeDownloadData:dataObj requestUrl:url];
                          
                          NSURL *downFileUrl = [[LJCacheManager shareManager] getDownloadDataFromCacheWithRequestUrl:url];
                          
                          successBlock(downFileUrl);
                      }
                      
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      if (failBlock) {
                          failBlock (error);
                      }
                  }];
    
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
    
    
}

#pragma mark privite method
+ (void)setupTimeout:(NSTimeInterval)timeout {
    requestTimeOut = timeout;
}

+ (void)cancleAllRequest {
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(LJURLSessionTask  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[LJURLSessionTask class]]) {
                [obj cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (!url) return;
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(LJURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[LJURLSessionTask class]]) {
                if ([obj.currentRequest.URL.absoluteString hasSuffix:url]) {
                    [obj cancel];
                    *stop = YES;
                }
            }
        }];
    }
}

+ (void)configHttpHeader:(NSDictionary *)httpHeader {
    headersDictionarys = httpHeader;
}

+ (NSArray *)currentRunningTasks {
    return [[self allTasks] copy];
}

@end




@implementation LJNetWorking (cache)
+ (NSUInteger)totalCacheSize {
    return [[LJCacheManager shareManager] totalCacheSize];
}

+ (NSUInteger)totalDownloadDataSize {
    return [[LJCacheManager shareManager] totalDownloadDataSize];
}

+ (void)clearDownloadData {
    [[LJCacheManager shareManager] clearDownloadData];
}

+ (NSString *)getDownDirectoryPath {
    return [[LJCacheManager shareManager] getDownDirectoryPath];
}

+ (NSString *)getCacheDiretoryPath {
    
    return [[LJCacheManager shareManager] getCacheDiretoryPath];
}

+ (void)clearTotalCache {
    [[LJCacheManager shareManager] clearTotalCache];
}

@end


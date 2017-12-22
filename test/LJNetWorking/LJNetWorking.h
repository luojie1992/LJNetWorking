//
//  LJNetWorking.h
//  LJNetWorking
//
//  Created by jie jie on 2017/12/22.
//  Copyright © 2017年 jie jie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 网络状态

 - LJNetWorkingStatusUnknown: 未知网络
 - LJNetWorkingStatusNotReachable: 无法连接
 - LJNetWorkingStatusViaWWAN: WWAN网络
 - LJNetWorkingStatusViaWiFi: WiFi网络
 */
typedef NS_ENUM(NSInteger , LJNetWorkingStatus) {
    LJNetWorkingStatusUnknown  = 0  ,
    LJNetWorkingStatusNotReachable = 1  ,
    LJNetWorkingStatusViaWWAN = 2,
    LJNetWorkingStatusViaWiFi = 3
};

typedef NSURLSessionTask LJURLSessionTask;

/**
 成功会调

 @param response 成功返回数据
 */
typedef void(^LJReponseSuccessBlock)(id response);

/**
 失败回调

 @param error 失败后返回的信息
 */
typedef void(^LJReponseErrorBlock)(NSError *error);

typedef void(^LJDownLoadProgress)(int64_t bytesRead,int64_t totalBytes);

typedef void(^LJUploadProgressBlock)(int64_t bytesWritten,
                                     int64_t totalBytes);

typedef void(^LJDownLoadSuccessBlock)(NSURL *url);






@interface LJNetWorking : NSObject

+ (NSArray *)currentRunningTasks ;

+ (void)configHttpHeader:(NSDictionary *)httpHeader ;

+ (void)cancleRequestWithURL:(NSString *)url ;

+ (void)cancleAllRequest ;

+ (void)setUpTimeOut:(NSTimeInterval)timeOut;

+ (NSMutableArray *)allTasks ;

/**
 get请求

 @param url 请求url
 @param refresh 是否刷新请求
 @param cache 是否从缓存拿数据
 @param params 拼接参数
 @param succesBlock 成功回掉
 @param errorBlcok 失败回掉
 @return 返回请求对象
 */
+ (LJURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                   progressBlock:(LJDownLoadProgress)progressBlock
                     succesBlock:(LJReponseSuccessBlock)succesBlock
                       failBlcok:(LJReponseErrorBlock)errorBlcok ;


/**
 *  POST请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          解释同上
 *  @param params           拼接参数
 *  @param progressBlock    进度回调
 *  @param succesBlock     成功回调
 *  @param errorBlcok        失败回调
 *
 *  @return 返回的对象中可取消请求
 */

+ (LJURLSessionTask *)postWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                     progressBlock:(LJDownLoadProgress)progressBlock
                      succesBlock:(LJReponseSuccessBlock)succesBlock
                        failBlcok:(LJReponseErrorBlock)errorBlcok ;



/**
 *  文件上传
 *
 *  @param url              上传文件接口地址
 *  @param data             上传文件数据
 *  @param type             上传文件类型
 *  @param name             上传文件服务器文件夹名
 *  @param mimeType         mimeType
 *  @param progressBlock    上传文件路径
 *    @param successBlock     成功回调
 *    @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (LJURLSessionTask *)uploadFileWithUrl:(NSString *)url
                               fileData:(NSData *)data
                                   type:(NSString *)type
                                   name:(NSString *)name
                               mimeType:(NSString *)mimeType
                          progressBlock:(LJUploadProgressBlock)progressBlock
                           successBlock:(LJReponseSuccessBlock)successBlock
                              failBlock:(LJReponseErrorBlock)failBlock;

+ (LJURLSessionTask *)downloadWithUrl:(NSString *)url
                        progressBlock:(LJDownLoadProgress)progressBlock
                         successBlock:(LJReponseSuccessBlock)successBlock
                            failBlock:(LJReponseErrorBlock)failBlock;

@end


@interface LJNetWorking (cache)
/**
 *  获取缓存目录路径
 *
 *  @return 缓存目录路径
 */
+ (NSString *)getCacheDiretoryPath;

/**
 *  获取下载目录路径
 *
 *  @return 下载目录路径
 */
+ (NSString *)getDownDirectoryPath;

/**
 *  获取缓存大小
 *
 *  @return 缓存大小
 */
+ (NSUInteger)totalCacheSize;

/**
 *  清除所有缓存
 */
+ (void)clearTotalCache;

/**
 *  获取所有下载数据大小
 *
 *  @return 下载数据大小
 */
+ (NSUInteger)totalDownloadDataSize;

/**
 *  清除下载数据
 */
+ (void)clearDownloadData;

@end

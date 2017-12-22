//
//  LJLRUManager.h
//  LJNetWorking
//
//  Created by jie jie on 2017/12/22.
//  Copyright © 2017年 jie jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJLRUManager : NSObject


/**
 *  当前队列的情况
 */
@property (nonatomic, copy, readonly)NSArray *currentQueue;

+ (LJLRUManager *)shareManager;

/**
 *  添加新的结点
 *
 *  @param filename 文件名字
 */
- (void)addFileNode:(NSString *)filename;

/**
 *  调整结点位置，一般用于命中缓存时
 *
 *  @param filename 文件名字
 */
- (void)refreshIndexOfFileNode:(NSString *)filename;

/**
 *  删除最近最久未使用的缓存
 *
 *  @param time 缓存时间
 *
 *  @return 删除结点的文件名列表
 */
- (NSArray *)removeLRUFileNodeWithCacheTime:(NSTimeInterval) time;

@end

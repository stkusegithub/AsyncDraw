//
//  ADQueue.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADQueue : NSObject

/**
 对应索引
 */
@property (nonatomic, assign) NSUInteger index;
/**
 队列
 */
@property (nonatomic, strong, readonly) dispatch_queue_t queue;
/**
 异步执行次数
 */
@property (nonatomic, assign) NSUInteger asyncCount;

@end

NS_ASSUME_NONNULL_END

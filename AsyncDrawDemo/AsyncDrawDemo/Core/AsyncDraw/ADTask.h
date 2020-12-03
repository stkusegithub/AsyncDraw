//
//  ADTask.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ADTask;
typedef ADTask *_Nonnull(^ADTaskBlock)(id target, SEL selector);

@interface ADTask : NSObject

/**
 初始化
 
 ADTaskBlock：target-ui对象，selector-调用方法
 */
+ (ADTaskBlock)init;
/**
 执行任务
 */
- (void)excute;

@end

NS_ASSUME_NONNULL_END

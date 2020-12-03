//
//  ADManager.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/15.
//

#import <Foundation/Foundation.h>

#import "ADQueue.h"
#import "ADTask.h"
#import "ADOperation.h"

typedef enum {
    ADManagerAsyncDrawTypeText = 1,// 文本
    ADManagerAsyncDrawTypeImage,// 图片
}ADManagerAsyncDrawType;

NS_ASSUME_NONNULL_BEGIN

@interface ADManager : NSObject

+ (instancetype)shareInstance;
/**
 添加任务
 @param target layer对象
 @param selector 执行方法
 */
- (void)ad_addTaskWith:(id)target selector:(SEL)selector;
/**
 获取最优队列执行异步操作
 */
- (ADQueue *)ad_getExecuteTaskQueue;
/**
 取消或完成任务
 @param q 队列存储对象
 */
- (void)ad_finishTask:(ADQueue *)q;
/**
 异步下载图片
 @param url 图片地址
 @param completedBlock 完成回调
 */
- (void)ad_setImageWithURL:(NSURL *)url target:(id)target completed:(void (^)(UIImage * _Nullable image, NSError * _Nullable error))completedBlock;
@end

NS_ASSUME_NONNULL_END

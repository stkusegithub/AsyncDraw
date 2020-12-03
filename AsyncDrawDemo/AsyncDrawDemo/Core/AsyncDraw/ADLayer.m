//
//  ADLayer.m
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/14.
//

#import "ADLayer.h"
#import "ADManager.h"

typedef enum {
    ADLayerStatusCancel = 0,// 绘制取消
    ADLayerStatusDrawing,// 正在绘制
}ADLayerStatus;

@interface ADLayer ()

/**
 维护线程安全的绘制状态
 */
@property (atomic, assign) ADLayerStatus status;
@end

@implementation ADLayer

#pragma mark - Override

- (void)setNeedsDisplay {
    // 收到新的绘制请求时，同步正在绘制的线程本次取消
    self.status = ADLayerStatusCancel;
    
    [super setNeedsDisplay];
}

- (void)display {
    // 标记正在绘制
    self.status = ADLayerStatusDrawing;
    
    if ([self.delegate respondsToSelector:@selector(asyncDrawLayer:inContext:canceled:)]) {
        [self asyncDraw];
    } else {
        [super display];
    }
}

#pragma mark - Pri MD

- (BOOL)canceled {
    return self.status == ADLayerStatusCancel;
}

- (void)asyncDraw {
    
    __block ADQueue *q = [[ADManager shareInstance] ad_getExecuteTaskQueue];
    __block id<ADLayerDelegate> delegate = (id<ADLayerDelegate>)self.delegate;
    
    dispatch_async(q.queue, ^{
        // 重绘取消
        if ([self canceled]) {
            [[ADManager shareInstance] ad_finishTask:q];
            return;
        }
        // 生成上下文context
        CGSize size = self.bounds.size;
        BOOL opaque = self.opaque;
        CGFloat scale = [UIScreen mainScreen].scale;
        CGColorRef backgroundColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (opaque && context) {
            CGContextSaveGState(context); {
                if (!backgroundColor || CGColorGetAlpha(backgroundColor) < 1) {
                    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                    CGContextFillPath(context);
                }
                if (backgroundColor) {
                    CGContextSetFillColorWithColor(context, backgroundColor);
                    CGContextAddRect(context, CGRectMake(0, 0, size.width * scale, size.height * scale));
                    CGContextFillPath(context);
                }
            } CGContextRestoreGState(context);
            CGColorRelease(backgroundColor);
        } else {
            CGColorRelease(backgroundColor);
        }
        // 使用context绘制
        [delegate asyncDrawLayer:self inContext:context canceled:[self canceled]];
        // 重绘取消
        if ([self canceled]) {
            [[ADManager shareInstance] ad_finishTask:q];
            UIGraphicsEndImageContext();
            return;
        }
        // 获取image
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 结束任务
        [[ADManager shareInstance] ad_finishTask:q];
        // 重绘取消
        if ([self canceled]) {
            return;
        }
        // 主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contents = (__bridge id)(image.CGImage);
        });
        
    });
}

@end

//
//  ADLayer.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/14.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@class ADLayer;

NS_ASSUME_NONNULL_BEGIN

@protocol ADLayerDelegate <CALayerDelegate>
/**
 外部ui遵循此协议进行内容绘制
 
 @param layer 图层
 @param ctx 图形上下文
 @param canceled 是否已取消
 */
- (void)asyncDrawLayer:(ADLayer *)layer inContext:(CGContextRef __nullable)ctx canceled:(BOOL)canceled;
@end

@interface ADLayer : CALayer

@end

NS_ASSUME_NONNULL_END

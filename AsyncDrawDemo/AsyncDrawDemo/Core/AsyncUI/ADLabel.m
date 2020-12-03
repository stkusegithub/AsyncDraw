//
//  ADLabel.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/14.
//

#import "ADLabel.h"
#import "ADLayer.h"
#import "ADManager.h"

#import <CoreText/CoreText.h>

@interface ADLabel () <ADLayerDelegate>
{
    UIColor *_backgroundColor;
    NSString *_text;
    UIFont *_font;
    UIColor *_textColor;
}
@end

@implementation ADLabel

#pragma mark - Pub MD

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    
    [[ADManager shareInstance] ad_addTaskWith:self selector:@selector(asyncDraw)];
}

- (void)setText:(NSString *)text {
    _text = text;

    [[ADManager shareInstance] ad_addTaskWith:self selector:@selector(asyncDraw)];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    
    [[ADManager shareInstance] ad_addTaskWith:self selector:@selector(asyncDraw)];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    [[ADManager shareInstance] ad_addTaskWith:self selector:@selector(asyncDraw)];
}

- (void)setParagraphStyle:(NSParagraphStyle *)paragraphStyle {
    _paragraphStyle = paragraphStyle;
    
    [[ADManager shareInstance] ad_addTaskWith:self selector:@selector(asyncDraw)];
}

//- (void)setCornerRadius:(CGFloat)cornerRadius {
//    _cornerRadius = cornerRadius;
//
//    [[ADManager shareInstance] ad_addTaskWith:self selector:@selector(setNeedsDisplay)];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [[ADManager shareInstance] ad_addTaskWith:self selector:@selector(asyncDraw)];
}
// 绑定异步绘制layer
+ (Class)layerClass {
    return ADLayer.class;
}

#pragma mark - Pri MD

- (void)asyncDraw {
    [self.layer setNeedsDisplay];
}

#pragma mark - ADLayerDelegate

- (void)layerWillDraw:(CALayer *)layer {
}

- (void)asyncDrawLayer:(ADLayer *)layer inContext:(CGContextRef __nullable)ctx canceled:(BOOL)canceled {
    
    if (canceled) {
        NSLog(@"异步绘制取消~");
        return;
    }
    
    UIColor *backgroundColor = _backgroundColor;
    NSString *text = _text;
    UIFont *font = _font;
    UIColor *textColor = _textColor;
    CGSize size = layer.bounds.size;
    
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, size.height);
    CGContextScaleCTM(ctx, 1, -1);
    
    // 绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
    
    // 绘制的内容属性字符串
    NSDictionary *attributes = @{NSFontAttributeName : font,
                                 NSForegroundColorAttributeName: textColor,
                                 NSBackgroundColorAttributeName : backgroundColor,
                                 NSParagraphStyleAttributeName : self.paragraphStyle ?:[NSParagraphStyle new]
                                 };
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    
    // 使用NSMutableAttributedString创建CTFrame
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrStr);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrStr.length), path, NULL);
    CFRelease(framesetter);
    CGPathRelease(path);
    
    // 使用CTFrame在CGContextRef上下文上绘制
    CTFrameDraw(frame, ctx);
    CFRelease(frame);
    
    // 如果存在圆角则进行绘制>>暂不支持
//    if (self.cornerRadius > 0) {
//        CGRect bounds = CGRectMake(0, 0, size.width, size.height);
//
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:bounds];
//        UIBezierPath *cornerPath = [[UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)] bezierPathByReversingPath];
//        [path appendPath:cornerPath];
//        //裁剪出圆角路径
//        CGContextAddPath(context, path.CGPath);
//        //用背景色填充路径
//        [backgroundColor set];
//        CGContextFillPath(context);
//    }
}

@end

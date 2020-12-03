//
//  ADImageView.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/13.
//

#import <UIKit/UIKit.h>

@class ADImageView;

@protocol ADImageViewDelegate <NSObject>

- (void)ADImageViewClicked:(ADImageView *)imageView;

@end

@interface ADImageView : UIImageView

@property (nonatomic, weak) id<ADImageViewDelegate> delegate;

@property (nonatomic, copy) void(^imageViewClickBlock)(ADImageView *image);

// 普通图片(渐变，未加载图片没背景色)
@property (nonatomic, strong) NSString *url;
// 正在展示(在可显cell上)
@property (nonatomic, assign) BOOL isDisplay;

// 外部传入占位图（有渐变，加载默认图）
- (void)setUrl:(NSString *)url placeholderName:(NSString *)placeholderName;

@end

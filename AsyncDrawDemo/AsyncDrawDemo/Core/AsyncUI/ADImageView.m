//
//  ADImageView.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/13.
//

#import "ADImageView.h"
#import "ADManager.h"

@implementation ADImageView

#pragma mark - Public Methods

- (void)setImage:(UIImage *)image {
    if (self.isDisplay) {
        [super setImage:image];
    } else {
        NSLog(@"超出可视范围，放弃渲染～");
    }
}

- (void)setUrl:(NSString *)url {
    _url = url;
    
    [[ADManager shareInstance] ad_setImageWithURL:[NSURL URLWithString:self.url] target:self completed:^(UIImage * _Nullable image, NSError * _Nullable error) {
        if (image) {
            self.image = image;
        }
    }];
}

- (void)setUrl:(NSString *)url placeholderName:(NSString *)placeholderName {
    _url = url;
    
//    UIImage *placeholderImage = [UIImage imageNamed:placeholderName];
    // 待完善
}

#pragma mark - Override

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGrAction:)];
        [self addGestureRecognizer:tapGr];
    }
    return self;
}

#pragma mark - Pri Property

- (void)tapGrAction:(UITapGestureRecognizer *)gr {
    
    if (self.imageViewClickBlock) {
        self.imageViewClickBlock(self);
    }
    
    if ([self.delegate respondsToSelector:@selector(ADImageViewClicked:)]) {
        [self.delegate ADImageViewClicked:self];
    }
}

@end

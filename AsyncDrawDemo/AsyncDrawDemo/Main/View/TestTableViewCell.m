//
//  TestTableViewCell.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/14.
//

#define kAsyncDraw true // 异步开关
#define kOnlyShowText true // 仅显示文本进行测试

#define kCommonSpace 10.0
#define kTitleHeight 30.0
#define kImageHeight 200.0

#import "TestTableViewCell.h"
#import "TestModel.h"
#import "iConstant.h"

#ifdef kAsyncDraw
#import "ADImageView.h"
#import "ADLabel.h"
#endif

@interface TestTableViewCell ()

#ifdef kAsyncDraw
@property (nonatomic, weak) ADImageView *bigImageView;
@property (nonatomic, weak) ADLabel *titleLabel;
@property (nonatomic, weak) ADLabel *contentLabel;
#else
@property (nonatomic, weak) UIImageView *bigImageView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *contentLabel;
#endif

@end

@implementation TestTableViewCell

#pragma mark - Pub MD

// 缓存高度，减少cpu计算
+ (CGFloat)heightWith:(TestModel *)model {
    static NSCache *cache = nil;
    if (!cache) {
        cache = [NSCache new];
        cache.name = @"TestTableViewCellHeightCache";
        cache.countLimit = 10000;
    }
    
    NSString *content = model.content ?: @"";
    NSString *key = [NSString stringWithFormat:@"%@Key-%ld", cache.name, (long)model.hash];
    NSValue *value = [cache objectForKey:key];
    if (value) { return value.CGSizeValue.height; }
    
    /// 计算高度进行缓存
    CGSize contentSize = [content boundingRectWithSize:CGSizeMake(ScreenWidth - kCommonSpace * 2 , MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [self textFont], NSParagraphStyleAttributeName : [self paragraphStyle]} context:nil].size;
    
    CGSize totalSize = CGSizeMake(1.0, contentSize.height + kCommonSpace * 3 + kTitleHeight + kImageHeight);
    
    [cache setObject:@(totalSize) forKey:key];
    
    return totalSize.height;
}

- (void)setIsDisplay:(BOOL)isDisplay {
    _isDisplay = isDisplay;
    
#ifdef kAsyncDraw
    self.bigImageView.isDisplay = isDisplay;
#endif
}

- (void)assignModel:(TestModel *)model {
    self.titleLabel.text = model.title;

#ifdef kAsyncDraw
    
    self.contentLabel.text = model.content;
#ifndef kOnlyShowText
    self.bigImageView.url = model.imageURL;
#endif
    
#else
    NSDictionary *attributes = @{NSFontAttributeName : self.contentLabel.font,
                                 NSParagraphStyleAttributeName : [self.class paragraphStyle] ?:[NSParagraphStyle new]
                                 };
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:model.content attributes:attributes];
    self.contentLabel.attributedText = attrStr;
    
#ifndef kOnlyShowText
    NSURL *imgUrl = [NSURL URLWithString:model.imageURL];
    NSData *imgData = [NSData dataWithContentsOfURL:imgUrl options:(NSDataReadingMappedIfSafe) error:nil];
    self.bigImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bigImageView.image = [UIImage imageWithData:imgData];
#endif
    
#endif
}

#pragma mark - Overide

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self loadSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat itemWidth = ScreenWidth - kCommonSpace * 2;
    CGFloat totalHeight = self.contentView.bounds.size.height;
    
    self.titleLabel.frame = CGRectMake(kCommonSpace, kCommonSpace, itemWidth, kTitleHeight);
    self.bigImageView.frame = CGRectMake(kCommonSpace, CGRectGetMaxY(self.titleLabel.frame), itemWidth, kImageHeight);
    self.contentLabel.frame = CGRectMake(kCommonSpace, CGRectGetMaxY(self.bigImageView.frame) + kCommonSpace, itemWidth, totalHeight - (CGRectGetMaxY(self.bigImageView.frame) + kCommonSpace * 2));
}

#pragma mark - Pri MD

+ (UIFont *)textFont {
    return [UIFont systemFontOfSize:14];
}

+ (NSParagraphStyle *)paragraphStyle {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [paragraphStyle setLineSpacing:5.0];
    return paragraphStyle;
}

- (void)loadSubViews {

#ifdef kAsyncDraw
    ADLabel *titleLabel = [[ADLabel alloc] init];
    
    ADImageView *imgView = [[ADImageView alloc] init];
    
    ADLabel *contentLabel = [[ADLabel alloc] init];
    contentLabel.paragraphStyle = [self.class paragraphStyle];
#else
    UILabel *titleLabel = [[UILabel alloc] init];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    
    UILabel *contentLabel = [[UILabel alloc] init];
#endif
    
    titleLabel.backgroundColor = [UIColor yellowColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    imgView.layer.cornerRadius = 8.0;
    imgView.layer.masksToBounds = YES;
    [self.contentView addSubview:imgView];
    self.bigImageView = imgView;
    
    contentLabel.numberOfLines = 0;
    contentLabel.backgroundColor = [UIColor yellowColor];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:contentLabel];
    self.contentLabel = contentLabel;
}

@end

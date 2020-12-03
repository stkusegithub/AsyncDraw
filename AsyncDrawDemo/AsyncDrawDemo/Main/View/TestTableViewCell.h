//
//  TestTableViewCell.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/14.
//

#import <UIKit/UIKit.h>

@class TestModel;

NS_ASSUME_NONNULL_BEGIN

@interface TestTableViewCell : UITableViewCell

// 正在展示
@property (nonatomic, assign) BOOL isDisplay;

+ (CGFloat)heightWith:(TestModel *)model;
- (void)assignModel:(TestModel *)model;
@end

NS_ASSUME_NONNULL_END

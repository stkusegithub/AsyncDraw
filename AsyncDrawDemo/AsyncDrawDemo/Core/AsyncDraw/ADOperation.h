//
//  ADOperation.h
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADOperation : NSBlockOperation

@property (nonatomic, strong) NSSet<id> *targetSet;

- (void)addTarget:(id)target;
- (void)removeAllTargets;
@end

NS_ASSUME_NONNULL_END

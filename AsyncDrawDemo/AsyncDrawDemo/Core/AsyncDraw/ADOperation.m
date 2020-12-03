//
//  ADOperation.m
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/21.
//

#import "ADOperation.h"

@interface ADOperation ()

@property (nonatomic, strong) NSMutableSet<id> *targetInnerSet;
@end

@implementation ADOperation

- (void)addTarget:(id)target {
    [self.targetInnerSet addObject:target];
}

- (void)removeAllTargets {
    [self.targetInnerSet removeAllObjects];
}

- (NSSet<id> *)targetSet {
    return self.targetInnerSet;
}

- (NSMutableSet<id> *)targetInnerSet {
    if (!_targetInnerSet) {
        _targetInnerSet = [NSMutableSet set];
    }
    return _targetInnerSet;
}
@end

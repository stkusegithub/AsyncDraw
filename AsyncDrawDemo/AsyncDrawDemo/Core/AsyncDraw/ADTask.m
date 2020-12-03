//
//  ADTask.m
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/14.
//

#import "ADTask.h"

@interface ADTask ()

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@end

@implementation ADTask

#pragma mark - Pub MD

//1. 创建一个ADTask的对象
+ (ADTaskBlock)init {
    return ^ADTask *(id target, SEL selector) {
        if (!target || !selector) return nil;
        ADTask *t = [ADTask new];
        t.target = target;
        t.selector = selector;
        return t;
    };
}

- (void)excute {
    ((void (*)(id, SEL))[self.target methodForSelector:self.selector])(self.target, self.selector);
}

#pragma mark - Overide

// 由于使用NSMutableSet存储自定义对象，而NSMutableSet使用HashMap实现存储结构的。hashmap中需要先寻找hash索引，以便快速的找到对应存储的对象。
- (NSUInteger)hash {
    long v1 = (long)((void *)_selector);
    long v2 = (long)_target;
    // 位异或处理，即相同_selector、_target则hash值相同，在set中只存储一份事务
    return v1 ^ v2;
}
// 在hashmap中寻找对象的时候，当找到hash索引后，如果对应位置没有值，则直接存储，否则需要判断对象是否相等，如果相等则放弃存储，否则指定位置使用链表或者再次寻址。
- (BOOL)isEqual:(id)object {
    if (self == object) return YES;
    if (![object isMemberOfClass:self.class]) return NO;
    ADTask *other = object;
    return other.selector == _selector && other.target == _target;
}

@end

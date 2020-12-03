//
//  ADQueue.m
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/15.
//

#import "ADQueue.h"

#define kADQueueSerial "kADQueueSerial"

@implementation ADQueue {
    dispatch_queue_t _queue;
}

#pragma mark - Pub MD

- (dispatch_queue_t)queue {
    return _queue;
}

#pragma mark - Overide

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
        _queue = dispatch_queue_create(kADQueueSerial, attr);
    }
    return self;
}

@end

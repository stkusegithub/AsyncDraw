//
//  ADTableView.m
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/22.
//

#import "ADTableView.h"

@implementation ADTableView

- (NSMutableArray<id> *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end

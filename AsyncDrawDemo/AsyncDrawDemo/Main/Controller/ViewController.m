//
//  ViewController.m
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/9.
//

#import "ViewController.h"
#import "ADTableView.h"
#import "TestTableViewCell.h"
#import "YYFPSLabel.h"
#import "iConstant.h"
#import "TestModel.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ADTableView *tableView;
@property (nonatomic, strong) YYFPSLabel *fpsLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loaddataArr];
}

#pragma mark - Private

- (void)loadSubViews {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.fpsLabel];
}

- (void)loaddataArr {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *appendingStr = @"😊😄😂😭💗🌹😳😫🤮😛等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等😊😄😂😭💗🌹😳😫🤮😛等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等😊😄😂😭💗🌹😳😫🤮😛等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等😊😄😂😭💗🌹😳😫🤮😛等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等😊😄😂😭💗🌹😳😫🤮😛等等😊😄😂😭💗🌹😳😫🤮😛等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等等😊😄😂😭💗🌹😳😫🤮😛";
        for (int i = 0; i < 1000; i ++) {
            TestModel *m = [TestModel new];
            m.title = [NSString stringWithFormat:@"紧急重要特别严重敏感新闻事件播报>>>%d", i];
            m.imageURL = kPictureTest;
            m.content = [NSString stringWithFormat:@"此demo主要封装了异步绘制框架，针对大量文本的UILabel进行异步绘制，UIImageView异步渲染缓存图片，减轻主线程压力；并进行cell动态文本高度计算缓存，减少CPU计算，进而提升UITableView的流畅性，保持屏幕刷新帧率在60fps，具体可以应用到的场景有新闻图文混排列表高频消息列表%@......", [appendingStr substringToIndex:arc4random() % appendingStr.length]];
            [self.tableView.dataArr addObject:m];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView 被调用了～");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableView.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TestTableViewCell class])];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    TestTableViewCell *testCell = (TestTableViewCell *)cell;
    testCell.isDisplay = YES;
    [testCell assignModel:self.tableView.dataArr[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    TestTableViewCell *testCell = (TestTableViewCell *)cell;
    testCell.isDisplay = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [TestTableViewCell heightWith:self.tableView.dataArr[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Lazy property

- (ADTableView *)tableView {
    if (!_tableView) {
        _tableView = [[ADTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[TestTableViewCell class] forCellReuseIdentifier:NSStringFromClass([TestTableViewCell class])];
    }
    return _tableView;
}

- (YYFPSLabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [YYFPSLabel new];
        _fpsLabel.frame = CGRectMake(10.0, (ScreenHeight - 40.0) / 2, 60.0, 40.0);
    }
    return _fpsLabel;
}

@end

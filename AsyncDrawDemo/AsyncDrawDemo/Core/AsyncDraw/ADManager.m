//
//  ADManager.m
//  AsyncDrawDemo
//
//  Created by Stk on 2020/11/15.
//

#import <UIKit/UIKit.h>
#import "ADManager.h"

#define kMAX_QUEUE_COUNT 6
#define kMAX_OPERATION_COUNT 6
#define kERROR_DOMAIN @"com.stk.AsyncDraw.imageLoad"

@interface ADManager () <NSCopying>

/**
 文本绘制的队列数组
 */
@property (nonatomic, strong) NSMutableArray<ADQueue *> *queueArr;
/**
 限制最大串行队列数
 */
@property (nonatomic, assign) NSUInteger limitQueueCount;

/**
 图片绘制的队列
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;
/**
 图片下载任务字典
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *,ADOperation *> *operationDict;
/**
 图片缓存字典
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *,NSData *> *imageDataDict;


@end

static id _instance;
/**
 runloop回调，并发执行异步绘制任务
 */
static NSMutableSet<ADTask *> *_taskSet = nil;
static void ADRunLoopCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (_taskSet.count == 0) return;
    NSSet *currentSet = _taskSet;
    _taskSet = [NSMutableSet set];
    [currentSet enumerateObjectsUsingBlock:^(ADTask *task, BOOL *stop) {
        [task excute];
    }];
}

@implementation ADManager

#pragma mark - Pub MD

+ (instancetype)shareInstance {
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       _instance = [[self alloc] init];
   });
   return _instance;
}

#pragma mark - 处理文本

- (void)ad_addTaskWith:(id)target selector:(SEL)selector {
    if (!target || !selector) return;
    ADTask *task = ADTask.init(target, selector);
    [_taskSet addObject:task];
}

- (ADQueue *)ad_getExecuteTaskQueue {
    // 1、创建对应数量串行队列处理并发任务，并行队列线程数无法控制
    if (self.queueArr.count < self.limitQueueCount) {
        ADQueue *q = [[ADQueue alloc] init];
        q.index = self.queueArr.count;
        [self.queueArr addObject:q];
        q.asyncCount += 1;
        NSLog(@"queue[%ld]-asyncCount:%ld", (long)q.index, (long)q.asyncCount);
        return q;
    }
    
    // 2、当队列数已达上限，择优获取异步任务数最少的队列
    NSUInteger minAsync = [[self.queueArr valueForKeyPath:@"@min.asyncCount"] integerValue];
    __block ADQueue *q = nil;
    [self.queueArr enumerateObjectsUsingBlock:^(ADQueue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.asyncCount <= minAsync) {
            *stop = YES;
            q = obj;
        }
    }];
    q.asyncCount += 1;
    NSLog(@"queue[%ld]-excute-count:%ld", (long)q.index, (long)q.asyncCount);
    return q;
}

- (void)ad_finishTask:(ADQueue *)q {
    q.asyncCount -= 1;
    if (q.asyncCount < 0) {
        q.asyncCount = 0;
    }
    NSLog(@"queue[%ld]-done-count:%ld", (long)q.index, (long)q.asyncCount);
}

#pragma mark - 处理图片

- (void)ad_setImageWithURL:(NSURL *)url target:(id)target completed:(void (^)(UIImage * _Nullable image, NSError * _Nullable error))completedBlock {
    if (!url) {
        if (completedBlock) {
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"Expected URL to be a image URL", @"AsyncDraw", nil)};
            NSError *error = [[NSError alloc] initWithDomain:kERROR_DOMAIN code:NSURLErrorBadURL userInfo:userInfo];
            completedBlock(nil, error);
        }
        return;
    }
    
    // 1、缓存中读取
    NSString *imageKey = url.absoluteString;
    NSData *imageData = self.imageDataDict[imageKey];
    if (imageData) {
        UIImage *image = [UIImage imageWithData:imageData];
        if (completedBlock) {
            completedBlock(image, nil);
        }
    } else {
        
        // 2、沙盒中读取
        NSString *imagePath = [NSString stringWithFormat:@"%@/Library/Caches/%@", NSHomeDirectory(), url.lastPathComponent];
        imageData = [NSData dataWithContentsOfFile:imagePath];
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            if (completedBlock) {
                completedBlock(image, nil);
            }
        } else {
            
            // 3、下载并缓存写入沙盒
            ADOperation *operation = [self ad_downloadImageWithURL:url toPath:imagePath completed:completedBlock];
            // 4、添加图片渲染对象
            [operation addTarget:target];
        }
    }
}

- (ADOperation *)ad_downloadImageWithURL:(NSURL *)url toPath:(NSString *)imagePath completed:(void (^)(UIImage * _Nullable image, NSError * _Nullable error))completedBlock  {
    NSString *imageKey = url.absoluteString;
    
    ADOperation *operation = self.operationDict[imageKey];
    if (!operation) {
        operation = [ADOperation blockOperationWithBlock:^{
            NSLog(@"AsyncDraw image loading~");
            NSData *newImageData = [NSData dataWithContentsOfURL:url];
            
            // 下载失败处理
            if (!newImageData) {
                [self.operationDict removeObjectForKey:imageKey];
                
                NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"Failed to load the image", @"AsyncDraw", nil)};
                NSError *error = [[NSError alloc] initWithDomain:kERROR_DOMAIN code:NSURLErrorUnknown userInfo:userInfo];
                if (completedBlock) {
                    completedBlock(nil, error);
                }
                return;
            }
            
            // 缓存图片数据
            [self.imageDataDict setValue:newImageData forKey:imageKey];
        }];
        
        // 设置完成回调
        __block ADOperation *blockOperation = operation;
        [operation setCompletionBlock:^{
            NSLog(@"AsyncDraw image load completed~");
            // 取缓存
            NSData *newImageData = self.imageDataDict[imageKey];
            if (!newImageData) {
                return;
            }
            
            // 返回主线程刷新
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                UIImage *newImage = [UIImage imageWithData:newImageData];
                // 遍历渲染同个图片地址的所有控件
                [blockOperation.targetSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView = (UIImageView *)obj;
                        // ADImageView内部判断“超出可视范围，放弃渲染～”
                        imageView.image = newImage;
                    }
                }];
                [blockOperation removeAllTargets];
            }];
            
            // 写入沙盒
            [newImageData writeToFile:imagePath atomically:YES];
            
            // 移除任务
            [self.operationDict removeObjectForKey:imageKey];
        }];
        
        // 加入队列
        [self.operationQueue addOperation:operation];
        
        // 添加opertion
        [self.operationDict setValue:operation forKey:imageKey];
    }
    
    return operation;
}

#pragma mark - Overide

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       _instance = [super allocWithZone:zone];
   });
   return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
   return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupRunLoopObserver];
    }
    return self;
}

#pragma mark Pri MD

- (void)setupRunLoopObserver {
    // 创建任务集合
    _taskSet = [NSMutableSet set];
    // 获取主线程的runloop
    CFRunLoopRef runloop = CFRunLoopGetMain();
    // 创建观察者，监听即将休眠和退出
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                       kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                       true,      // 重复
                                       0xFFFFFF,  // 设置优先级低于CATransaction(2000000)
                                       ADRunLoopCallBack, NULL);
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}

#pragma mark - Lazy Property

- (NSMutableArray<ADQueue *> *)queueArr {
    if (!_queueArr) {
        _queueArr = [[NSMutableArray alloc] initWithCapacity:kMAX_QUEUE_COUNT];
    }
    return _queueArr;
}

- (NSUInteger)limitQueueCount {
    if (_limitQueueCount == 0) {
        // 获取当前系统处于激活状态的处理器数量
        NSUInteger processorCount = [NSProcessInfo processInfo].activeProcessorCount;
        // 根据处理器的数量和设置的最大队列数来设定当前队列数组的大小
        _limitQueueCount = processorCount > 0 ? (processorCount > kMAX_QUEUE_COUNT ? kMAX_QUEUE_COUNT : processorCount) : 1;
    }
    
    return _limitQueueCount;
}

- (NSOperationQueue *)operationQueue {
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = kMAX_OPERATION_COUNT;
    }
    return _operationQueue;
}

- (NSMutableDictionary<NSString *,ADOperation *> *)operationDict {
    if (!_operationDict) {
        _operationDict = [NSMutableDictionary dictionary];
    }
    return _operationDict;
}

- (NSMutableDictionary<NSString *,NSData *> *)imageDataDict {
    if (!_imageDataDict) {
        _imageDataDict = [NSMutableDictionary dictionary];
    }
    return _imageDataDict;
}

@end

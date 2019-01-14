//
//  RwLockViewController.m
//  iOSLock
//
//  Created by iOS开发T001 on 2019/1/14.
//  Copyright © 2019 iOS开发. All rights reserved.
//

#import "RwLockViewController.h"

@interface RwLockViewController ()

@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, copy) NSString *testStr;

@end

@implementation RwLockViewController{
    NSString *_testStr;
}

@synthesize testStr = _testStr;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataArr addObjectsFromArray:@[@"读写锁"]];
    
    __weak typeof(self) weakSelf = self;
    self.itemOperation = ^(NSIndexPath * _Nonnull indexPath) {
        weakSelf.testStr = @"读写锁";
        NSLog(@"%@",weakSelf.testStr);
    };
}

// 在并发队列里同步读取属性值
- (NSString *)testStr {
    __block NSString *str;
    dispatch_sync(self.syncQueue, ^{
        str = _testStr;
    });
    return str;
}

// 异步写入属性值
- (void)setTestStr:(NSString *)testStr {
    //执行此操作时队列其他操作等待
    //这样可同时有多个线程读取该属性，同一时刻只能有一个线程写值且读线程等到
    dispatch_barrier_async(self.syncQueue, ^{
        _testStr = testStr;
    });
}

- (dispatch_queue_t)syncQueue {
    if (!_syncQueue) {
        _syncQueue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _syncQueue;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

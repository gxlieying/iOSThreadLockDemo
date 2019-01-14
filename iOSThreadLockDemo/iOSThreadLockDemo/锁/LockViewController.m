//
//  LockViewController.m
//  iOSLock
//
//  Created by iOS开发T001 on 2019/1/14.
//  Copyright © 2019 iOS开发. All rights reserved.
//

#import "LockViewController.h"

//执行一次，之后用到，不在定义
#define K_GLOBAL_QUEUE(block) \
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ \
block();\
})

@interface LockViewController ()

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataArr addObjectsFromArray:@[@"synchronize",@"lock",@"条件锁（NSConditionLock）",@"递归锁(recursiveLock)"]];
    __weak typeof(self) weakSelf = self;
    self.itemOperation = ^(NSIndexPath * _Nonnull indexPath) {
        NSString *temp = weakSelf.dataArr[indexPath.row];
        if ([temp isEqualToString:@"synchronize"]) {
            [weakSelf synchronizedAction];
        } else if ([temp isEqualToString:@"lock"]) {
            [weakSelf lockAction];
        } else if ([temp isEqualToString:@"递归锁(recursiveLock)"]) {
            [weakSelf recursiveLockAction];
        } else if ([temp isEqualToString:@"条件锁（NSConditionLock）"]) {
            [weakSelf conditionLockAction];
        }
    };
}

- (void)synchronizedAction {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized (self) {
            for (int i = 0; i <= 3; i++) {
                NSLog(@"执行操作");
                sleep(1);
            }
        }
        
    });
}

- (void)lockAction {
    NSLock *lock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            [lock lock];
            NSLog(@"执行操作");
            sleep(1);
            [lock unlock];
        }
    });
}

/** 条件锁 */
- (void)conditionLockAction {
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:0];
    K_GLOBAL_QUEUE(^{
        for (int i=0;i<3;i++){
            [conditionLock lock];
            NSLog(@"线程 0:%d",i);
            sleep(1);
            [conditionLock unlockWithCondition:i];
        }
    });
    K_GLOBAL_QUEUE(^{
        [conditionLock lock];
        NSLog(@"线程 1");
        [conditionLock unlock];
    });
    K_GLOBAL_QUEUE(^{
        [conditionLock lockWhenCondition:2];
        NSLog(@"线程 2");
        [conditionLock unlockWithCondition:0];
    });
    K_GLOBAL_QUEUE(^{
        [conditionLock lockWhenCondition:1];
        NSLog(@"线程 3");
        [conditionLock unlockWithCondition:2];
    });
    
}

/** 递归锁 */
- (void)recursiveLockAction {
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    K_GLOBAL_QUEUE(^{
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            [lock lock];
            if (value > 0) {
                NSLog(@"加锁层数 %d", value);
                sleep(1);
                RecursiveBlock(--value);
            }
            [lock unlock];
        };
        RecursiveBlock(3);
    });
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

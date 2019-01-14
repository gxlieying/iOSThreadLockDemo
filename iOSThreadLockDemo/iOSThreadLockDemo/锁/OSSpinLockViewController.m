//
//  OSSpinLockViewController.m
//  iOSLock
//
//  Created by iOS开发T001 on 2019/1/14.
//  Copyright © 2019 iOS开发. All rights reserved.
//

#import "OSSpinLockViewController.h"
#import <libkern/OSAtomic.h>

@interface OSSpinLockViewController ()

@end

@implementation OSSpinLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.dataArr addObjectsFromArray:@[@"OSSpinLock(不安全，已弃用)"]];
    
    __weak typeof(self) weakSelf = self;
    self.itemOperation = ^(NSIndexPath * _Nonnull indexPath) {
        [weakSelf OSSpinLock];
    };
}

// 自旋锁
- (void)OSSpinLock {
    
    __block OSSpinLock lock = OS_SPINLOCK_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            OSSpinLockLock(&lock);
            NSLog(@"已不安全");
            OSSpinLockUnlock(&lock);
        }
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

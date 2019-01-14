//
//  RootViewController.m
//  iOSLock
//
//  Created by iOS开发T001 on 2019/1/11.
//  Copyright © 2019 iOS开发. All rights reserved.
//

#import "RootViewController.h"
#import "OSSpinLockViewController.h"
#import "RwLockViewController.h"
#import "PthreadViewController.h"
#import "SemaphoreViewController.h"
#import "LockViewController.h"

@interface RootViewController ()


@end


@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.dataArr addObjectsFromArray:@[@"自旋锁",@"互斥锁、条件锁、递归锁",@"读写锁",@"只执行一次",@"信号量",@"pthread"]];
    
    __weak typeof(self) weakSelf = self;
    self.itemOperation = ^(NSIndexPath * _Nonnull indexPath) {
        NSString *temp = weakSelf.dataArr[indexPath.row];
        if ([temp isEqualToString:@"自旋锁"]) {
            OSSpinLockViewController *OSSpinLockVC = [[OSSpinLockViewController alloc] init];
            [weakSelf.navigationController pushViewController:OSSpinLockVC animated:YES];
        } else if ([temp isEqualToString:@"互斥锁、条件锁、递归锁"]) {
            LockViewController *lockVC = [[LockViewController alloc] init];
            [weakSelf.navigationController pushViewController:lockVC animated:YES];
        } else if ([temp isEqualToString:@"信号量"]) {
            SemaphoreViewController *semaphoreVC = [[SemaphoreViewController alloc] init];
            [weakSelf.navigationController pushViewController:semaphoreVC animated:YES];
        } else if ([temp isEqualToString:@"读写锁"]) {
            RwLockViewController *rwLockVC = [[RwLockViewController alloc] init];
            [weakSelf.navigationController pushViewController:rwLockVC animated:YES];
        } else if ([temp isEqualToString:@"只执行一次"]) {
            [weakSelf onceAction];
        } else if ([temp isEqualToString:@"pthread"]) {
            PthreadViewController *pthreadVC = [[PthreadViewController alloc] init];
            [weakSelf.navigationController pushViewController:pthreadVC animated:YES];
        }
    };
}


/** 只执行一次 */
- (void)onceAction {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            NSLog(@"onceAction");
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSLog(@"%@",[NSThread currentThread]);
            });
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

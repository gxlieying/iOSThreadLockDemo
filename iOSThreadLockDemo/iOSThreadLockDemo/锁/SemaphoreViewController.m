//
//  SemaphoreViewController.m
//  iOSLock
//
//  Created by iOS开发T001 on 2019/1/14.
//  Copyright © 2019 iOS开发. All rights reserved.
//

#import "SemaphoreViewController.h"

@interface SemaphoreViewController ()

@end

@implementation SemaphoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataArr addObjectsFromArray:@[@"NSCondition",@"dispatch_semaphore_t"]];
    __weak typeof(self) weakSelf = self;
    self.itemOperation = ^(NSIndexPath * _Nonnull indexPath) {
        NSString *temp = weakSelf.dataArr[indexPath.row];
        if ([temp isEqualToString:@"NSCondition"]) {
            [weakSelf conditionAction];
        } else if ([temp isEqualToString:@"dispatch_semaphore_t"]) {
            [weakSelf semphoreAction];
        }
    };
}

- (void)conditionAction {
    __block NSMutableArray *products=[[NSMutableArray alloc] init];
    NSCondition *condition = [[NSCondition alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"加锁");
        [condition lock];
        sleep(1);
        NSLog(@"添加");
        [products addObject:@"Product"];
        NSLog(@"发送信号");
        [condition signal];
        NSLog(@"解锁");
        [condition unlock];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"加锁");
        [condition lock];
        NSLog(@"准备");
        if (!products.count) {
            NSLog(@"无，休眠等待");
            [condition wait];
        }
        NSLog(@"减一");
        [products removeObjectAtIndex:0];
        NSLog(@"解锁");
        [condition unlock];
    });
}

- (void)semphoreAction {
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        sleep(1);
        dispatch_semaphore_signal(semaphore);
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

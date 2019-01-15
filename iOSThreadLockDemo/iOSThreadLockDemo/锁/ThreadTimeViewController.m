//
//  ThreadTimeViewController.m
//  iOSThreadLockDemo
//
//  Created by iOS开发T001 on 2019/1/15.
//  Copyright © 2019 iOS开发. All rights reserved.
//

#import "ThreadTimeViewController.h"
#import <libkern/OSAtomic.h>
#import <os/lock.h>
#import <pthread.h>

@interface ThreadTimeViewController ()

@end

@implementation ThreadTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataArr addObject:@"打印时间"];
    
    __weak typeof(self) weakSelf = self;
    self.itemOperation = ^(NSIndexPath * _Nonnull indexPath) {
        [weakSelf timeAction];
    };
}

- (void)timeAction {
    NSMutableArray *timeArr = [NSMutableArray array];
    CFTimeInterval start,end,cost;
    NSInteger count = 100000;
    NSArray *nameArr = @[@"OSSpinLock",@"os_unfair_lock",@"NSLock",@"NSConditionLock",@"NSRecursiveLock",@"@synchronized",@"pthread_mutex",@"NSCondition",@"dispatch_semaphore"];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    {// OSSpinLock
        OSSpinLock lock = OS_SPINLOCK_INIT;
        start = CFAbsoluteTimeGetCurrent();
        for (int i = 0; i < count; i++) {
            OSSpinLockLock(&lock);
            OSSpinLockUnlock(&lock);
        }
        end = CFAbsoluteTimeGetCurrent();
        cost = end - start;
        [timeArr addObject:@(cost)];
    }
#pragma clang pop
    
    {// os_unfair_lock
        os_unfair_lock_t unfairLock;
        unfairLock = &(OS_UNFAIR_LOCK_INIT);
        start = CFAbsoluteTimeGetCurrent();
        for (int i = 0; i < count; i++) {
            os_unfair_lock_lock(unfairLock);
            os_unfair_lock_unlock(unfairLock);
        }
        end = CFAbsoluteTimeGetCurrent();
        cost = end - start;
        [timeArr addObject:@(cost)];
    }
    
    {// NSLock
        NSLock *lock = [NSLock new];
        start = CFAbsoluteTimeGetCurrent();
        for (int i = 0; i < count; i++) {
            [lock lock];
            [lock unlock];
        }
        end = CFAbsoluteTimeGetCurrent();
        cost = end - start;
        [timeArr addObject:@(cost)];
    }
    
    {// NSConditionLock
        NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:1];
        start = CFAbsoluteTimeGetCurrent();
        for (int i = 0; i < count; i++) {
            [lock lock];
            [lock unlock];
        }
        end = CFAbsoluteTimeGetCurrent();
        cost = end - start;
        [timeArr addObject:@(cost)];
    }
    
    {// NSRecursiveLock
        NSRecursiveLock *lock = [NSRecursiveLock new];
        start = CFAbsoluteTimeGetCurrent();
        for (int i = 0; i < count; i++) {
            [lock lock];
            [lock unlock];
        }
        end = CFAbsoluteTimeGetCurrent();
        cost = end - start;
        [timeArr addObject:@(cost)];
    }
    
    {// @synchronized
        NSObject *lock = [NSObject new];
        start = CFAbsoluteTimeGetCurrent();
        for (int i = 0; i < count; i++) {
            @synchronized(lock) {}
        }
        end = CFAbsoluteTimeGetCurrent();
        cost = end - start;
        [timeArr addObject:@(cost)];
    }
    
    {// pthread_mutex
        pthread_mutex_t lock;
        pthread_mutex_init(&lock, NULL);
        start = CFAbsoluteTimeGetCurrent();
        for (int i = 0; i < count; i++) {
            pthread_mutex_lock(&lock);
            pthread_mutex_unlock(&lock);
        }
        end = CFAbsoluteTimeGetCurrent();
        cost = end - start;
        [timeArr addObject:@(cost)];
    }
    
    {// NSCondition
        NSCondition *lock = [NSCondition new];
        start = CFAbsoluteTimeGetCurrent();
        for (int i = 0; i < count; i++) {
            [lock lock];
            [lock unlock];
        }
        end = CFAbsoluteTimeGetCurrent();
        cost = end - start;
        [timeArr addObject:@(cost)];
    }
    
    
    {// dispatch_semaphore
        dispatch_semaphore_t lock =  dispatch_semaphore_create(1);
        start = CFAbsoluteTimeGetCurrent();
        for (int i = 0; i < count; i++) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(lock);
        }
        end = CFAbsoluteTimeGetCurrent();
        cost = end - start;
        [timeArr addObject:@(cost)];
    }
    
    
    
    for (int i = 0; i < timeArr.count; i++) {
        NSLog(@"------%@------%@\n",timeArr[i],nameArr[i]);
    }
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

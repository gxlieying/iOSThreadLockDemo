//
//  PthreadViewController.m
//  iOSLock
//
//  Created by iOS开发T001 on 2019/1/14.
//  Copyright © 2019 iOS开发. All rights reserved.
//

#import "PthreadViewController.h"
#import <pthread.h>

@interface PthreadViewController ()

@end

@implementation PthreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.dataArr addObjectsFromArray:@[@"互斥锁",@"递归锁",@"信号量",@"读写锁",@"ONCE(只执行一次)"]];
    __weak typeof(self) weakSelf = self;
    self.itemOperation = ^(NSIndexPath * _Nonnull indexPath) {
        NSString *temp = weakSelf.dataArr[indexPath.row];
        if ([temp isEqualToString:@"互斥锁"]) {
            [weakSelf mutexLockAction];
        } else if ([temp isEqualToString:@"递归锁"]) {
            [weakSelf recursiveLockAction];
        } else if ([temp isEqualToString:@"信号量"]) {
            [weakSelf semaphoreAction];
        } else if ([temp isEqualToString:@"读写锁"]) {
            [weakSelf rwLockAction];
        } else if ([temp isEqualToString:@"ONCE(只执行一次)"]) {
            [weakSelf onceLockAction];
        }
    };
}

/** 互斥锁 */
- (void)mutexLockAction {
    __block pthread_mutex_t lock;
    pthread_mutex_init(&lock,NULL);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            NSLog(@"线程 0：加锁");
            pthread_mutex_lock(&lock);
            NSLog(@"线程 0：睡眠 1 秒");
            sleep(1);
            pthread_mutex_unlock(&lock);
            NSLog(@"线程 0：解锁");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            NSLog(@"线程 1：加锁");
            pthread_mutex_lock(&lock);
            NSLog(@"线程 1：睡眠 2 秒");
            sleep(2);
            pthread_mutex_unlock(&lock);
            NSLog(@"线程 1：解锁");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            NSLog(@"线程 2：加锁");
            pthread_mutex_lock(&lock);
            NSLog(@"线程 2：睡眠 3 秒");
            sleep(3);
            pthread_mutex_unlock(&lock);
            NSLog(@"线程 2：解锁");
        }
    });
    // 释放锁
    pthread_mutex_destroy(&lock);
}

/** 递归锁 */
- (void)recursiveLockAction {
    static pthread_mutex_t pLock;
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr); //初始化attr并且给它赋予默认
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE); //设置锁类型，这边是设置为递归锁
    pthread_mutex_init(&pLock, &attr);
    pthread_mutexattr_destroy(&attr); //销毁一个属性对象，在重新进行初始化之前该结构不能重新使用
    
    // 线程
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            pthread_mutex_lock(&pLock);
            if (value > 0) {
                NSLog(@"value: %d", value);
                RecursiveBlock(value - 1);
            }
            pthread_mutex_unlock(&pLock);
        };
        RecursiveBlock(5);
    });
}

/** 信号量 */
- (void)semaphoreAction {
    __block pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
    __block pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            //NSLog(@"线程 0：加锁");
            pthread_mutex_lock(&mutex);
            pthread_cond_wait(&cond, &mutex);
            NSLog(@"线程 0：wait");
            pthread_mutex_unlock(&mutex);
            //NSLog(@"线程 0：解锁");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            //NSLog(@"线程 1：加锁");
            sleep(3);//3秒发一次信号
            pthread_mutex_lock(&mutex);
            NSLog(@"线程 1：signal");
            pthread_cond_signal(&cond);
            pthread_mutex_unlock(&mutex);
            //NSLog(@"线程 1：加锁");
        }
    });
    
}

/** 读写锁 */
- (void)rwLockAction {
    __block pthread_rwlock_t rwlock;
    pthread_rwlock_init(&rwlock,NULL);
    // 读
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            //NSLog(@"线程0：随眠 1 秒");//还是不打印能直观些
            sleep(1);
            NSLog(@"线程0：加锁");
            pthread_rwlock_rdlock(&rwlock);
            NSLog(@"线程0：读");
            pthread_rwlock_unlock(&rwlock);
            NSLog(@"线程0：解锁");
        }
    });
    // 写
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            //NSLog(@"线程1：随眠 3 秒");
            sleep(3);
            NSLog(@"线程1：加锁");
            pthread_rwlock_wrlock(&rwlock);
            NSLog(@"线程1：写");
            pthread_rwlock_unlock(&rwlock);
            NSLog(@"线程1：解锁");
        }
    });
}

/** 只执行一次 */
- (void)onceLockAction {
    __block pthread_once_t once=PTHREAD_ONCE_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            sleep(1);
            pthread_once(&once, fun);
        }
    });
}

void fun(void){
    NSLog(@"%@",[NSThread currentThread]);
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

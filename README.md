# iOSThreadLockDemo
我们在使用多线程的时候多个线程可能会访问同一块资源，这样就很容易引发数据错乱和数据安全等问题，这时候就需要我们保证每次只有一个线程访问这一块资源，这就是锁。


# 一、互斥锁
> 在编程中，引入了对象互斥锁的概念，来保证共享数据操作的完整性。每个对象都对应于一个可称为" 互斥锁" 的标记，这个标记用来保证在任一时刻，只能有一个线程访问该对象
## 1. @synchronize
* @synchronized要一个参数,这个参数相当于信号量
```
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
```
## 2. NSLock
```
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
```

## 3.  pthread
> pthread可以创建互斥锁、递归锁、读写锁、once等锁，可以单独学习，这里不做详细讲解

# 二、递归锁（NSRecursiveLock）
> 同意线程可多次加锁，不会造成死锁
```
- (void)recursiveLockAction {
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
```


# 三、信号量
> 信号量(Semaphore)，有时被称为信号灯，是在多线程环境下使用的一种设施，是可以用来保证两个或多个关键代码段不被并发调用。在进入一个关键代码段之前，线程必须获取一个信号量；一旦该关键代码段完成了，那么该线程必须释放信号量。其它想进入该关键代码段的线程必须等待直到第一个线程释放信号量
## 1. NSCondition
```
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
```
## 2. GCD dispatch_semaphore_t
信号量参数为信号的总量
```
- (void)semphoreAction {
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        sleep(1);
        dispatch_semaphore_signal(semaphore);
    });
}
```
# 四、条件锁(NSConditionLock)
* lockWhenCondition:满足特定条件,执行相应代码
* unlockWithCondition:我的理解就是设置解锁条件（同一时刻只有一个条件，如果已设置条件，相当于修改条件）
```
- (void)conditionLockAction {
    NSConditionLock *conditionLock = [[NSConditionLock alloc] initWithCondition:0];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        for (int i=0;i<3;i++){
            [conditionLock lock];
            NSLog(@"线程 0:%d",i);
            sleep(1);
            [conditionLock unlockWithCondition:i];
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [conditionLock lock];
        NSLog(@"线程 1");
        [conditionLock unlock];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [conditionLock lockWhenCondition:2];
        NSLog(@"线程 2");
        [conditionLock unlockWithCondition:0];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        [conditionLock lockWhenCondition:1];
        NSLog(@"线程 3");
        [conditionLock unlockWithCondition:2];
    });    
}
```

# 五、分布式锁(NSDistributedLock)
> 分布式锁是控制分布式系统之间同步访问共享资源的一种方式。在分布式系统中，常常需要协调他们的动作。如果不同的系统或是同一个系统的不同主机之间共享了一个或一组资源，那么访问这些资源的时候，往往需要互斥来防止彼此干扰来保证一致性，在这种情况下，便需要使用到分布式锁

* 处理多个进程或多个程序之间互斥问题
* 一个获取锁的进程或程序在释放锁之前挂掉，锁不会被释放，可以通过breakLock方法解锁
* 通过文件系统实现的互斥,Mac开发使用


# 六、读写锁
> 读写锁是多线程下的一种同步机制，也称“共享-互斥锁”。是一种特殊的自旋锁，它把对共享资源的访问者划分成读者和写者，读者只对共享资源进行读访问，写者则需要对共享资源进行写操作。这种锁相对于自旋锁而言，能提高并发性，因为在多处理器系统中，它允许同时有多个读者来访问共享资源，最大可能的读者数为实际的逻辑CPU数。写者是排他性的，一个读写锁同时只能有一个写者或多个读者（与CPU数相关），但不能同时既有读者又有写者

可以使用`dispatch_barrier_async `创建读写锁
```
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
```

# 七、自旋锁
> 自旋锁是为了防止多处理器并发而引入的一种锁，它是为实现保护共享资源而提出一种锁机制。其实，自旋锁与互斥锁比较类似，它们都是为了解决对某项资源的互斥使用。无论是互斥锁，还是自旋锁，在任何时刻，最多只能有一个保持者，也就说，在任何时刻最多只能有一个执行单元获得锁。但是两者在调度机制上略有不同。对于互斥锁，如果资源已经被占用，资源申请者只能进入睡眠状态。但是自旋锁不会引起调用者睡眠，如果自旋锁已经被别的执行单元保持，调用者就一直循环在那里看是否该自旋锁的保持者已经释放了锁，"自旋"一词就是因此而得名。

## 1. OSSpinLock(已弃用)
* OSSpinLock已不再安全，文章[《不再安全的OSSpinLock》](http://www.cocoachina.com/ios/20161115/18088.html)
```
    __block OSSpinLock lock = OS_SPINLOCK_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            OSSpinLockLock(&lock);
            NSLog(@"已不安全");
            OSSpinLockUnlock(&lock);
        }
    });
```
## 2. os_unfair_lock
os_unfair_lock 是苹果官方推荐的替换OSSpinLock的方案，但是它在iOS10.0以上的系统开始支持。
```
- (void)unfairLock {

    __block os_unfair_lock unfairLock = OS_UNFAIR_LOCK_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            os_unfair_lock_lock(&unfairLock);
            NSLog(@"执行操作");
            os_unfair_lock_unlock(&unfairLock);
        }
    });
}
```

# 八、ONCE（只执行一次）
* 多用来创建单例
## GCD dispatch_once
```
- (void)onceAction {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i <= 3; i++) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                NSLog(@"%@",[NSThread currentThread]);
            });
        }
    });
}
```
结果：![](https://upload-images.jianshu.io/upload_images/3958249-72bd5c186093d3a4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


#  九、性能比较
![性能](https://upload-images.jianshu.io/upload_images/3958249-755d0420fe2df13c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

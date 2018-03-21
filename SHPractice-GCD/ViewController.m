//
//  ViewController.m
//  SHPractice-GCD
//
//  Created by Shine on 18/03/2018.
//  Copyright © 2018 yixia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    dispatch_semaphore_t semaphoreLock;
}
@property (nonatomic, assign) NSInteger tickets;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self demo13];
}


//同步+串行队列 (不会开新线程，顺序执行,"结束了"肯定会在最后打印)
- (void)demo1{
    //串行队列
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_SERIAL);
    
    for(NSInteger i = 0; i < 10; i++) {
        dispatch_sync(q, ^{
            NSLog(@"%@ ********** %ld",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"结束了。。。");
}


//同步+并发队列 （不会开新线程，顺序执行, "结束了"肯定会在最后打印)
- (void)demo2{
    //并行队列
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);
    
    for(NSInteger i = 0;i < 10 ; i++){
        dispatch_sync(q, ^{
            NSLog(@"%@ ********** %ld",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"结束了。。。");
}

//异步+同步队列 (会开启一个线程，顺序执行，“结束了"执行时机不一定)
- (void)demo3{
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_SERIAL);
    
    for(NSInteger i = 0; i < 10 ; i++){
        dispatch_async(q, ^{
            NSLog(@"%@ ********** %ld",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"结束了。。。");
}

//异步+并发队列 (会开启多个线程, 执行顺序不确定, "结束了"执行时机也不一定)
- (void)demo4{
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);
    
    for(NSInteger i = 0; i < 10 ; i++){
        dispatch_async(q, ^{
            NSLog(@"%@ ********** %ld",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"结束了。。。");

}

#pragma mark - dispatch_After
//Dispatch_after (会延时调度队列中的任务，并且一定是"异步执行")

//dispatch_after 串行队列
- (void)demo5{
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_SERIAL);
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC));
    dispatch_after(t, q, ^{
        NSLog(@"%@",[NSThread currentThread]);   // <NSThread: 0x60000007d980>{number = 3, name = (null)}   开了新线程
    });
}


//dispatch_after 并发队列
- (void)demo6{
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC));
    dispatch_after(t, q, ^{
        NSLog(@"%@",[NSThread currentThread]);   // <NSThread: 0x600000461a00>{number = 3, name = (null)}   开了新线程
    });
}


#pragma mark - dispatch_once

//dispatch_once 不仅是只执行一次，而且是线程安全的。
- (void)demo7{
    for(int i = 0; i < 10; i++){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self once];
        });
    };
}

- (void)once{
    NSLog(@"进来了");
    static dispatch_once_t onceToken;
    NSLog(@"onceToken  %ld",onceToken);
    dispatch_once(&onceToken, ^{
        NSLog(@"这里只执行了一次 %@",[NSThread currentThread]);
    });
}

#pragma mark - dispatch_group
//加两个dispatch_group_notify也是可以的。
- (void)demo8{
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);   //全局队列
    dispatch_group_t g = dispatch_group_create();
    dispatch_group_async(g, q, ^{
        NSLog(@"第1个任务******%@",[NSThread currentThread]);
    });
    
    dispatch_group_async(g, q, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"第2个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_group_async(g, q, ^{
        NSLog(@"第3个任务********%@",[NSThread currentThread]);
    });
    
    dispatch_group_notify(g, q, ^{   //这里还是在全局队列里执行,所以这个任务还是会在子线程里执行
        NSLog(@"所有任务都执行完毕啦*********%@",[NSThread currentThread]);   //这里还是在子线程
    });
    
    dispatch_group_notify(g, dispatch_get_main_queue(), ^{
        NSLog(@"所有任务都执行完毕啦*********%@",[NSThread currentThread]);   //这里回到主线程刷新UI
    });
    
}

#pragma mark - dispatch_barrier
//执行完栅栏之前的任务，然后执行栅栏任务。最后执行栅栏之后的任务
- (void)demo9{
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(q, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"第1个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_async(q, ^{
        NSLog(@"第2个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_barrier_async(q, ^{
        NSLog(@"第1个barrier任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_barrier_async(q, ^{
        NSLog(@"第2个barrier任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_async(q, ^{
        NSLog(@"第3个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_async(q, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"第4个任务*******%@",[NSThread currentThread]);
    });
    
    
    /*
     
     2018-03-21 11:39:18.979090+0800 SHPractice-GCD[26495:984304] 第2个任务*******<NSThread: 0x604000462b80>{number = 3, name = (null)}
     2018-03-21 11:39:20.983903+0800 SHPractice-GCD[26495:984290] 第1个任务*******<NSThread: 0x60000046a1c0>{number = 4, name = (null)}
     2018-03-21 11:39:20.984268+0800 SHPractice-GCD[26495:984290] 第1个barrier任务*******<NSThread: 0x60000046a1c0>{number = 4, name = (null)}
     2018-03-21 11:39:20.984565+0800 SHPractice-GCD[26495:984290] 第2个barrier任务*******<NSThread: 0x60000046a1c0>{number = 4, name = (null)}
     2018-03-21 11:39:20.984826+0800 SHPractice-GCD[26495:984290] 第3个任务*******<NSThread: 0x60000046a1c0>{number = 4, name = (null)}
     2018-03-21 11:39:22.988300+0800 SHPractice-GCD[26495:984304] 第4个任务*******<NSThread: 0x604000462b80>{number = 3, name = (null)}
     
     */
}


//全局队列里加栅栏就和普通的dispatch_async效果一样了。必须是并发队列(DISPATCH_QUEUE_CONCURRENT)
- (void)demo10{
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    dispatch_async(q, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"第1个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_async(q, ^{
        NSLog(@"第2个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_barrier_async(q, ^{
        NSLog(@"第1个barrier任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_barrier_async(q, ^{
        NSLog(@"第2个barrier任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_async(q, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"第3个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_async(q, ^{
        NSLog(@"第4个任务*******%@",[NSThread currentThread]);
    });
    
    
    /*
     
     2018-03-21 11:43:18.247669+0800 SHPractice-GCD[26609:989027] 第1个barrier任务*******<NSThread: 0x60400046d800>{number = 5, name = (null)}
     2018-03-21 11:43:18.247711+0800 SHPractice-GCD[26609:989022] 第2个任务*******<NSThread: 0x600000260bc0>{number = 3, name = (null)}
     2018-03-21 11:43:18.247758+0800 SHPractice-GCD[26609:989028] 第2个barrier任务*******<NSThread: 0x60400046d5c0>{number = 4, name = (null)}
     2018-03-21 11:43:18.247989+0800 SHPractice-GCD[26609:989030] 第4个任务*******<NSThread: 0x60400046db80>{number = 6, name = (null)}
     2018-03-21 11:43:20.248029+0800 SHPractice-GCD[26609:988358] 第1个任务*******<NSThread: 0x60400046dac0>{number = 8, name = (null)}
     2018-03-21 11:43:20.248029+0800 SHPractice-GCD[26609:989029] 第3个任务*******<NSThread: 0x6000002608c0>{number = 7, name = (null)}

     */
}


//串行队列就没意义了。因为加不加栅栏，都会是顺序执行了。所以这种情况不会用到。没有意义
- (void)demo11{
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_SERIAL);   //串行队列
    dispatch_async(q, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"第1个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_async(q, ^{
        NSLog(@"第2个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_barrier_async(q, ^{
        NSLog(@"第1个barrier任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_barrier_async(q, ^{
        NSLog(@"第2个barrier任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_async(q, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"第3个任务*******%@",[NSThread currentThread]);
    });
    
    dispatch_async(q, ^{
        NSLog(@"第4个任务*******%@",[NSThread currentThread]);
    });
    
    /*
     
     2018-03-21 11:44:28.456845+0800 SHPractice-GCD[26656:990165] 第1个任务*******<NSThread: 0x600000467e80>{number = 4, name = (null)}
     2018-03-21 11:44:28.457185+0800 SHPractice-GCD[26656:990165] 第2个任务*******<NSThread: 0x600000467e80>{number = 4, name = (null)}
     2018-03-21 11:44:28.457461+0800 SHPractice-GCD[26656:990165] 第1个barrier任务*******<NSThread: 0x600000467e80>{number = 4, name = (null)}
     2018-03-21 11:44:28.457665+0800 SHPractice-GCD[26656:990165] 第2个barrier任务*******<NSThread: 0x600000467e80>{number = 4, name = (null)}
     2018-03-21 11:44:30.462219+0800 SHPractice-GCD[26656:990165] 第3个任务*******<NSThread: 0x600000467e80>{number = 4, name = (null)}
     2018-03-21 11:44:30.462574+0800 SHPractice-GCD[26656:990165] 第4个任务*******<NSThread: 0x600000467e80>{number = 4, name = (null)}

     */
}


//dispatch_apply. 按指定的次数在队列中重复执行block中的任务。并等待全部处理结束了才执行apply之后的任务. (可以用来异步遍历数组操作). 和dispatch_sync操作的作用一样。
//无论是在串行队列，还是异步队列中，dispatch_apply 都会等待全部任务执行完毕，再执行dispatch_apply外代码。
- (void)demo12{
    //    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);  //并发队列进行异步执行，dispatch_apply 可以在多个线程中同时（异步）遍历多个数字。
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_SERIAL);   //串行队列, dispatch_apply，那么就和 for 循环一样，按顺序同步执行
    void(^task)(void) = ^() {
        for(int i = 0; i < 10 ;i++){
            NSLog(@"i等于%d",i);
            NSLog(@"当前线程是%@",[NSThread currentThread]);
        }
    };
    NSLog(@"apply之前");
    dispatch_apply(10, q, ^(size_t t) {
        task();
        NSLog(@"第%zu次循环",t);
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //更新UI
        NSLog(@"这里更新UI");
    });
    NSLog(@"apply之后");
}

#pragma mark - disaptch_semaphore
- (void)demo13{
    /* 代表北京售票点 */ dispatch_queue_t q1 = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);
    /* 代表上海售票点 */ dispatch_queue_t q2 = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);
    self.tickets = 100;
    semaphoreLock = dispatch_semaphore_create(1);   //同时只允许一个线程访问资源
    dispatch_async(q1, ^{
        [self safeSellTicket];
    });
    
    dispatch_async(q2, ^{
        [self safeSellTicket];
    });
}


//非安全版
- (void)unsafeSellTicket{
    while (1) {
        if(self.tickets > 0){
            self.tickets--;
            [NSThread sleepForTimeInterval:0.2];   //模拟耗时操作
            NSLog(@"剩余票数%ld,%@",(long)self.tickets,[NSThread currentThread]);
        }
        else{  //没票了
            NSLog(@"剩余票数%ld,%@",(long)self.tickets,[NSThread currentThread]);
            break;
        }
    }
}


//安全版
- (void)safeSellTicket{
    while (1) {
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);  //加锁
        if(self.tickets > 0){
            self.tickets--;
            [NSThread sleepForTimeInterval:0.2];   //模拟耗时操作
            NSLog(@"剩余票数%ld,%@",(long)self.tickets,[NSThread currentThread]);
        }
        else{  //没票了
            dispatch_semaphore_signal(semaphoreLock);
            NSLog(@"剩余票数%ld,%@",(long)self.tickets,[NSThread currentThread]);
            break;
        }
        dispatch_semaphore_signal(semaphoreLock);
    }
}

@end

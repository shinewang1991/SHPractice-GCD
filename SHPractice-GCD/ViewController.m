//
//  ViewController.m
//  SHPractice-GCD
//
//  Created by Shine on 18/03/2018.
//  Copyright © 2018 yixia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self demo8];
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

@end

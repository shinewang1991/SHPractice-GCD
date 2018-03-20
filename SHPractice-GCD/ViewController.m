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
    [self demo6];
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

- (void)demo6{
    dispatch_queue_t q = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1 * NSEC_PER_SEC));
    dispatch_after(t, q, ^{
        NSLog(@"%@",[NSThread currentThread]);   // <NSThread: 0x600000461a00>{number = 3, name = (null)}   开了新线程
    });
}

@end

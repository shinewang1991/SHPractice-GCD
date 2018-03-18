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
    [self demo4];
}


//同步+串行队列 (不会开新线程，顺序执行,"结束了"肯定会在最后打印)
- (void)demo1{
    //串行队列
    dispatch_queue_t t = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_SERIAL);
    
    for(NSInteger i = 0; i < 10; i++) {
        dispatch_sync(t, ^{
            NSLog(@"%@ ********** %ld",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"结束了。。。");
}


//同步+并发队列 （不会开新线程，顺序执行, "结束了"肯定会在最后打印)
- (void)demo2{
    //并行队列
    dispatch_queue_t t = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);
    
    for(NSInteger i = 0;i < 10 ; i++){
        dispatch_sync(t, ^{
            NSLog(@"%@ ********** %ld",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"结束了。。。");
}

//异步+同步队列 (会开启一个线程，顺序执行，“结束了"执行时机不一定)
- (void)demo3{
    dispatch_queue_t t = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_SERIAL);
    
    for(NSInteger i = 0; i < 10 ; i++){
        dispatch_async(t, ^{
            NSLog(@"%@ ********** %ld",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"结束了。。。");
}

//异步+并发队列 (会开启多个线程, 执行顺序不确定, "结束了"执行时机也不一定)
- (void)demo4{
    dispatch_queue_t t = dispatch_queue_create("SHPractice-GCD", DISPATCH_QUEUE_CONCURRENT);
    
    for(NSInteger i = 0; i < 10 ; i++){
        dispatch_async(t, ^{
            NSLog(@"%@ ********** %ld",[NSThread currentThread],i);
        });
    }
    
    NSLog(@"结束了。。。");

}


@end

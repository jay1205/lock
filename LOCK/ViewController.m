//
//  ViewController.m
//  LOCK
//
//  Created by JHW on 2017/9/28.
//  Copyright © 2017年 JHW. All rights reserved.
//

#import "ViewController.h"

#define Window  [[[UIApplication sharedApplication] delegate] window]
#define WIDTH   [[UIScreen mainScreen] bounds].size.width
#define HEIGHT  [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()
@property (nonatomic, assign)NSInteger clickIndex;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ;
    for (int i = 0; i<2; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake((WIDTH - 100)/2, 100*i+100, 100, 100);
        [btn setTitle:(i==0?@"普通锁":@"递归锁") forState:UIControlStateNormal];
        SEL action = (i==0?@selector(btnclick):@selector(btnclick2));
        [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)btnclick{
    NSLock *lock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^block)(int);
        block = ^(int value) {
            //加锁
            [lock lock];
            NSLog(@"加锁");
            if (value > 0) {
                NSLog(@"%d",value);
                //                sleep(2);
                //递归调用
                block(--value);
            }
            //解锁
            [lock unlock];
            NSLog(@"解锁");
        };
        //调用代码块
        block(10);
    });
}

- (void)btnclick2{
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^block)(int);
        block = ^(int value) {
            //加锁
            [lock lock];
            NSLog(@"加锁");
            if (value > 0) {
                NSLog(@"%d",value);
                //
                sleep(2);
                //递归调用
                block(--value);
            }
            //解锁
            [lock unlock];
            NSLog(@"解锁");
        };
        //调用代码块
        block(10);
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        BOOL flag = [lock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        if (flag) {
            NSLog(@"lock before date");
            
            [lock unlock];
        } else {
            NSLog(@"fail to lock before date");
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

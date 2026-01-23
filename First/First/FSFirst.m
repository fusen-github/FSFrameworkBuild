//
//  FSFirst.m
//  First
//
//  Created by fusen on 2026/1/7.
//

#import "FSFirst.h"
#import <Second/FSSecond.h>

@implementation FSFirst

+ (void)printFirst {
    NSLog(@"我是 first");
    [FSSecond printSecond];
}

@end

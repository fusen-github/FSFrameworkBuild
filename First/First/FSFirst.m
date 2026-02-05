//
//  FSFirst.m
//  First
//
//  Created by fusen on 2026/1/7.
//

#import "FSFirst.h"
#import <Second/FSSecond.h>
#import "FSFirstMacro.h"


@implementation FSFirst

+ (void)printFirst {
    NSLog(@"我是 first");
    [FSSecond printSecond];
    
#ifdef AAA
    NSLog(@"我是AAA");
#endif
    
#ifdef USE_IDFA
    NSLog(@"我是 IDFA");
#endif
}


@end

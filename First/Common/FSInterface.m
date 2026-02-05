//
//  FSInterface.m
//  First
//
//  Created by fusen on 2026/2/5.
//

#import "FSInterface.h"
#import "FSBaidu.h"
#import "FSAli.h"
#import "FSFirst.h"


@implementation FSInterface

+ (void)test {
//    if ([FSBaidu class]) {
//        [FSBaidu test];
//    } else if ([FSAli class]) {
//        [FSAli test];
//    } else if ([FSFirst class]) {
//        [FSFirst printFirst];
//    }
    
#if defined(IS_FIRST)
    [FSFirst printFirst];
#elif defined(IS_FIRST_BAIDU)
    [FSBaidu test];
#elif defined(IS_FIRST_ALI)
    [FSAli test];
#endif
    
    NSLog(@"%s", __func__);
}

@end

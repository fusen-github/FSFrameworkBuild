//
//  FSPerson.m
//  FSSDK
//
//  Created by fusen on 2026/2/28.
//

#import "FSPerson.h"
#import <AFNetworking/AFNetworking.h>

@implementation FSPerson

+ (void)printPerson {
    [[AFHTTPSessionManager manager] GET:@"http://www.baidu.com" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"FS--response=%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"FS--error=%@", error);
    }];
}

@end

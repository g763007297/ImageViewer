//
//  GQGobalPaths.m
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageGobalPaths.h"

static NSBundle* globalBundle = nil;

/**
 * 设置全局bundle,默认为main bundle, 如多主题可以使用
 */
void GQSetDefaultBundle(NSBundle* bundle)
{
    globalBundle = bundle;
}

/**
 * 返回全局默认bundle
 */
NSBundle *GQGetDefaultBundle()
{
    return (nil != globalBundle) ? globalBundle : [NSBundle mainBundle];
}

/**
 * 返回bundle资源路径
 */
NSString *GQPathForBundleResource(NSString* relativePath)
{
    NSString* resourcePath = [GQGetDefaultBundle() resourcePath];
    return [resourcePath stringByAppendingPathComponent:relativePath];
}

/**
 * 返回Documents资源路径
 */
NSString *GQPathForDocumentsResource(NSString* relativePath)
{
    static NSString* documentsPath = nil;
    if (nil == documentsPath) {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = dirs[0];
    }
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

/**
 * 返回Cache资源路径
 */
NSString *GQPathForCacheResource(NSString* relativePath)
{
    static NSString* documentsPath = nil;
    if (nil == documentsPath) {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        documentsPath = dirs[0];
    }
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

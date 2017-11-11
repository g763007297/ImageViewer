//
//  GQGobalPaths.h
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 设置全局bundle,默认为main bundle, 如多主题可以使用
 */
void GQSetDefaultBundle(NSBundle* bundle);

/**
 * 返回全局默认bundle
 */
NSBundle *GQGetDefaultBundle(void);

/**
 * 返回bundle资源路径
 */
NSString *GQPathForBundleResource(NSString* relativePath);

/**
 * 返回Documents资源路径
 */
NSString *GQPathForDocumentsResource(NSString* relativePath);

/**
 * 返回Cache资源路径
 */
NSString *GQPathForCacheResource(NSString* relativePath);

//
//  GQImageCacheManager.h
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GQImageDownloaderConst.h"

typedef enum : NSUInteger {
    GQImageDownloaderCacheTypeNone,
    GQImageDownloaderCacheTypeOnlyMemory,
    GQImageDownloaderCacheTypeDisk
} GQImageDownloaderCacheType;

@interface GQImageCacheManager : NSObject

+ (GQImageCacheManager *)sharedManager;

/**
 *  获取指定key的图片文件位置
 *
 *  param url 请求的url或key
 *
 *  return 文件位置
 */
- (NSString *)createImageFilePathWithUrl:(NSString *)url;

/**
 *  图片保存
 *
 *  param image 图片
 *  param url   请求的url或key
 *  param cacheType   缓存类型
 */
- (void)saveImage:(UIImage*)image withUrl:(NSString*)url withCacheType:(GQImageDownloaderCacheType)cacheType;
- (void)saveImage:(UIImage*)image withKey:(NSString*)key withCacheType:(GQImageDownloaderCacheType)cacheType;

/**
 *  获取指定图片
 *
 *  param url 请求的url或key
 *
 *  return image
 */
- (UIImage *)getImageFromCacheWithUrl:(NSString*)url;
- (UIImage *)getImageFromCacheWithKey:(NSString*)key;

/**
 *  图片是否缓存在内存里
 *
 *  param url 请求的url或key
 *
 *  return YES or NO
 */
- (BOOL)isImageInMemoryCacheWithUrl:(NSString*)url;

/**
 图片是否缓存在硬盘中

 param url
 return
 */
- (BOOL)isImageExistDiskWithUrl:(NSString *)url;

/**
 *  清除内存中的缓存
 */
- (void)clearMemoryCache;

/**
 *  删除指定的image缓存
 *
 *  param url 请求的url或key
 */
- (void)removeImageFromCacheWithUrl:(NSString *)url;
- (void)removeImageFromCacheWithKey:(NSString *)key;

/**
 获取文件缓存总大小

 return 文件大小
 */
- (NSUInteger)getSize;

/**
 获取文件总数

 return 文件数
 */
- (NSUInteger)getDiskCount;

/**
 删除disk所有资源文件
 */
- (void)clearDisk;
- (void)clearDiskOnCompletion:(GQImageDownloaderNoParamsBlock)completion;

@end

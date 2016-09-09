//
//  GQImageCacheManager.h
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GQImageCacheManager : NSObject

+ (GQImageCacheManager *)sharedManager;

- (NSString *)createImageFilePathWithUrl:(NSString *)url;

- (void)saveImage:(UIImage*)image withUrl:(NSString*)url;
- (void)saveImage:(UIImage*)image withKey:(NSString*)key;

- (UIImage*)getImageFromCacheWithUrl:(NSString*)url;
- (UIImage*)getImageFromCacheWithKey:(NSString*)key;

- (BOOL)isImageInMemoryCacheWithUrl:(NSString*)url;

- (void)clearMemoryCache;
- (void)clearDiskCache;

- (void)removeImageFromCacheWithUrl:(NSString *)url;
- (void)removeImageFromCacheWithKey:(NSString *)key;

@end

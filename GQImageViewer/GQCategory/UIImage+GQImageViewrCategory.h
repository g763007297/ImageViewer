//
//  UIImage+GQImageViewrCategory.h
//  ImageViewer
//
//  Created by 高旗 on 17/1/19.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef GQ_CoreSD
    #if __has_include(<SDWebImage/UIImageView+WebCache.h>)
    #import <SDWebImage/UIImageView+WebCache.h>
    #elif __has_include("UIImageView+WebCache.h")
    #import "UIImageView+WebCache.h"
    #endif
#else
    #if __has_include(<GQImageDownloader/UIImage+GQImageDownloader.h>)
    #import <GQImageDownloader/UIImage+GQImageDownloader.h>
    #elif __has_include("UIImage+GQImageDownloader.h")
    #import "UIImage+GQImageDownloader.h"
    #endif
    #if __has_include(<GQImageDownloader/GQImageCacheManager.h>)
    #import <GQImageDownloader/GQImageCacheManager.h>
    #elif __has_include("GQImageCacheManager.h")
    #import "GQImageCacheManager.h"
    #endif
#endif

@interface UIImage (GQImageViewrCategory)

/**
 等比例自适应imageView大小  (等高  宽度自适应)

 param size 父视图size
 return 适配后的size
 */
- (CGRect)gq_imageSizeHeightCompareWithSize:(CGSize)size;

/**
 等比例自适应imageView大小  （等宽 高度自适应）
 
 param size 父视图size
 return 适配后的size
 */
- (CGRect)gq_imageSizeWidthCompareWithSize:(CGSize)size;

/**
 等比例自适应imageView大小  （高宽等比例缩放至图片完全显示）
 
 param size 父视图size
 return 适配后的size
 */
- (CGRect)gq_imageSizeFullyDisplayCompareWithSize:(CGSize)size;

@end

//
//  UIImage+GQImageViewrCategory.h
//  ImageViewer
//
//  Created by 高旗 on 17/1/19.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GQImageViewrCategory)

#ifdef GQ_WEBP

/**
 data转换成UIImage
 
 @param imgData
 @return
 */
+ (UIImage *)gq_imageWithWebPData:(NSData *)imgData;

/**
 WebP文件转换成UIImage
 
 @param filePath
 @return
 */
+ (UIImage *)gq_imageWithWebPFile:(NSString*)filePath;

/**
 WebP图片转换成UIImage

 @param imageName
 @return
 */
+ (UIImage *)gq_imageWithWebPImageName:(NSString *)imageName;

#endif

/**
 等比例自适应imageView大小  (等高  宽度自适应)

 @param size 父视图size
 @return 适配后的size
 */
- (CGRect)gq_imageSizeHeightCompareWithSize:(CGSize)size;

/**
 等比例自适应imageView大小  （等宽 高度自适应）
 
 @param size 父视图size
 @return 适配后的size
 */
- (CGRect)gq_imageSizeWidthCompareWithSize:(CGSize)size;

/**
 等比例自适应imageView大小  （高宽等比例缩放至图片完全显示）
 
 @param size 父视图size
 @return 适配后的size
 */
- (CGRect)gq_imageSizeFullyDisplayCompareWithSize:(CGSize)size;

@end

//
//  UIImage+GQImageDownloader.h
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GQImageDownloader)

#ifdef GQ_WEBP

/**
 WebP文件转换成UIImage
 
 param filePath
 return
 */
+ (UIImage *)gq_imageWithWebPFile:(NSString*)filePath;

/**
 WebP图片转换成UIImage
 
 param imageName
 return
 */
+ (UIImage *)gq_imageWithWebPImageName:(NSString *)imageName;

#endif

@end

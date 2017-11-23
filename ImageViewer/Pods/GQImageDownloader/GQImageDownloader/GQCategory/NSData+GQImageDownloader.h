//
//  NSData+GQImageDownloader.h
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSData (GQImageDownloader)

/**
 获取图片资源
 
 return UIImage *
 */
- (UIImage *)gqImageWithData;

/**
 获取图片种类
 
 return 种类字符串
 */
- (NSString *)gqTypeForImageData;

#ifdef GQ_WEBP

/**
 data转换成UIImage
 
 param imgData
 return
 */
+ (UIImage *)gq_imageWithWebPData:(NSData *)imgData;

#endif
@end

//
//  NSData+GQCategory.h
//  ImageViewer
//
//  Created by 高旗 on 16/9/9.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSData (GQImageViewrCategory)

/**
 获取图片资源
 
 @return UIImage *
 */
- (UIImage *)gqImageWithData;

/**
 获取图片种类

 @return 种类字符串
 */
- (NSString *)gqTypeForImageData;

@end

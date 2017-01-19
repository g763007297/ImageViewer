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

+ (UIImage *)gq_imageWithWebPData:(NSData *)data;

#endif

@end

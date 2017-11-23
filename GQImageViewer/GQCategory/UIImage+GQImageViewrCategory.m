//
//  UIImage+GQImageViewrCategory.m
//  ImageViewer
//
//  Created by 高旗 on 17/1/19.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import "UIImage+GQImageViewrCategory.h"

@implementation UIImage (GQImageViewrCategory)

- (CGRect)gq_imageSizeWidthCompareWithSize:(CGSize)size {
    CGSize originSize = size;
    CGSize imageSize = self.size;
    
    CGFloat WScale = imageSize.width / originSize.width;
    
    CGFloat scale = WScale;
    
    CGFloat height = imageSize.height / scale;
    CGFloat width = imageSize.width / scale;
    
    CGRect confirmRect = CGRectMake((size.width - width) / 2,
                                    (size.height > height)?(size.height - height) / 2:0,
                                    width,
                                    height);
    return confirmRect;
}

- (CGRect)gq_imageSizeHeightCompareWithSize:(CGSize)size {
    CGSize originSize = size;
    CGSize imageSize = self.size;
    
    CGFloat HScale = imageSize.height / originSize.height;
    
    CGFloat scale = HScale;
    
    CGFloat height = imageSize.height / scale;
    CGFloat width = imageSize.width / scale;
    
    CGRect confirmRect = CGRectMake( ((size.width > width)?(size.width - width) / 2:0),
                                    (size.height - height)/2,
                                    width,
                                    height);
    return confirmRect;
}

- (CGRect)gq_imageSizeFullyDisplayCompareWithSize:(CGSize)size {
    CGSize originSize = size;
    CGSize imageSize = self.size;
    
    CGFloat HScale = imageSize.height / originSize.height;
    CGFloat WScale = imageSize.width / originSize.width;
    
    CGFloat scale = (HScale > WScale) ? HScale : WScale;
    
    CGFloat height = imageSize.height / scale;
    CGFloat width = imageSize.width / scale;
    
    CGRect confirmRect = CGRectMake((size.width - width) / 2,
                                    (size.height - height)/2,
                                    width,
                                    height);
    return confirmRect;
}

@end

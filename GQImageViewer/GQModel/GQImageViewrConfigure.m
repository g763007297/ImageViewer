//
//  GQImageViewrConfigure.m
//  ImageViewer
//
//  Created by 高旗 on 16/11/30.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQImageViewrConfigure.h"

@implementation GQImageViewrConfigure

+ (instancetype)initWithImageViewBgColor:(UIColor *)imageViewBgColor
                         textViewBgColor:(UIColor *)textViewBgColor
                               textColor:(UIColor *)textColor
                                textFont:(UIFont *)textFont
                           maxTextHeight:(CGFloat )maxTextHeight
                          textEdgeInsets:(UIEdgeInsets)textEdgeInsets
{
    GQImageViewrConfigure *configure = [[[self class] alloc] init];
    configure.imageViewBgColor = imageViewBgColor;
    configure.textViewBgColor = textViewBgColor;
    configure.textColor = textColor;
    configure.textFont = textFont;
    configure.maxTextHeight = maxTextHeight;
    configure.textEdgeInsets = textEdgeInsets;
    
    return configure;
}

@end

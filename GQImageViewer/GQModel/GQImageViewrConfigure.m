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
                               scaleType:(GQImageViewerScaleType)scaleType {
    return [self initWithImageViewBgColor:imageViewBgColor
                          textViewBgColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]
                                textColor:[UIColor whiteColor]
                                 textFont:[UIFont systemFontOfSize:15]
                            maxTextHeight:200
                           textEdgeInsets:UIEdgeInsetsZero
                                scaleType:scaleType];
}

+ (instancetype)initWithImageViewBgColor:(UIColor *)imageViewBgColor
                         textViewBgColor:(UIColor *)textViewBgColor
                               textColor:(UIColor *)textColor
                                textFont:(UIFont *)textFont
                           maxTextHeight:(CGFloat )maxTextHeight
                          textEdgeInsets:(UIEdgeInsets)textEdgeInsets
{
    return [self initWithImageViewBgColor:imageViewBgColor
                          textViewBgColor:textViewBgColor
                                textColor:textColor
                                 textFont:textFont
                            maxTextHeight:maxTextHeight
                           textEdgeInsets:textEdgeInsets
                                scaleType:GQImageViewerScaleTypeFullyDisplay];
}

+ (instancetype)initWithImageViewBgColor:(UIColor *)imageViewBgColor
                         textViewBgColor:(UIColor *)textViewBgColor
                               textColor:(UIColor *)textColor
                                textFont:(UIFont *)textFont
                           maxTextHeight:(CGFloat)maxTextHeight
                          textEdgeInsets:(UIEdgeInsets)textEdgeInsets
                               scaleType:(GQImageViewerScaleType)scaleType {
    GQImageViewrConfigure *configure = [[[self class] alloc] init];
    configure.imageViewBgColor = imageViewBgColor;
    configure.textViewBgColor = textViewBgColor;
    configure.textColor = textColor;
    configure.textFont = textFont;
    configure.maxTextHeight = maxTextHeight;
    configure.textEdgeInsets = textEdgeInsets;
    configure.scaleType = scaleType;
    return configure;
}

@end

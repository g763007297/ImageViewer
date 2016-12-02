//
//  GQImageViewrConfigure.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/30.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQImageViewrBaseObject.h"

@interface GQImageViewrConfigure : GQImageViewrBaseObject

/**
 整体背景颜色
 */
@property (nonatomic, strong) UIColor *imageViewBgColor;

/**
 文字背景颜色
 */
@property (nonatomic, strong) UIColor *textViewBgColor;

/**
 文字颜色
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 字体大小
 */
@property (nonatomic, strong) UIFont *textFont;

/**
 文字最高显示多高
 */
@property (nonatomic, assign) CGFloat maxTextHeight;

/**
 文本相对于父视图的缩进  距离四周的距离  UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
 */
@property (nonatomic, assign) UIEdgeInsets textEdgeInsets;

+ (instancetype)initWithImageViewBgColor:(UIColor *)imageViewBgColor
                         textViewBgColor:(UIColor *)textViewBgColor
                               textColor:(UIColor *)textColor
                                textFont:(UIFont *)textFont
                           maxTextHeight:(CGFloat)maxTextHeight
                          textEdgeInsets:(UIEdgeInsets)textEdgeInsets;

@end

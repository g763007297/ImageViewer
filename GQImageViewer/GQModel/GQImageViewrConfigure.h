//
//  GQImageViewrConfigure.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/30.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQImageViewrBaseObject.h"

typedef enum : NSUInteger {
    GQImageViewerScaleTypeFullyDisplay,//让图片完全显示 (高度宽度等比例缩放到图片能完全显示)
    GQImageViewerScaleTypeEqualWidth, //等宽高度自适应（宽度为屏幕宽度  高度自适应）
    GQImageViewerScaleTypeEqualHeight, //等高宽度自适应（高度为屏幕高度，宽度自适应） //不推荐使用，效果不好
} GQImageViewerScaleType;

@interface GQImageViewrConfigure : GQImageViewrBaseObject

/**
 整体背景颜色
 */
@property (nonatomic, strong) UIColor *imageViewBgColor;

/**
 设置图片的等比例缩放  默认为等高宽度自适应
 */
@property (nonatomic, assign) GQImageViewerScaleType scaleType;

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

//如果没有使用到文字显示就使用这个方法初始化
+ (instancetype)initWithImageViewBgColor:(UIColor *)imageViewBgColor
                               scaleType:(GQImageViewerScaleType)scaleType;

+ (instancetype)initWithImageViewBgColor:(UIColor *)imageViewBgColor
                         textViewBgColor:(UIColor *)textViewBgColor
                               textColor:(UIColor *)textColor
                                textFont:(UIFont *)textFont
                           maxTextHeight:(CGFloat)maxTextHeight
                          textEdgeInsets:(UIEdgeInsets)textEdgeInsets;

+ (instancetype)initWithImageViewBgColor:(UIColor *)imageViewBgColor
                         textViewBgColor:(UIColor *)textViewBgColor
                               textColor:(UIColor *)textColor
                                textFont:(UIFont *)textFont
                           maxTextHeight:(CGFloat)maxTextHeight
                          textEdgeInsets:(UIEdgeInsets)textEdgeInsets
                               scaleType:(GQImageViewerScaleType)scaleType;



@end

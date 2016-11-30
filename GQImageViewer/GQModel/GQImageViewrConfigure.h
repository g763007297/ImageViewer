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

@end

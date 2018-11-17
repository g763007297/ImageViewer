//
//  GQImageViewrConfigure.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/30.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQImageViewrBaseObject.h"

typedef NS_ENUM(NSUInteger, GQLaunchDirection) {
    GQLaunchDirectionBottom = 1,//从下往上推入
    GQLaunchDirectionTop,       //从上往下推入
    GQLaunchDirectionLeft,      //从左往右推入
    GQLaunchDirectionRight,     //从右往左推入
    GQLaunchDirectionFromRect   //从视图位置放大或缩小
};

typedef NS_ENUM(NSUInteger, GQImageViewerScaleType) {
    GQImageViewerScaleTypeFullyDisplay,     //让图片完全显示 (高度宽度等比例缩放到图片能完全显示)
    GQImageViewerScaleTypeEqualWidth,       //等宽高度自适应（宽度为屏幕宽度  高度自适应） 如果超过屏幕高度的长图会影响滑动消失手势，
    GQImageViewerScaleTypeEqualHeight,      //等高宽度自适应（高度为屏幕高度，宽度自适应  超过屏幕高度的长图设置为这个模式不会影响滑动消失手势
};

typedef NS_ENUM(NSUInteger, GQImageViewerCacheType) {
    GQImageViewerCacheTypeNone,         //无缓存，每次都是去请求
    GQImageViewerCacheTypeOnlyMemory,   //缓存在内存
    GQImageViewerCacheTypeDisk,         //保存至硬盘
};

typedef enum {
    GQImageViewerShowIndexTypeNone = 1,        // 不显示下标
    GQImageViewerShowIndexTypePageControl,     // 以pageControl的形式显示
    GQImageViewerShowIndexTypeLabel            // 以文字样式显示
    
}GQImageViewerShowIndexType;

@interface GQImageViewrConfigure : GQImageViewrBaseObject

/*
 *  显示PageControl传yes   默认 : YES
 *  显示label就传no
 */
@property (nonatomic, assign) GQImageViewerShowIndexType showIndexType;

/**
 是否需要循环滚动  默认 : NO
 */
@property (nonatomic, assign) BOOL needLoopScroll;

/**
 是否需要滑动消失手势  默认 : YES
 */
@property (nonatomic, assign) BOOL needPanGesture;

/**
 是否需要点击手势自动隐藏头部和底部视图 （该方法如果设置为yes则单机手势dissmiss会失效） 默认 ： NO
 */
@property (nonatomic, assign) BOOL needTapAutoHiddenTopBottomView;

/**
 *  如果有网络图片则设置默认图片   默认 :  nil
 */
@property (nonatomic, copy) UIImage *placeholderImage;

/**
 自定义图片浏览界面class名称 必须继承GQImageView 需在设置DataSource之前设置 否则没有效果
 */
@property (nonatomic, strong) NSString *imageViewClassName;

/**
 自定义图片请求class名称 必须继承GQImageViewrBaseURLRequest 需在设置DataSource之前设置 否则没有效果
 */
@property (nonatomic, strong) NSString *requestClassName;

/**
 *  推出方向  默认 : GQLaunchDirectionBottom 如果设置为GQLaunchDirectionFromRect 必须设置launchFromView才有效果
 */
@property (nonatomic, assign) GQLaunchDirection laucnDirection;

/**
 推出视图  当设置为GQLaunchDirectionFromRect才有用 默认为nil
 */
@property (nonatomic, weak) UIView  *launchFromView;

/**
 整体背景颜色
 */
@property (nonatomic, strong) UIColor *imageViewBgColor;

/**
 设置图片的等比例缩放  默认为等高宽度自适应
 */
@property (nonatomic, assign) GQImageViewerScaleType scaleType;

/**
 缓存类型  默认：GQImageViewerCacheTypeDisk
 */
@property (nonatomic, assign) GQImageViewerCacheType cacheType;

/**
 文字背景颜色  默认为：[[UIColor blackColor] colorWithAlphaComponent:0.3]
 */
@property (nonatomic, strong) UIColor *textViewBgColor;

/**
 文字颜色   默认为：[UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 字体大小   默认为：[UIFont systemFontOfSize:15]
 */
@property (nonatomic, strong) UIFont *textFont;

/**
 文字最高显示多高  默认为：200
 */
@property (nonatomic, assign) CGFloat maxTextHeight;

/**
 文本相对于父视图的缩进  距离四周的距离  UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)   默认为：UIEdgeInsetsZero
 */
@property (nonatomic, assign) UIEdgeInsets textEdgeInsets;

//如果没有使用到文字显示就使用这个方法配置
- (instancetype)configureWithImageViewBgColor:(UIColor *)imageViewBgColor
                                    scaleType:(GQImageViewerScaleType)scaleType;

- (instancetype)configureWithImageViewBgColor:(UIColor *)imageViewBgColor
                                    scaleType:(GQImageViewerScaleType)scaleType
                                    launchDirection:(GQLaunchDirection)launchDirection;

- (instancetype)configureWithImageViewBgColor:(UIColor *)imageViewBgColor
                              textViewBgColor:(UIColor *)textViewBgColor
                                    textColor:(UIColor *)textColor
                                     textFont:(UIFont *)textFont
                                maxTextHeight:(CGFloat)maxTextHeight
                               textEdgeInsets:(UIEdgeInsets)textEdgeInsets;

- (instancetype)configureWithImageViewBgColor:(UIColor *)imageViewBgColor
                              textViewBgColor:(UIColor *)textViewBgColor
                                    textColor:(UIColor *)textColor
                                     textFont:(UIFont *)textFont
                                maxTextHeight:(CGFloat)maxTextHeight
                               textEdgeInsets:(UIEdgeInsets)textEdgeInsets
                                    scaleType:(GQImageViewerScaleType)scaleType;

- (instancetype)configureWithImageViewBgColor:(UIColor *)imageViewBgColor
                              textViewBgColor:(UIColor *)textViewBgColor
                                    textColor:(UIColor *)textColor
                                     textFont:(UIFont *)textFont
                                maxTextHeight:(CGFloat)maxTextHeight
                               textEdgeInsets:(UIEdgeInsets)textEdgeInsets
                                    scaleType:(GQImageViewerScaleType)scaleType
                              launchDirection:(GQLaunchDirection)launchDirection;

@end


//
//  ImageViewer.h
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQImageViewrConfigure.h"
#import "GQImageViewerConst.h"

typedef enum {
    GQLaunchDirectionBottom = 1,//从下往上推出
    GQLaunchDirectionTop,       //从上往下推出
    GQLaunchDirectionLeft,      //从左往右推出
    GQLaunchDirectionRight      //从右往左推出
}GQLaunchDirection;

typedef void (^GQAchieveIndexBlock)(NSInteger selectIndex);//获取当前图片的index的block
typedef void (^GQLongTapIndexBlock)(UIImage *image ,NSInteger selectIndex);

@class GQImageViewer;

//链式调用block
typedef GQImageViewer * (^GQBOOLChain)(BOOL pageControl);
typedef GQImageViewer * (^GQSubViewChain)(UIView *subView);
typedef GQImageViewer * (^GQPlaceholderImageChain)(UIImage *placeholderImage);
typedef GQImageViewer * (^GQDataSouceArrayChain)(NSArray *imageArray ,NSArray *textArray);
typedef GQImageViewer * (^GQSelectIndexChain)(NSInteger selectIndex);
typedef GQImageViewer * (^GQConfigureChain) (GQImageViewrConfigure *configure);
typedef GQImageViewer * (^GQLaunchDirectionChain)(GQLaunchDirection launchDirection);
typedef GQImageViewer * (^GQAchieveIndexChain)(GQAchieveIndexBlock achieveIndexBlock);
typedef GQImageViewer * (^GQLongTapIndexChain)(GQLongTapIndexBlock longTapIndexBlock);
typedef GQImageViewer * (^GQSingleTapChain)(GQAchieveIndexBlock singleTapBlock);
typedef void (^GQShowViewChain)(UIView *showView, BOOL animation);

@interface GQImageViewer : UIView

#pragma mark -- 链式调用
/**
 *  显示PageControl传yes   type : BOOL
 */
@property (nonatomic, copy, readonly) GQBOOLChain usePageControlChain;

/**
 是否需要循环滚动   Type: BOOL
 */
@property (nonatomic, copy, readonly) GQBOOLChain needLoopScrollChain;

/**
 *  数据源    type : NSArray *
 */
@property (nonatomic, copy, readonly) GQDataSouceArrayChain dataSouceArrayChain;

/**
 *  选中的索引    type : NSInteger
 */
@property (nonatomic, copy, readonly) GQSelectIndexChain selectIndexChain;

/**
 参数配置  type : GQImageViewrConfigure
 */
@property (nonatomic, copy, readonly) GQConfigureChain configureChain;

/**
 *  推出方向  type : GQLaunchDirection
 */
@property (nonatomic, copy, readonly) GQLaunchDirectionChain launchDirectionChain;

/**
 *  显示GQImageViewer到指定view上   type: UIView *
 */
@property (nonatomic, copy, readonly) GQShowViewChain showInViewChain;

/**
 缺省图   type : UIImage *
 */
@property (nonatomic, copy, readonly) GQPlaceholderImageChain placeholderImageChain;

/**
 *  获取当前选中的图片index  type: void (^GQAchieveIndexBlock)(NSInteger selectIndex)
 */
@property (nonatomic, copy, readonly) GQAchieveIndexChain achieveSelectIndexChain;

/**
 *  单击手势  type: void (^GQAchieveIndexBlock)(NSInteger selectIndex)
 */
@property (nonatomic, copy, readonly) GQSingleTapChain singleTapChain;

/**
 *  长按手势  type : void (^GQLongTapIndexBlock)(UIImage *image ,NSInteger selectIndex);
 */
@property (nonatomic, copy, readonly) GQLongTapIndexChain longTapIndexChain;

/**
 滑动手势  type : BOOL
 */
@property (nonatomic, copy, readonly) GQBOOLChain needPanGestureChain;

/**
 底部自定义View type : UIView
 */
@property (nonatomic, copy, readonly) GQSubViewChain bottomViewChain;

/**
 顶部自定义View type : UIView
 */
@property (nonatomic, copy, readonly) GQSubViewChain topViewChain;

#pragma mark -- 普通调用

/**
 *  单例方法
 *
 *  @return GQImageViewer
 */
+ (GQImageViewer *)sharedInstance;

/**
 设置数据源

 @param imageArray 图片数组
 @param textArray 文字数组
 */
- (void)setImageArray:(NSArray *)imageArray textArray:(NSArray *)textArray;

/*
 *  显示PageControl传yes   默认 : yes
 *  显示label就传no
 */
@property (nonatomic, assign) BOOL usePageControl;

/**
 是否需要循环滚动
 */
@property (nonatomic, assign) BOOL needLoopScroll;

/**
 是否需要滑动消失手势
 */
@property (nonatomic, assign) BOOL needPanGesture;

/**
 设置配置
 */
@property (nonatomic, strong) GQImageViewrConfigure *configure;

/**
 *  如果有网络图片则设置默认图片
 */
@property (nonatomic, copy) UIImage *placeholderImage;

/**
 底部UIView   默认为nil
 */
@property (nonatomic, copy) UIView *bottomView;

/**
 底部UIView   默认为nil
 */
@property (nonatomic, copy) UIView *topView;

/**
 *  图片数组
 */
@property (nonatomic, strong, readonly) NSArray *imageArray;

/**
 文字数组
 */
@property (nonatomic, strong, readonly) NSArray *textArray;

/**
 *  获取当前选中的图片index
 */
@property (nonatomic, copy) GQAchieveIndexBlock achieveSelectIndex;

/**
 单击手势
 */
@property (nonatomic, copy) GQAchieveIndexBlock singleTap;

/**
 *  长按手势
 */
@property (nonatomic, copy) GQLongTapIndexBlock longTapIndex;

/**
 *  选中的图片索引
 */
@property (nonatomic, assign) NSInteger selectIndex;

/**
 *  推出方向  默认GQLaunchDirectionBottom
 */
@property (nonatomic, assign) GQLaunchDirection laucnDirection;

/**
 *  显示GQImageViewer到指定view上
 *
 *  @param showView view
 */
- (void)showInView:(UIView *)showView animation:(BOOL)animation;

/**
 *  取消显示
 */
- (void)dissMissWithAnimation:(BOOL)animation;

@end

//
//  ImageViewer.h
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQImageViewrConfigure.h"
#import "UIView+GQImageViewrCategory.h"
#import "GQImageViewerConst.h"

typedef void (^GQAchieveIndexBlock)(NSInteger selectIndex);//获取当前图片的index的block
typedef void (^GQLongTapIndexBlock)(UIImage *image ,NSInteger selectIndex);
typedef void (^GQSubViewConfigureBlock)(UIView *configureView);
typedef void (^GQConfigureBlock)(GQImageViewrConfigure *configure);
typedef void (^GQVoidBlock)(void);

@class GQImageViewer;

//链式调用block
typedef GQImageViewer * (^GQVoidChain)(GQVoidBlock voidBlock);
typedef GQImageViewer * (^GQDataSouceArrayChain)(NSArray *imageArray ,NSArray *textArray);
typedef GQImageViewer * (^GQSelectIndexChain)(NSInteger selectIndex);
typedef GQImageViewer * (^GQConfigureChain) (GQConfigureBlock configure);
typedef GQImageViewer * (^GQSubViewConfigureChain) (GQSubViewConfigureBlock configureBlock);;
typedef GQImageViewer * (^GQAchieveIndexChain)(GQAchieveIndexBlock achieveIndexBlock);
typedef GQImageViewer * (^GQLongTapIndexChain)(GQLongTapIndexBlock longTapIndexBlock);
typedef GQImageViewer * (^GQSingleTapChain)(GQAchieveIndexBlock singleTapBlock);
typedef void (^GQShowViewChain)(UIView *showView, BOOL animation);

@interface GQImageViewer : UIView

#pragma mark -- 链式调用

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
 *  显示GQImageViewer到指定view上   type: UIView *
 */
@property (nonatomic, copy, readonly) GQShowViewChain showInViewChain;

/**
 *  获取当前选中的图片index  type: void (^GQAchieveIndexBlock)(NSInteger selectIndex)
 */
@property (nonatomic, copy, readonly) GQAchieveIndexChain achieveSelectIndexChain;

/**
 *  单击手势  type: void (^GQAchieveIndexBlock)(NSInteger selectIndex)
 */
@property (nonatomic, copy, readonly) GQSingleTapChain singleTapChain;

/**
 配置头部自定义view type : void (^GQSubViewConfigureBlock)(UIView *configureView)
 */
@property (nonatomic, copy, readonly) GQSubViewConfigureChain topViewConfigureChain;

/**
 配置底部自定义view type : void (^GQSubViewConfigureBlock)(UIView *configureView)
 */
@property (nonatomic, copy, readonly) GQSubViewConfigureChain bottomViewConfigureChain;

/**
 *  长按手势  type : void (^GQLongTapIndexBlock)(UIImage *image ,NSInteger selectIndex);
 */
@property (nonatomic, copy, readonly) GQLongTapIndexChain longTapIndexChain;

/**
 视图消失的回调  type  ：GQVoidBlock
 */
@property (nonatomic, copy, readonly) GQVoidChain dissMissChain;

#pragma mark -- 普通调用

/**
 *  单例方法
 *
 *  return GQImageViewer
 */
+ (GQImageViewer *)sharedInstance;

/**
 设置数据源

 param imageArray 图片数组
 param textArray 文字数组
 */
- (void)setImageArray:(NSArray *)imageArray textArray:(NSArray *)textArray;

/**
 设置配置
 */
@property (nonatomic, copy) GQConfigureBlock configure;

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
 * 配置顶部View
 */
@property (nonatomic, copy) GQSubViewConfigureBlock topViewConfigure;

/**
 配置底部View
 */
@property (nonatomic, copy) GQSubViewConfigureBlock bottomViewConfigure;

/**
 单击手势
 */
@property (nonatomic, copy) GQAchieveIndexBlock singleTap;

/**
 *  长按手势
 */
@property (nonatomic, copy) GQLongTapIndexBlock longTapIndex;

/**
 视图消失
 */
@property (nonatomic, copy) GQVoidBlock dissMiss;

/**
 *  选中的图片索引
 */
@property (nonatomic, assign) NSInteger selectIndex;

/**
 是否正在显示
 */
@property (nonatomic, assign, readonly) BOOL isVisible;

/**
 *  显示GQImageViewer到指定view上
 *
 *  param showView view
 */
- (void)showInView:(UIView *)showView animation:(BOOL)animation;

/**
 *  取消显示
 */
- (void)dissMissWithAnimation:(BOOL)animation;

@end

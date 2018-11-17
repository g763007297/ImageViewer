//
//  GQImagePreviewer.h
//  ImageViewer
//
//  Created by tusm on 2018/11/16.
//  Copyright © 2018年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GQImageViewerMacro.h"

#import "GQImageViewrConfigure.h"

#import "GQImageViewerConst.h"

@class GQImagePreviewer;

@protocol GQImagePreviewerDelegate <NSObject>

@optional

/**
 当前选中的index

 @param imageViewer
 @param index
 */
- (void)imageViewer:(GQImagePreviewer *)imageViewer didSelectIndex:(NSInteger)index;

/**
 当前单击的index

 @param imageViewer
 @param index
 */
- (void)imageViewer:(GQImagePreviewer *)imageViewer didSingleTapIndex:(NSInteger)index;

/**
 当前长按的index

 @param imageViewer
 @param index
 @param data
 */
- (void)imageViewer:(GQImagePreviewer *)imageViewer didLongTapIndex:(NSInteger)index data:(id)data;

/**
 配置头部view

 @param imageViewer
 @param configureView
 */
- (void)imageViewer:(GQImagePreviewer *)imageViewer topViewConfigure:(UIView *)topConfigureView;

/**
 配置底部view

 @param imageViewer
 @param configureView
 */
- (void)imageViewer:(GQImagePreviewer *)imageViewer bottomViewConfigure:(UIView *)bttomConfigureView;

/**
 视图消失

 @param imageViewer
 */
- (void)imageViewerDidDissmiss:(GQImagePreviewer *)imageViewer;

@end

@protocol GQImagePreviewerDataSource <NSObject>

@required

/**
 获取数据总个数

 @param imageViewer
 @return 总个数
 */
- (NSInteger)numberOfItemInImageViewer:(GQImagePreviewer *)imageViewer;

/**
 获取制定index的数据

 @param imageViewer
 @param index
 @return 数据
 */
- (nonnull id)imageViewer:(GQImagePreviewer *)imageViewer dataForItemAtIndex:(NSInteger)index;

/**
 配置configure

 @param imageViewer
 @param configure
 */
- (void)imageViewer:(GQImagePreviewer *)imageViewer configure:(GQImageViewrConfigure *)configure;

@optional

/**
 获取指定index的文字 NSAttributedString NSString

 @param imageViewer
 @param index
 @return 可为 NSAttributedString NSString
 */
- (nonnull id)imageViewer:(GQImagePreviewer *)imageViewer textForItemAtIndex:(NSInteger)index;

@end

@interface GQImagePreviewer : UIView

@property (nonatomic, weak) id <GQImagePreviewerDelegate> delegate;

@property (nonatomic, weak) id <GQImagePreviewerDataSource> dataSource;

@property (nonatomic, assign, readonly) NSInteger currentIndex;//当前选中

@property (nonatomic, assign, readonly) BOOL isVisible;//是否正在显示

#pragma mark -- Init Method

/**
 初始化方法

 @return
 */
+ (instancetype)imageViewer;

/**
 初始化方法

 @param index 指定index
 @return
 */
+ (instancetype)imageViewerWithCurrentIndex:(NSInteger)index;

#pragma mark -- Public Method

/**
 滑动到指定index

 param index
 param animation
 */
- (void)scrollToIndex:(NSInteger)index animation:(BOOL)animation;

/**
 刷新数据
 */
- (void)reloadData;

/**
 删除指定的index

 @param index 
 */
- (void)deleteIndex:(NSInteger)index
          animation:(BOOL)animation
           complete:(void (^ _Nullable)(BOOL finished))complete ;

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

//
//  ImageViewer.h
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GQImageViewer;

//链式调用block
typedef GQImageViewer * (^GQUsePageControlChain)(BOOL pageControl);
typedef GQImageViewer * (^GQImageArrayChain)(NSArray *imageArray);
typedef GQImageViewer * (^GQSelectIndexChain)(NSInteger selectIndex);

@interface GQImageViewer : UIView

@property (nonatomic, copy, readonly) GQUsePageControlChain usePageControlChain;

@property (nonatomic, copy, readonly) GQImageArrayChain imageArrayChain;

@property (nonatomic, copy, readonly) GQSelectIndexChain selectIndexChain;

/*
 *  显示PageControl传yes
 *  显示label就传no
 */
@property (nonatomic, assign) BOOL usePageControl;

/**
 *  图片数组
 */
@property (nonatomic, retain) NSArray *imageArray;//图片数组

/**
 *  选中的图片索引
 */
@property(nonatomic,assign) NSInteger selectIndex;

/*显示ImageViewer到指定控制器上*/
- (void)showView:(UIViewController *)viewController;

/**
 *  单例方法
 *
 *  @return GQImageViewer
 */
+ (GQImageViewer *)sharedInstance;

- (void)dissMiss;

@end

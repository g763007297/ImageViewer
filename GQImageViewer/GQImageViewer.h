//
//  ImageViewer.h
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GQLaunchDirectionBottom = 1,//从下往上推出
    GQLaunchDirectionTop,       //从上往下推出
    GQLaunchDirectionLeft,      //从左往右推出
    GQLaunchDirectionRight      //从右往左推出
}GQLaunchDirection;

@class GQImageViewer;

//链式调用block
typedef GQImageViewer * (^GQUsePageControlChain)(BOOL pageControl);
typedef GQImageViewer * (^GQImageArrayChain)(NSArray *imageArray);
typedef GQImageViewer * (^GQSelectIndexChain)(NSInteger selectIndex);
typedef GQImageViewer * (^GQLaunchDirectionChain)(GQLaunchDirection launchDirection) ;
typedef void (^GQShowViewChain)(UIView *showView);

@interface GQImageViewer : UIView

/**
 *  显示PageControl传yes   type : BOOL
 */
@property (nonatomic, copy, readonly) GQUsePageControlChain usePageControlChain;

/**
 *  图片数组    type : NSArray *
 */
@property (nonatomic, copy, readonly) GQImageArrayChain imageArrayChain;

/**
 *  选中的图片索引    type : NSInteger
 */
@property (nonatomic, copy, readonly) GQSelectIndexChain selectIndexChain;

/**
 *  推出方向  type : GQLaunchDirection
 */
@property (nonatomic, copy, readonly) GQLaunchDirectionChain launchDirectionChain;

/**
 *  显示GQImageViewer到指定view上   type: UIView *
 */
@property (nonatomic, copy, readonly) GQShowViewChain showViewChain;

/*
 *  显示PageControl传yes   默认 : yes
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

/**
 *  推出方向  默认GQLaunchDirectionBottom
 */
@property (nonatomic) GQLaunchDirection laucnDirection;

/**
 *  显示GQImageViewer到指定view上
 *
 *  @param showView view
 */
- (void)showInView:(UIView *)showView;

/**
 *  单例方法
 *
 *  @return GQImageViewer
 */
+ (GQImageViewer *)sharedInstance;

/**
 *  取消显示
 */
- (void)dissMiss;

@end

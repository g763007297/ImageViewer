//
//  GQImageViewerModel.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/30.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQImageViewrBaseObject.h"

typedef enum : NSUInteger {
    GGImageViewerScaleTypeEqualHeight, //等高宽度自适应（高度为屏幕高度，宽度自适应）
    GGImageViewerScaleTypeEqualWidth, //等宽高度自适应（宽度为屏幕宽度  高度自适应）
} GGImageViewerScaleType;

@interface GQImageViewerModel : GQImageViewrBaseObject

//图片信息
@property (nonatomic, copy) id imageSource;

/**
 自定义图片浏览界面class名称 必须继承GQImageView
 */
@property (nonatomic, copy) NSString *GQImageViewClassName;

//文字信息
@property (nonatomic, copy) NSString *textSource;

//设置图片的等比例缩放  等宽高度自适应（宽度为屏幕宽度  高度自适应）   等高宽度自适应（高度为屏幕高度，宽度自适应）
@property (nonatomic, assign) GGImageViewerScaleType scaleType;

@end

//
//  PhotoScrollView.h
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQImageViewrConfigure.h"

@class GQImageViewerModel;

@interface GQImageScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, strong) GQImageViewerModel *imageModel;

@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, assign) GQImageViewerCacheType cacheType;

@property (nonatomic, assign) GQImageViewerScaleType scaleType;

@property (nonatomic, copy) void(^singleTap)(void);

@end

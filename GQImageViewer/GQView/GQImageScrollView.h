//
//  PhotoScrollView.h
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQImageViewrConfigure.h"

@interface GQImageScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, strong) id imageModel;

@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, strong) GQImageViewrConfigure *configure;

@property (nonatomic, copy) void(^singleTap)(void);

@end

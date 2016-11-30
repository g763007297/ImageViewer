//
//  PhotoScrollView.h
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GQImageView;

@interface GQImageScrollView : UIScrollView<UIScrollViewDelegate>{
    GQImageView *_imageView;
}

@property (nonatomic, strong) id data;

@property (nonatomic, copy) UIImage *placeholderImage;

@property (nonatomic, copy) void(^singleTap)();

@end

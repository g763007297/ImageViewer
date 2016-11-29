//
//  PhotoScrollView.h
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GQImageView;

@interface GQPhotoScrollView : UIScrollView<UIScrollViewDelegate>{
    GQImageView *_imageView;
}

@property (nonatomic, strong) id data;

@property (nonatomic, assign) NSInteger row;

@property (nonatomic, copy) UIImage *placeholderImage;

@end

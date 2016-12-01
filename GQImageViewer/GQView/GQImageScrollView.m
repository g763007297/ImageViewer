//
//  PhotoScrollView.m
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import "GQImageScrollView.h"
#import "GQImageViewer.h"
#import "GQImageView.h"

#import "GQImageCacheManager.h"

#import "GQImageViewerConst.h"

@interface GQImageScrollView()

@end

@implementation GQImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[GQImageView alloc] initWithFrame:self.bounds];
        //让图片等比例适应图片视图的尺寸
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        //设置最大放大倍数
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 1.0;
        
        //隐藏滚动条
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        self.delegate = self;
        
        //单击手势
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap1];

        //双击放大缩小手势
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        //双击
        tap2.numberOfTapsRequired = 2;
        //手指的数量
        tap2.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tap2];

        //tap1、tap2两个手势同时响应时，则取消tap1手势
        [tap1 requireGestureRecognizerToFail:tap2];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.zoomScale == 1) {
        _imageView.frame = self.bounds;
    }
}

- (void)setSingleTap:(void (^)())singleTap
{
    _singleTap = [singleTap copy];
}

- (void)setData:(id)data
{
    if ([data isKindOfClass:[UIImage class]])
    {
        _imageView.image = data;
    }else if ([data isKindOfClass:[NSString class]]||[data isKindOfClass:[NSURL class]])
    {
        NSURL *imageUrl = data;
        if ([data isKindOfClass:[NSString class]]) {
            imageUrl = [NSURL URLWithString:data];
        }
        [_imageView cancelCurrentImageRequest];
        [_imageView loadImage:imageUrl placeHolder:_placeholderImage complete:nil];
    }else if ([data isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageView = (UIImageView *)data;
        _imageView.image = imageView.image;
    }else
    {
        _imageView.image = nil;
    }
}

#pragma mark - UIScrollView delegate
//返回需要缩放的子视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (tap.numberOfTapsRequired == 1)
    {
        if (self.singleTap) {
            self.singleTap();
        }else {
            [_imageView cancelCurrentImageRequest];
            [[GQImageViewer sharedInstance] dissMissWithAnimation:YES];
        }
    }
    else if(tap.numberOfTapsRequired == 2)
    {
        if (self.zoomScale > 1)
        {
            [self setZoomScale:1 animated:YES];
        } else
        {
            [self setZoomScale:3 animated:YES];
        }
    }
}

- (void)dealloc
{
    [[GQImageCacheManager sharedManager] clearMemoryCache];
    [_imageView cancelCurrentImageRequest];
    _imageView = nil;
}

@end

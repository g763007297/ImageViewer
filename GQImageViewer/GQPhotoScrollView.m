//
//  PhotoScrollView.m
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import "GQPhotoScrollView.h"
#import "GQImageViewer.h"

#import "UIImageView+WebCache.h"

#import "GQImageViewerConst.h"

@interface GQPhotoScrollView()

@end

@implementation GQPhotoScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundColor = [UIColor clearColor];
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

- (void)setData:(id)data
{
    if ([data isKindOfClass:[UIImage class]])
    {
        _imageView.image = data;
    }else if ([data isKindOfClass:[NSString class]]||[data isKindOfClass:[NSURL class]])
    {
        [self downloadeImage:data];
    }else if ([data isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageView = (UIImageView *)data;
        _imageView.image = imageView.image;
    }else
    {
        _imageView.image = nil;
    }
}

- (void)downloadeImage:(id)data{
    NSURL *imageUrl = data;
    if ([data isKindOfClass:[NSString class]]) {
        imageUrl = [NSURL URLWithString:data];
    }
    if (![[_imageView sd_imageURL] isEqual:imageUrl]) {
        [_imageView sd_cancelCurrentImageLoad];
        GQWeakify(self);
        [_imageView sd_setImageWithURL:imageUrl placeholderImage:_placeholderImage?_placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            GQStrongify(self);
            if (self.block) {
                self.block(self.row,image,imageUrl);
            }
        }];
    }
}

- (void)setBlock:(GQDownloaderCompletedBlock)block{
    if (_block) {
        _block = nil;
    }
    _block = [block copy];
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
        [_imageView sd_cancelCurrentImageLoad];
        [[GQImageViewer sharedInstance] dissMiss];
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

@end

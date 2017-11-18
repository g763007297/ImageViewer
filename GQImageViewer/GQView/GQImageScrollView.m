//
//  PhotoScrollView.m
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import "GQImageScrollView.h"
#import "GQImageView.h"
#import "GQImageViewerModel.h"

#import "GQImageCacheManager.h"

#import "GQImageViewerConst.h"

#import "UIImage+GQImageViewrCategory.h"

#import "UIImageView+GQImageViewerCategory.h"

@interface GQImageScrollView(){
    BOOL            _isAddSubView;
}

@property (nonatomic, strong) GQImageView *imageView;

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
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
        
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
        if (_imageView.image) {
            CGRect rect = [self imageViewCompareSize];
            _imageView.frame = rect;
            self.contentSize = rect.size;
        }else
            _imageView.frame = self.bounds;
    }
}

- (void)setSingleTap:(void (^)(void))singleTap
{
    _singleTap = [singleTap copy];
}

- (void)setImageModel:(GQImageViewerModel *)imageModel
{
    _imageModel = imageModel;
    if (!_isAddSubView) {
        [self addSubview:self.imageView];
        _isAddSubView = YES;
    }
    id data = imageModel.imageSource;
    if ([data isKindOfClass:[UIImage class]])
    {
        _imageView.image = data;
    }else if ([data isKindOfClass:[NSString class]]||[data isKindOfClass:[NSURL class]])
    {
        NSURL *imageUrl = data;
        if ([data isKindOfClass:[NSString class]]) {
            imageUrl = [NSURL URLWithString:data];
        }
        [_imageView showLoading];
        GQWeakify(self);
        [_imageView loadImage:imageUrl
             requestClassName:imageModel.GQImageViewURLRequestClassName
                  placeHolder:_placeholderImage
                     progress:^(CGFloat progress) {
                         
                     }
                     complete:^(UIImage *image, NSError *error, NSURL *imageUrl) {
                         GQStrongify(self);
                         [self.imageView hideLoading];
                         [self layoutSubviews];
                     }];
    }else if ([data isKindOfClass:[UIImageView class]])
    {
        UIImageView *imageView = (UIImageView *)data;
        _imageView.image = imageView.image;
    }else
    {
        _imageView.image = nil;
    }
    [self layoutSubviews];
}

#pragma mark - UIScrollView delegate
//返回需要缩放的子视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    if (scale == 1) {
        
        [UIView animateWithDuration:0.3 animations:^{
            _imageView.frame = [self imageViewCompareSize];
        }];
    }else {
        CGFloat gapHeight = (self.frame.size.height - view.frame.size.height);
        CGFloat gapWidth = (self.frame.size.width - view.frame.size.width);
        [UIView animateWithDuration:0.3 animations:^{
            _imageView.frame = CGRectMake((gapWidth > 0 ? gapWidth : 0) / 2, (gapHeight > 0 ? gapHeight : 0) / 2, view.frame.size.width, view.frame.size.height);
        }];
    }
}

- (CGRect)imageViewCompareSize {
    CGRect rect = [_imageView.image gq_imageSizeFullyDisplayCompareWithSize:self.bounds.size];
    
    switch (_scaleType) {
        case GQImageViewerScaleTypeEqualWidth:
        {
            rect = [_imageView.image gq_imageSizeWidthCompareWithSize:self.bounds.size];
            break;
        }
        case GQImageViewerScaleTypeEqualHeight:
        {
            rect = [_imageView.image gq_imageSizeHeightCompareWithSize:self.bounds.size];
            break;
        }
        default:
            break;
    }
    return rect;
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (tap.numberOfTapsRequired == 1)
    {
        if (self.singleTap) {
            self.singleTap();
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

- (GQImageView *)imageView {
    if (!_imageView) {
        _imageView = [[NSClassFromString(_imageModel.GQImageViewClassName) alloc] initWithFrame:self.bounds];
        //让图片等比例适应图片视图的尺寸
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

@end

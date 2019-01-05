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

#import "GQImageViewerConst.h"

#import "UIImage+GQImageViewrCategory.h"
#import "UIView+GQImageViewrCategory.h"

#ifdef GQ_CoreSD
#import "UIImageView+WebCache.h"
#else
    #import "GQImageDownloader.h"
    #import "GQImageCacheManager.h"
#endif

@interface GQImageScrollView(){
    BOOL            _isAddSubView;
}

@property (nonatomic, strong) GQImageView *imageView;

@end

@implementation GQImageScrollView

#pragma mark -- life cycle

+ (void)load {
    if (@available(iOS 11.0, *)){
        [[self appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[GQImageView alloc] initWithFrame:self.bounds];
        //让图片等比例适应图片视图的尺寸
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
        
        self.bounces = NO;
        
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

- (void)dealloc
{
#ifdef GQ_CoreSD
    [_imageView sd_cancelCurrentAnimationImagesLoad];
#else
    [[GQImageCacheManager sharedManager] clearMemoryCache];
    [_imageView cancelCurrentImageRequest];
#endif
    _imageView = nil;
}

#pragma mark -- set method

- (void)setSingleTap:(void (^)(void))singleTap
{
    _singleTap = [singleTap copy];
}

- (void)setImageModel:(id)imageModel
{
    _imageModel = imageModel;
    if (!_isAddSubView) {
        [self addSubview:self.imageView];
        _isAddSubView = YES;
    }
    id data = imageModel;
    if ([data isKindOfClass:[UIImage class]]) {
        _imageView.image = data;
    } else if ([data isKindOfClass:[NSString class]]||[data isKindOfClass:[NSURL class]]) {
        NSURL *imageUrl = data;
        if ([data isKindOfClass:[NSString class]]) {
            imageUrl = [NSURL URLWithString:data];
        }
        [_imageView showLoading];
        GQWeakify(self);
#ifdef GQ_CoreSD
        SDWebImageOptions options = 0;
        switch (self.configure.cacheType) {
            case GQImageViewerCacheTypeDisk:
                break;
            case GQImageViewerCacheTypeNone:
                options = SDWebImageRetryFailed;
                break;
            case GQImageViewerCacheTypeOnlyMemory:
                options = SDWebImageCacheMemoryOnly;
                break;
            default:
                break;
        }
        
        [_imageView sd_setImageWithURL:imageUrl
                      placeholderImage:_placeholderImage
                               options:options
//                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                                  GQStrongify(self);
//                                  self.imageView.progress = receivedSize/expectedSize;
//                              }
                             completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                  GQStrongify(self);
                                  [self.imageView hideLoading];
                                  [self layoutSubviews];
                              }];
#else
        [_imageView loadImage:imageUrl
             requestClassName:self.configure.requestClassName
                    cacheType:(NSInteger)self.configure.cacheType
                  placeHolder:_placeholderImage
                     progress:^(CGFloat progress) {
                         GQStrongify(self);
                         self.imageView.progress = progress;
                     }
                     complete:^(UIImage *image, NSURL *imageUrl,NSError *error) {
                         GQStrongify(self);
                         [self.imageView hideLoading];
                         [self layoutSubviews];
                     }];
#endif
    } else if ([data isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)data;
        _imageView.image = imageView.image;
    } else {
        _imageView.image = nil;
    }
    [self layoutSubviews];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:self.panGestureRecognizer])
    {
        UIView *view = [self.panGestureRecognizer view];
        if (self.zoomScale == 1) {
            //如果scrollview滑动到左边界并且是往左滑
            CGPoint translation = [self.panGestureRecognizer translationInView:view];
            CGPoint velocity = [self.panGestureRecognizer velocityInView:view];
            CGFloat ratio = (fabs(velocity.x)/fabs(velocity.y));
            if (self.contentOffset.y == 0 && ratio < 0.68 && translation.y > 0) {
                return NO;
            } else if (self.contentSize.height - self.contentOffset.y - self.height < 1 && ratio < 0.68 && translation.y < 0 ) {
                return NO;
            }
        }
    }
    return YES;
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
            self->_imageView.frame = [self imageViewCompareSize];
        }];
    }else {
        CGFloat gapHeight = (self.frame.size.height - view.frame.size.height);
        CGFloat gapWidth = (self.frame.size.width - view.frame.size.width);
        [UIView animateWithDuration:0.3 animations:^{
            self->_imageView.frame = CGRectMake((gapWidth > 0 ? gapWidth : 0) / 2, (gapHeight > 0 ? gapHeight : 0) / 2, view.frame.size.width, view.frame.size.height);
        }];
    }
}

- (CGRect)imageViewCompareSize {
    CGRect rect = [_imageView.image gq_imageSizeFullyDisplayCompareWithSize:self.bounds.size];
    
    switch (self.configure.scaleType) {
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
    if (tap.numberOfTapsRequired == 1) {
        if (self.singleTap) {
            self.singleTap();
        }
    }
    else if(tap.numberOfTapsRequired == 2) {
        if (self.zoomScale > 1) {
            [self setZoomScale:1 animated:YES];
        } else {
            [self setZoomScale:3 animated:YES];
        }
    }
}

- (GQImageView *)imageView {
    if (!_imageView) {
        _imageView = [[NSClassFromString(_configure.imageViewClassName) alloc] initWithFrame:self.bounds];
        //让图片等比例适应图片视图的尺寸
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

@end

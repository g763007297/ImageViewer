//
//  GQImageView.m
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageView.h"
#import "GQImageDataDownload.h"
#import "GQImageViewerConst.h"

@interface GQImageView()

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, copy) GQImageCompletionBlock complete;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) GQImageDataDownload *download;

-(void)showLoading;
-(void)hideLoading;

@end

@implementation GQImageView

- (void)dealloc
{
    [self cancelCurrentImageRequest];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.indicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.showLoadingView = NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.indicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.showLoadingView = NO;
    }
    return self;
}

- (void)cancelCurrentImageRequest
{
    [_download cancel];
    [self hideLoading];
}

- (void)loadImage:(NSURL*)url complete:(GQImageCompletionBlock)complete
{
    [self loadImage:url placeHolder:nil complete:complete];
}

- (void)loadImage:(NSURL*)url placeHolder:(UIImage *)placeHolderImage complete:(GQImageCompletionBlock)complete
{
    if(nil == url || [@"" isEqualToString:url.absoluteString] ) {
        return;
    }
    self.complete = [complete copy];
    self.imageUrl = url;
    [self cancelCurrentImageRequest];
    if (self.showLoadingView) {
        [self showLoading];
    }
    self.image = placeHolderImage;
    GQWeakify(self);
    _download = [[GQImageDataDownload alloc]
                 initWithURL:_imageUrl
                 progress:^(CGFloat progress) {
                     
                 }complete:^(NSURL *url, UIImage *image, NSError *error) {
                     GQStrongify(self);
                     self.image = image;
                     if (self.complete) {
                         self.complete(image,error,url);
                     }
                 }];
}

-(void)setIndicatorViewStyle:(UIActivityIndicatorViewStyle)style
{
    _indicatorViewStyle = style;
    [_indicator setActivityIndicatorViewStyle:style];
}

-(void)showLoading
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:_indicatorViewStyle];
        _indicator.center = CGPointMake(self.bounds.origin.x+(self.bounds.size.width/2), self.bounds.origin.y+(self.bounds.size.height/2));
        [_indicator setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
    }
    if (!_indicator.isAnimating||_indicator.hidden) {
        _indicator.hidden = NO;
        if(!_indicator.superview){
            [self addSubview:_indicator];
        }
        [_indicator startAnimating];
    }
}

-(void)hideLoading
{
    if (_indicator) {
        [_indicator stopAnimating];
        _indicator.hidden = YES;
    }
}

@end

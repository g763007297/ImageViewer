//
//  GQImageView.m
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageView.h"
#import "GQImageViewerOperationManager.h"
#import "GQImageViewerConst.h"

@interface GQImageView()

@property (nonatomic, copy) GQImageCompletionBlock complete;
@property (nonatomic, copy) GQImageProgressBlock progress;
@property (nonatomic, strong) id<GQImageViwerOperationDelegate> downloadOperation;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation GQImageView

- (void)dealloc
{
    [self cancelCurrentImageRequest];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self configureImageView];
    self.showLoadingView = YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureImageView];
        self.showLoadingView = YES;
    }
    return self;
}

- (void)configureImageView {
    
}

- (void)cancelCurrentImageRequest
{
    [_downloadOperation cancel];
    _downloadOperation = nil;
    [self hideLoading];
}

- (void)loadImage:(NSURL*)url progress:(GQImageProgressBlock)progress complete:(GQImageCompletionBlock)complete
{
    [self loadImage:url placeHolder:nil progress:progress complete:complete];
}

- (void)loadImage:(NSURL*)url placeHolder:(UIImage *)placeHolderImage progress:(GQImageProgressBlock)progress complete:(GQImageCompletionBlock)complete
{
    if(nil == url || [@"" isEqualToString:url.absoluteString] ) {
        return;
    }
    self.complete = [complete copy];
    self.progress = [progress copy];
    self.imageUrl = url;
    [self cancelCurrentImageRequest];
    
    if (self.showLoadingView) {
        [self showLoading];
    }
    
    self.image = placeHolderImage;
    GQWeakify(self);
    _downloadOperation = [[GQImageViewerOperationManager sharedManager]
                 loadWithURL:_imageUrl
                 progress:^(CGFloat progress) {
                     GQStrongify(self);
                     if (self.progress) {
                         self.progress(progress);
                     }
                 }complete:^(NSURL *url, UIImage *image, NSError *error) {
                     GQStrongify(self);
                     [self hideLoading];
                     if (image) {
                         self.image = image;
                     }
                     if (self.complete) {
                         self.complete(image,error,url);
                     }
                 }];
}

-(void)showLoading
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
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

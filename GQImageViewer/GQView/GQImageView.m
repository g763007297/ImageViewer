//
//  GQImageView.m
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageView.h"
#import "GQImageViewerConst.h"

@interface GQImageView()

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation GQImageView

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

-(void)showLoading
{
    if (!self.showLoadingView) {
        return;
    }
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
    if (!self.showLoadingView) {
        return;
    }
    if (_indicator) {
        [_indicator stopAnimating];
        _indicator.hidden = YES;
    }
}

@end

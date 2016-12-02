//
//  GQTextScrollView.m
//  ImageViewer
//
//  Created by 高旗 on 16/11/30.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQTextScrollView.h"
#import "NSString+GQImageViewrCategory.h"
#import "GQImageViewrConfigure.h"
#import "GQImageViewerModel.h"

static NSInteger pageNumberTag = 10086;

static const CGFloat maxTextHight = 200;

@interface GQTextScrollView(){
    CGFloat _textHeight;
    UIColor *_textColor;
    UIFont *_textFont;
    CGFloat _maxHeight;
    UIEdgeInsets _textEdgeInsets;
    NSInteger _pageNumber;
}

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UILabel *pageLabel;

@end

@implementation GQTextScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.textLabel];
        [self addSubview:self.pageControl];
        [self addSubview:self.pageLabel];
        
        //设置最大放大倍数
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 1.0;
        
        self.scrollEnabled = YES;
        
        //隐藏滚动条
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        self.delegate = self;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentSize = CGSizeMake(self.bounds.size.width, _textHeight + _textEdgeInsets.top + _textEdgeInsets.bottom);
    _pageControl.frame = CGRectMake(0, 0, self.bounds.size.width, 10);
    _textLabel.frame = CGRectMake(_textEdgeInsets.left, _textEdgeInsets.top, self.bounds.size.width - _textEdgeInsets.left - _textEdgeInsets.right, _textHeight);
    _pageLabel.frame = CGRectMake(0, 0, self.bounds.size.width, self.frame.size.height);
}

- (CGFloat)configureSource:(NSArray <GQImageViewerModel*>*)source
           withConfigure:(GQImageViewrConfigure *)configure
        withCurrentIndex:(NSInteger)currentIndex
          usePageControl:(BOOL)usePageControl
{
    
    UIFont *textFont = configure.textFont?:[UIFont systemFontOfSize:15];
    if (![_textFont isEqual:textFont]) {
        _textFont = textFont;
        _textLabel.font = _textFont;
    }
    
    NSString *text = source[currentIndex].textSource;
    if (![_text isEqual:text]) {
        _text = [text copy];
        _textLabel.text = _text;
    }
    
    UIColor *textColor = configure.textColor?:[UIColor whiteColor];
    if (![_textColor isEqual:textColor]) {
        _textColor = textColor;
        _textLabel.textColor = _textColor;
    }
    
    CGFloat maxHeight = configure.maxTextHeight?:maxTextHight;
    if (_maxHeight != maxHeight) {
        _maxHeight = maxHeight;
    }
    
    NSInteger pageNumber = [source count];
    if (_pageNumber != pageNumber) {
        _pageNumber = pageNumber;
        _pageControl.numberOfPages = pageNumber;
    }
    
    if (!UIEdgeInsetsEqualToEdgeInsets(configure.textEdgeInsets, UIEdgeInsetsZero)&&
        !UIEdgeInsetsEqualToEdgeInsets(_textEdgeInsets, configure.textEdgeInsets)) {
        _textEdgeInsets = configure.textEdgeInsets;
    }
    
    self.backgroundColor = configure.textViewBgColor?:[[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    CGFloat height = [text textSizeWithFont:textFont withcSize:CGSizeMake(self.bounds.size.width - _textEdgeInsets.left - _textEdgeInsets.right, MAXFLOAT)].height;
    CGFloat scolleViewHeight = height + _textEdgeInsets.top + _textEdgeInsets.bottom;
    if (scolleViewHeight >_maxHeight) {
        scolleViewHeight = _maxHeight;
    }
    
    _textHeight = height;
    
    if (_text) {
        [_pageLabel setHidden:YES];
        [_pageControl setHidden:YES];
        [_textLabel setHidden:NO];
    }else {
        if (usePageControl) {
            _pageControl.currentPage = currentIndex;
            scolleViewHeight = 10;
            [_pageLabel setHidden:YES];
            [_pageControl setHidden:NO];
            [_textLabel setHidden:YES];
        }else {
            scolleViewHeight = 20;
            _pageLabel.text = [NSString stringWithFormat:@"%zd/%zd",(currentIndex+1),pageNumber];
            [_pageLabel setHidden:NO];
            [_pageControl setHidden:YES];
            [_textLabel setHidden:YES];
        }
    }
    
    [self setContentOffset:CGPointZero animated:NO];
    [self setNeedsLayout];
    return scolleViewHeight;
}

#pragma mark -- lazy load

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.tag = pageNumberTag;
        [_pageControl setHidden:YES];
    }
    return _pageControl;
}

- (UILabel *)pageLabel {
    if (!_pageLabel){
        _pageLabel = [[UILabel alloc] init];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.tag = pageNumberTag;
        [_pageLabel setHidden:YES];
        _pageLabel.textColor = [UIColor whiteColor];
    }
    return _pageLabel;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textEdgeInsets = UIEdgeInsetsMake(0, 5, 10, 5);
        _textLabel = [[UILabel alloc] init];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (void)dealloc {
    _pageControl = nil;
    _textLabel = nil;
    _pageLabel = nil;
}

@end

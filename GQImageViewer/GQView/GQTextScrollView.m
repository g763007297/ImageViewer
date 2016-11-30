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

static const CGFloat maxTextHight = 100;

@interface GQTextScrollView(){
    CGFloat textHeight;
    UIColor *_textColor;
    UIFont *_textFont;
    CGFloat _maxHeight;
}

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UILabel *pageLabel;

@end

@implementation GQTextScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _textLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _textLabel.numberOfLines = 0;
        //让图片等比例适应图片视图的尺寸
        [self addSubview:_textLabel];
        
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentSize = CGSizeMake(self.bounds.size.width, textHeight);
    _textLabel.frame = CGRectMake(5, 0, self.bounds.size.width - 10, textHeight);
    _pageLabel.frame = CGRectMake(0, 0, self.bounds.size.width, textHeight);
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
    
    CGFloat maxHeight = configure.maxTextHeight>0?:maxTextHight;
    if (_maxHeight != maxHeight) {
        _maxHeight = maxHeight;
    }
    
    NSInteger pageNumber = [source count];
    if (_pageNumber != pageNumber) {
        _pageNumber = pageNumber;
        _pageControl.numberOfPages = pageNumber;
    }
    
    CGFloat height = [text textSizeWithFont:textFont withcSize:CGSizeMake(self.bounds.size.width - 10, MAXFLOAT)].height + 10;
    CGFloat scolleViewHeight = height;
    if (height >maxHeight) {
        scolleViewHeight = maxHeight;
    }
    
    textHeight = height;
    
    if (_text) {
        [_pageLabel setHidden:YES];
        [_pageControl setHidden:YES];
        [_textLabel setHidden:NO];
    }else {
        if (usePageControl) {
            _pageControl.currentPage = currentIndex;
            textHeight = 10;
            [_pageLabel setHidden:YES];
            [_pageControl setHidden:NO];
            [_textLabel setHidden:YES];
        }else {
            textHeight = 15;
            _pageLabel.text = [NSString stringWithFormat:@"%zd/%zd",(currentIndex+1),pageNumber];
            [_pageLabel setHidden:NO];
            [_pageControl setHidden:YES];
            [_textLabel setHidden:YES];
        }
    }
    
    return scolleViewHeight;
}

#pragma mark -- lazy load

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
        _pageControl.numberOfPages = _pageNumber;
        _pageControl.tag = pageNumberTag;
        [_pageControl setHidden:YES];
        [self insertSubview:_pageControl atIndex:1];
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
        [self insertSubview:_pageLabel atIndex:1];
    }
    return _pageLabel;
}

@end

//
//  ImageViewer.m
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import "GQImageViewer.h"
#import "GQPhotoTableView.h"

#define GQChainObjectDefine(_key_name_,_Chain_, _type_ , _block_type_)\
- (_block_type_)_key_name_{\
    __weak typeof(self) weakSelf = self;\
    if (!_##_key_name_) {\
        _##_key_name_ = ^(_type_ value){\
        __strong typeof(weakSelf) strongSelf = weakSelf;\
        _##_Chain_ = value;\
        return strongSelf;\
        };\
    }\
    return _##_key_name_;\
}\

static NSInteger pageNumberTag = 10086;

@interface GQImageViewer(){
    GQPhotoTableView *_tableView;
    UIPageControl *_pageControl;
    UILabel *_pageLabel;
    CGRect superViewRect;
}

@property (nonatomic, assign) BOOL isVisible;

@end

@implementation GQImageViewer

__strong static GQImageViewer *imageViewerManager;

+ (GQImageViewer *)sharedInstance {
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        imageViewerManager = [[super allocWithZone:nil] init];
    });
    return imageViewerManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone*)zone {
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    NSAssert(!imageViewerManager, @"init method can't call");
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }
    return self;
}

@synthesize usePageControlChain = _usePageControlChain;
@synthesize imageArrayChain =_imageArrayChain;
@synthesize selectIndexChain = _selectIndexChain;

GQChainObjectDefine(usePageControlChain, usePageControl, BOOL, GQUsePageControlChain);
GQChainObjectDefine(imageArrayChain, imageArray, NSArray *, GQImageArrayChain);
GQChainObjectDefine(selectIndexChain, selectIndex, NSInteger, GQSelectIndexChain);

- (void)setUsePageControl:(BOOL)usePageControl{
    _usePageControl = usePageControl;
    [self updateNumberView];
}

- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = [imageArray copy];
    NSAssert([_imageArray count] > 0, @"imageArray count must be greater than zero");
    _tableView.imageArray = _imageArray;
    if (_selectIndex>[imageArray count]-1&&[_imageArray count]>0) {
        _selectIndex = [imageArray count]-1;
        [self updatePageNumber];
        [self scrollToSettingIndex];
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex{
    _selectIndex = selectIndex;
    NSAssert(selectIndex>=0, @"_selectIndex must be greater than zero");
    NSAssert([_imageArray count] > 0, @"imageArray count must be greater than zero");
    if (selectIndex>[_imageArray count]-1) {
        _selectIndex = [_imageArray count]-1;
    }else if (selectIndex < 0){
        _selectIndex = 0;
    }
    [self updatePageNumber];
    [self scrollToSettingIndex];
}

- (void)initViewWithFrame:(CGRect)rect{
    
    [self updateNumberView];
    
    _tableView = [[GQPhotoTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect)) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    __weak typeof(self) weakSelf = self;
    _tableView.block = ^(NSInteger index){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_selectIndex = index;
        [strongSelf updatePageNumber];
    };
    _tableView.rowHeight = CGRectGetWidth(rect);
    [self insertSubview:_tableView belowSubview:_pageControl?_pageControl:_pageLabel];
    
    _tableView.pagingEnabled  = YES;
    
    //将所有的图片url赋给tableView显示
    _tableView.imageArray = _imageArray;
    
    [self scrollToSettingIndex];
}

- (void)updateNumberView{
    
    [[self viewWithTag:pageNumberTag] removeFromSuperview];
    
    if (_usePageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(superViewRect)-10, 0, 10)];
        _pageControl.numberOfPages = _imageArray.count;
        _pageControl.tag = pageNumberTag;
        _pageControl.currentPage = _selectIndex;
        [self insertSubview:_pageControl atIndex:1];
    }else{
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(superViewRect)/2 - 30, CGRectGetHeight(superViewRect) - 20, 60, 15)];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.tag = pageNumberTag;
        _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",(_selectIndex+1),_imageArray.count];
        _pageLabel.textColor = [UIColor darkGrayColor];
        [self insertSubview:_pageLabel atIndex:1];
    }
    [self updatePageNumber];
}

- (void)updatePageNumber{
    if (_usePageControl) {
        _pageControl.currentPage = self.selectIndex;
    }else{
        _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",(_selectIndex+1),_imageArray.count];
    }
}

- (void)scrollToSettingIndex{
    //滚动到指定的单元格
    if (_tableView) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectIndex inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)showView:(UIViewController *)viewController{
    if (_isVisible) {
        return;
    }else{
        _isVisible = YES;
    }
    
    UIView *showView = viewController.navigationController.view?viewController.navigationController.view:viewController.view;
    
    superViewRect = CGRectMake(0, 0, CGRectGetMaxX(showView.frame), CGRectGetMaxY(showView.frame));
    
    [self initViewWithFrame:superViewRect];
    
    self.frame = CGRectMake(0, CGRectGetMaxY(showView.frame), CGRectGetMaxX(showView.frame), CGRectGetMaxY(showView.frame));
    
    [showView addSubview:self];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = superViewRect;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)dissMiss{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, CGRectGetMaxY(self.frame), CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
                     } completion:^(BOOL finished) {
                         [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                         self.frame = CGRectZero;
                         [self removeFromSuperview];
                         _isVisible = NO;
                     }];
}

@end

//
//  ImageViewer.m
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import "GQImageViewer.h"
#import "GQPhotoTableView.h"
#import "GQImageViewerConst.h"

#import "GQImageCacheManager.h"

static NSInteger pageNumberTag = 10086;

@interface GQImageViewer()
{
    GQPhotoTableView *_tableView;//tableview
    UIPageControl *_pageControl;//页码显示control
    UILabel *_pageLabel;//页码显示label
    CGRect _superViewRect;//superview的rect
    CGRect _initialRect;//初始化rect
    UILongPressGestureRecognizer *longTap;//长按手势
}

@property (nonatomic, assign) BOOL isVisible;//是否正在显示

@end

@implementation GQImageViewer

GQOBJECT_SINGLETON_BOILERPLATE(GQImageViewer, sharedInstance)

//初始化，不可重复调用
- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(!zsharedInstance, @"init method can't call");
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self setClipsToBounds:YES];
        self.laucnDirection = GQLaunchDirectionBottom;
        self.usePageControl = YES;
    }
    return self;
}

@synthesize usePageControlChain = _usePageControlChain;
@synthesize imageArrayChain =_imageArrayChain;
@synthesize selectIndexChain = _selectIndexChain;
@synthesize showViewChain = _showViewChain;
@synthesize launchDirectionChain = _launchDirectionChain;
@synthesize achieveSelectIndexChain = _achieveSelectIndexChain;
@synthesize longTapIndexChain = _longTapIndexChain;

GQChainObjectDefine(usePageControlChain, UsePageControl, BOOL, GQUsePageControlChain);
GQChainObjectDefine(imageArrayChain, ImageArray, NSArray *, GQImageArrayChain);
GQChainObjectDefine(selectIndexChain, SelectIndex, NSInteger, GQSelectIndexChain);
GQChainObjectDefine(launchDirectionChain, LaucnDirection, GQLaunchDirection, GQLaunchDirectionChain);
GQChainObjectDefine(achieveSelectIndexChain, AchieveSelectIndex, GQAchieveIndexBlock, GQAchieveIndexChain);
GQChainObjectDefine(longTapIndexChain, LongTapIndex, GQLongTapIndexBlock, GQLongTapIndexChain);

- (GQShowViewChain)showViewChain
{
    if (!_showViewChain) {
        GQWeakify(self);
        _showViewChain = ^(UIView *showView){
            GQStrongify(self);
            [self showInView:showView];
        };
    }
    return _showViewChain;
}

#pragma mark -- set method

- (void)setUsePageControl:(BOOL)usePageControl
{
    _usePageControl = usePageControl;
    [self updateNumberView];
}

- (void)setImageArray:(NSArray *)imageArray
{
    _imageArray = [[self handleImageUrlArray:imageArray] copy];
    if (!_isVisible) {
        return;
    }
    
    NSAssert([_imageArray count] > 0, @"imageArray count must be greater than zero");
    
    _tableView.imageArray = [_imageArray copy];
    
    if (_selectIndex>[imageArray count]-1&&[_imageArray count]>0){
        _selectIndex = [imageArray count]-1;
        
        [self updatePageNumber];
        [self scrollToSettingIndex];
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    if (!_isVisible) {
        return;
    }
    
    NSAssert(selectIndex>=0, @"_selectIndex must be greater than zero");
    NSAssert([_imageArray count] > 0, @"imageArray count must be greater than zero");
    
    if (selectIndex>[_imageArray count]-1){
        _selectIndex = [_imageArray count]-1;
    }else if (selectIndex < 0){
        _selectIndex = 0;
    }
    
    [self updatePageNumber];
    [self scrollToSettingIndex];
}

- (void)setLongTapIndex:(GQLongTapIndexBlock)longTapIndex
{
    _longTapIndex = [longTapIndex copy];
    
    if (_longTapIndex) {
        //长按手势
        longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
        [self addGestureRecognizer:longTap];
    }
}

- (void)showInView:(UIView *)showView
{
    if ([_imageArray count]==0) {
        return;
    }
    
    if (_isVisible) {
        [self dissMiss];
        return;
    }else{
        _isVisible = YES;
    }
    
    //设置superview的rect
    _superViewRect = showView.bounds;
    
    //初始化子view
    [self initSubViews];
    
    //更新初始化rect
    [self updateInitialRect];
    
    //设置初始值
    self.alpha = 0;
    self.frame = _initialRect;
    
    [showView addSubview:self];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 1;
                         self.frame = _superViewRect;
                     }];
}

//view消失
- (void)dissMiss
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.alpha = 0;
                         self.frame = _initialRect;
                     } completion:^(BOOL finished) {
                         [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                         [self removeFromSuperview];
                         _tableView = nil;
                         _isVisible = NO;
                     }];
}

#pragma mark -- privateMethod
//屏幕旋转通知
- (void)statusBarOrientationChange:(NSNotification *)noti{
    if (_isVisible) {
        _superViewRect = self.superview.bounds;
        [self orientationChange];
    }
}

//屏幕旋转调整frame
- (void)orientationChange{
    [_tableView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_tableView removeFromSuperview];
    _tableView = nil;
    [self initSubViews];
    self.frame = _superViewRect;
    [self updateInitialRect];
}

//初始化子view
- (void)initSubViews
{
    [self updateNumberView];
    if (!_tableView) {
        _tableView = [[GQPhotoTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_superViewRect) ,CGRectGetHeight(_superViewRect)) style:UITableViewStylePlain];
        GQWeakify(self);
        _tableView.block = ^(NSInteger index){
            GQStrongify(self);
            self->_selectIndex = index;
            [self updatePageNumber];
        };
        _tableView.rowHeight = CGRectGetWidth(_superViewRect);
        _tableView.pagingEnabled  = YES;
    }
    [self insertSubview:_tableView atIndex:0];
    
    //将所有的图片url赋给tableView显示
    _tableView.imageArray = [_imageArray copy];
    
    [self scrollToSettingIndex];
}

//更新初始化rect
- (void)updateInitialRect{
    switch (_laucnDirection) {
        case GQLaunchDirectionBottom:{
            _initialRect = CGRectMake(0, CGRectGetHeight(_superViewRect), CGRectGetWidth(_superViewRect), 0);
            break;
        }
        case GQLaunchDirectionTop:{
            _initialRect = CGRectMake(0, 0, CGRectGetWidth(_superViewRect), 0);
            break;
        }
        case GQLaunchDirectionLeft:{
            _initialRect = CGRectMake(0, 0, 0, CGRectGetHeight(_superViewRect));
            break;
        }
        case GQLaunchDirectionRight:{
            _initialRect = CGRectMake(CGRectGetWidth(_superViewRect), 0, 0, CGRectGetHeight(_superViewRect));
            break;
        }
        default:
            break;
    }
}

//更新页面显示view
- (void)updateNumberView
{
    [[self viewWithTag:pageNumberTag] removeFromSuperview];
    
    if (_usePageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_superViewRect)-10, 0, 10)];
        _pageControl.numberOfPages = _imageArray.count;
        _pageControl.tag = pageNumberTag;
        _pageControl.currentPage = _selectIndex;
        [self insertSubview:_pageControl atIndex:1];
    }else{
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_superViewRect)/2 - 30, CGRectGetHeight(_superViewRect) - 20, 60, 15)];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        _pageLabel.tag = pageNumberTag;
        _pageLabel.text = [NSString stringWithFormat:@"%zd/%zd",(_selectIndex+1),_imageArray.count];
        _pageLabel.textColor = [UIColor whiteColor];
        [self insertSubview:_pageLabel atIndex:1];
    }
    [self updatePageNumber];
}

//更新页码
- (void)updatePageNumber
{
    if (self.achieveSelectIndex) {
        self.achieveSelectIndex(_selectIndex);
    }
    if (_usePageControl) {
        _pageControl.currentPage = self.selectIndex;
    }else{
        _pageLabel.text = [NSString stringWithFormat:@"%zd/%zd",(_selectIndex+1),_imageArray.count];
    }
}

- (void)scrollToSettingIndex
{
    //滚动到指定的单元格
    if (_tableView) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectIndex inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

//图片处理
- (NSArray *)handleImageUrlArray:(NSArray *)imageURlArray{
    NSMutableArray *handleImages = [[NSMutableArray alloc] initWithCapacity:[imageURlArray count]];
    for (id imageObject in imageURlArray) {
        id handleImageUrl = imageObject;
        if ([imageObject isKindOfClass:[NSString class]]) {
            handleImageUrl = [NSURL URLWithString:imageObject];
        }
        [handleImages addObject:handleImageUrl];
    }
    return handleImages;
}

//清除通知，防止崩溃
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark -- 长按手势响应处理
- (void)longTapAction:(UILongPressGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateBegan)
    {
        if (_longTapIndex)
        {
            if ([_imageArray count] > _selectIndex)
            {
                id imageData = _imageArray[_selectIndex];
                UIImage *image;
                if ([imageData isKindOfClass:[NSString class]]||[imageData isKindOfClass:[NSURL class]])
                {
                    if ([imageData isKindOfClass:[NSURL class]])
                    {
                        imageData = ((NSURL *)imageData).absoluteString;
                    }
                    if ([[GQImageCacheManager sharedManager] isImageInMemoryCacheWithUrl:imageData])
                    {
                        image = [[GQImageCacheManager sharedManager] getImageFromCacheWithUrl:imageData];
                    }
                }else if ([imageData isKindOfClass:[UIImageView class]])
                {
                    image = ((UIImageView *)imageData).image;
                }else
                {
                    image = imageData;
                }
                _longTapIndex(image,_selectIndex);
            }
        }
    }
}

@end

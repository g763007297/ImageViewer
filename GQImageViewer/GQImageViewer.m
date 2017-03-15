//
//  ImageViewer.m
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import "GQImageViewer.h"
#import "GQImageCollectionView.h"
#import "GQTextScrollView.h"
#import "GQImageViewerConst.h"

#import "GQImageCacheManager.h"
#import "GQImageViewerModel.h"

#import "UIView+GQImageViewrCategory.h"

@interface GQImageViewer()<GQCollectionViewDelegate,GQCollectionViewDataSource,UIGestureRecognizerDelegate>
{
    CGRect _superViewRect;//superview的rect
    CGRect _initialRect;//初始化rect
    CGFloat _bottomBgViewY;
    BOOL interation;
}

@property (nonatomic, strong) GQTextScrollView *textScrollView;
@property (nonatomic, strong) UIView *bottomBgView;
@property (nonatomic, strong) GQImageCollectionView *collectionView;//collectionView
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UILongPressGestureRecognizer *longTapGesture;//长按手势
@property (nonatomic, strong) NSArray <GQImageViewerModel *>*dataSources;//数据源

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
        self.needLoopScroll = NO;
    }
    return self;
}

//清除通知，防止崩溃
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

@synthesize usePageControlChain = _usePageControlChain;
@synthesize needLoopScrollChain = _needLoopScrollChain;
@synthesize dataSouceArrayChain =_dataSouceArrayChain;
@synthesize selectIndexChain = _selectIndexChain;
@synthesize configureChain = _configureChain;
@synthesize showInViewChain = _showInViewChain;
@synthesize launchDirectionChain = _launchDirectionChain;
@synthesize placeholderImageChain = _placeholderImageChain;
@synthesize achieveSelectIndexChain = _achieveSelectIndexChain;
@synthesize singleTapChain = _singleTapChain;
@synthesize longTapIndexChain = _longTapIndexChain;
@synthesize needPanGestureChain = _needPanGestureChain;
@synthesize bottomViewChain = _bottomViewChain;
@synthesize topViewChain = _topViewChain;

GQChainObjectDefine(usePageControlChain, UsePageControl, BOOL, GQBOOLChain);
GQChainObjectDefine(needLoopScrollChain, NeedLoopScroll, BOOL, GQBOOLChain);
GQChainObjectDefine(selectIndexChain, SelectIndex, NSInteger, GQSelectIndexChain);
GQChainObjectDefine(configureChain, Configure, GQImageViewrConfigure*, GQConfigureChain);
GQChainObjectDefine(placeholderImageChain, PlaceholderImage, UIImage *, GQPlaceholderImageChain);
GQChainObjectDefine(launchDirectionChain, LaucnDirection, GQLaunchDirection, GQLaunchDirectionChain);
GQChainObjectDefine(achieveSelectIndexChain, AchieveSelectIndex, GQAchieveIndexBlock, GQAchieveIndexChain);
GQChainObjectDefine(singleTapChain, SingleTap, GQAchieveIndexBlock, GQAchieveIndexChain);
GQChainObjectDefine(longTapIndexChain, LongTapIndex, GQLongTapIndexBlock, GQLongTapIndexChain);
GQChainObjectDefine(needPanGestureChain, NeedPanGesture, BOOL, GQBOOLChain);
GQChainObjectDefine(bottomViewChain, BottomView, UIView *, GQSubViewChain);
GQChainObjectDefine(topViewChain, TopView, UIView *, GQSubViewChain);

- (GQShowViewChain)showInViewChain
{
    if (!_showInViewChain) {
        GQWeakify(self);
        _showInViewChain = ^(UIView *showView, BOOL animation){
            GQStrongify(self);
            [self showInView:showView animation:animation];
        };
    }
    return _showInViewChain;
}

- (GQDataSouceArrayChain)dataSouceArrayChain
{
    if (!_dataSouceArrayChain) {
        GQWeakify(self);
        _dataSouceArrayChain = ^(NSArray *imageArray ,NSArray *textArray){
            GQStrongify(self);
            [self setImageArray:imageArray textArray:textArray];
            return self;
        };
    }
    return _dataSouceArrayChain;
}

#pragma mark -- set method

- (void)resetConfigure {
    _selectIndex = 0;
    _imageArray = nil;
    _textArray = nil;
    _dataSources = nil;
    _bottomBgView = nil;
    _bottomView = nil;
    _topView = nil;
    _collectionView = nil;
    _textScrollView = nil;
    _collectionView.gqDelegate = nil;
    _collectionView.gqDataSource = nil;
    _isVisible = NO;
}

- (void)setUsePageControl:(BOOL)usePageControl
{
    _usePageControl = usePageControl;
    [self setupTextScrollView];
}

- (void)setNeedLoopScroll:(BOOL)needLoopScroll
{
    _needLoopScroll = needLoopScroll;
    if (!_isVisible) {
        return;
    }
    _collectionView.needLoopScroll = _needLoopScroll;
}

- (void)setNeedPanGesture:(BOOL)needPanGesture {
    _needPanGesture = needPanGesture;
    if (_needPanGesture) {
        [self.panGesture setEnabled:YES];
    }else {
        [self.panGesture setEnabled:NO];
    }
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    if (!_isVisible) {
        return;
    }
    _collectionView.placeholderImage = placeholderImage;
}

- (void)setBottomView:(UIView *)bottomView {
    _bottomView = bottomView;
    if (!_isVisible) {
        return;
    }
    [self setupTextScrollView];
}

- (void)setTopView:(UIView *)topView {
    _topView = topView;
    if (!_isVisible) {
        return;
    }
    [self setupTextScrollView];
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    
    if (!_isVisible) {
        return;
    }
    
    NSAssert(selectIndex>=0, @"_selectIndex must be greater than zero");
    NSAssert([_imageArray count] > 0, @"imageArray count must be greater than zero");
    
    [self setupTextScrollView];
    [self scrollToSettingIndex];
}

- (void)setImageArray:(NSArray *)imageArray textArray:(NSArray *)textArray
{
    _textArray = [textArray copy];
    _imageArray = [imageArray copy];
    if ([_textArray count] > 0) {
        NSAssert([_textArray count] == [_imageArray count], @"imageArray count must be equal to textArray");
    }
    NSAssert([_imageArray count] > 0, @"imageArray count must be greater than zero");
    
    _dataSources = [self handleImageUrlArray:_imageArray withTextArray:_textArray];
    
    if (!_isVisible) {
        return;
    }
    
    if (_selectIndex>[imageArray count]-1&&[_imageArray count]>0){
        _selectIndex = [imageArray count]-1;
        
        [self setupTextScrollView];
        [self scrollToSettingIndex];
    }
}

- (void)setConfigure:(GQImageViewrConfigure *)configure
{
    _configure = [configure copy];
    self.backgroundColor = self.configure.imageViewBgColor?:[UIColor clearColor];
}

- (void)setLongTapIndex:(GQLongTapIndexBlock)longTapIndex
{
    _longTapIndex = [longTapIndex copy];
    
    if (_longTapIndex) {
        //长按手势
        [self addGestureRecognizer:self.longTapGesture];
    }
}

#pragma mark -- GQCollectionViewDataSource

- (NSInteger)totalPagesInGQCollectionView:(GQBaseCollectionView *)collectionView {
    return [self.dataSources count];
}

- (GQImageViewerModel *)GQCollectionView:(GQBaseCollectionView *)collectionView dataSourceInIndex:(NSInteger)index {
    return self.dataSources[index];
}

- (GQImageViewrConfigure *)configureOfGQCollectionView:(GQBaseCollectionView *)collectionView {
    return _configure;
}

#pragma mark -- GQCollectionViewDelegate

- (void)GQCollectionViewDidSigleTap:(GQBaseCollectionView *)collectionView withCurrentSelectIndex:(NSInteger)index
{
    if (_singleTap||[_textArray count] > 0) {
        if (self.singleTap) {
            self.singleTap(self.selectIndex);
        }
        if ([_textArray count] > 0) {
            if (self->_bottomBgView.hidden) {
                if (self -> _topView) {
                    [self -> _topView setHidden:NO];
                    [self -> _topView setAlpha:1];
                }
                [self->_bottomBgView setAlpha:1];
                [self->_bottomBgView setHidden:NO];
            }else {
                [UIView animateWithDuration:0.2 animations:^{
                    if (self -> _topView) {
                        [self -> _topView setAlpha:0];
                    }
                    [self->_bottomBgView setAlpha:0];
                }completion:^(BOOL finished) {
                    [self->_bottomBgView setHidden:YES];
                    [self -> _topView setHidden:YES];
                }];
            }
        }
        return;
    }
    [self dissMissWithAnimation:YES];
}

- (void)GQCollectionViewDidEndScroll:(GQBaseCollectionView *)collectionView
{
    [self setupTextScrollView];
}

- (void)GQCollectionViewCurrentSelectIndex:(NSInteger)index
{
    self->_selectIndex = index;
    if (self.achieveSelectIndex) {
        self.achieveSelectIndex(_selectIndex);
    }
}

#pragma mark -- public method

- (void)showInView:(UIView *)showView animation:(BOOL)animation
{
    if ([_dataSources count] == 0) {
        return;
    }
    
    if (_isVisible) {
        [self dissMissWithAnimation:YES];
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
    
    if (animation) {
        //设置初始值
        self.alpha = 0;
        self.frame = _initialRect;
        
        [showView addSubview:self];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.alpha = 1;
                             self.frame = _superViewRect;
                         }];
    }else {
        self.alpha = 1;
        self.frame = _superViewRect;
        [showView addSubview:self];
    }
}

//view消失
- (void)dissMissWithAnimation:(BOOL)animation
{
    GQWeakify(self);
    dispatch_block_t completionBlock = ^(){
        GQStrongify(self);
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
        [self resetConfigure];
    };
    
    if (animation) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.alpha = 0;
                             self.frame = _initialRect;
                         } completion:^(BOOL finished) {
                             dispatch_async(dispatch_get_main_queue(), completionBlock);
                         }];
    }else {
        completionBlock();
    }
}

#pragma mark -- privateMethod

//屏幕旋转通知
- (void)statusBarOrientationChange:(NSNotification *)noti
{
    if (_isVisible) {
        _superViewRect = self.superview.bounds;
        [self orientationChange];
    }
}

//屏幕旋转调整frame
- (void)orientationChange
{
    self.frame = _superViewRect;
    _collectionView.frame = _superViewRect;
    [self setupTextScrollView];
    [self updateInitialRect];
}

//设置文字View
- (void)setupTextScrollView
{
    CGFloat height = [_textScrollView configureSource:_dataSources
                                     withConfigure:_configure
                                  withCurrentIndex:_selectIndex
                                   withUsePageControl:_usePageControl
                                   withSuperViewWidth:_superViewRect.size.width];
    CGFloat bottomViewHeight = 0;
    
    if (_bottomView) {
        bottomViewHeight = _bottomView.height;
        _bottomView.frame = CGRectMake(_bottomView.x, height, _bottomView.width, bottomViewHeight);
        [_bottomBgView addSubview:_bottomView];
    }
    
    _textScrollView.frame = CGRectMake(0, 0, _superViewRect.size.width, height);
    
    _bottomBgViewY = _superViewRect.size.height - height - bottomViewHeight;
    _bottomBgView.frame = CGRectMake(0, _superViewRect.size.height - height - bottomViewHeight, _superViewRect.size.width, height + bottomViewHeight);
}

//初始化子view
- (void)initSubViews
{
    [self insertSubview:self.collectionView atIndex:0];
    [_collectionView addGestureRecognizer:self.panGesture];
    
    _collectionView.needLoopScroll = _needLoopScroll;
    _collectionView.placeholderImage = _placeholderImage;
    
    if (self.topView) {
        [self addSubview:self.topView];
    }
    
    [self addSubview:self.bottomBgView];
    
    [_bottomBgView addSubview:self.textScrollView];
    
    [self setupTextScrollView];
    
    [self scrollToSettingIndex];
}

//更新初始化rect
- (void)updateInitialRect
{
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

- (void)scrollToSettingIndex
{
    //滚动到指定的单元格
    if (_collectionView) {
        if (_selectIndex>[_imageArray count]-1){
            _selectIndex = [_imageArray count]-1;
        }else if (_selectIndex < 0){
            _selectIndex = 0;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectIndex+(_needLoopScroll?[_dataSources count]*maxSectionNum/2:0) inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

//图片处理
- (NSArray *)handleImageUrlArray:(NSArray *)imageURlArray withTextArray:(NSArray *)textArray
{
    NSMutableArray *handleSouces = [[NSMutableArray alloc] initWithCapacity:[imageURlArray count]];
    for (int i = 0; i <[imageURlArray count]; i++) {
        GQImageViewerModel *model = [GQImageViewerModel new];
        id imageObject = imageURlArray[i];
        if ([imageObject isKindOfClass:[NSString class]]) {
            imageObject = [NSURL URLWithString:imageObject];
        }
        if ([textArray count] == [imageURlArray count]) {
            model.textSource = textArray[i];
        }
        model.imageSource = imageObject;
        [handleSouces addObject:model];
    }
    
    return handleSouces;
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

#pragma mark -- 滑动手势处理

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isEqual:_panGesture]) {
        UIView *view = [gestureRecognizer view];
        CGPoint velocity = [_panGesture velocityInView:view];
        CGFloat ratio = (fabs(velocity.x)/fabs(velocity.y));
        //判断滑动手势消失的角度决定是否响应
        if (ratio > 0.68) {
            return NO;
        }else {
            return YES;
        }
    }
    return YES;
}

- (void)panGestureAction:(UIPanGestureRecognizer *)gesture {
    float transitionY = [gesture translationInView:gesture.view].y;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            //手势开始的时候标记手势状态，并开始相应的事件
            interation = YES;
            break;
        case UIGestureRecognizerStateChanged:{
            //手势过程中，通过updateInteractiveTransition设置frame
            [self updateInteractiveTransition:transitionY];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            interation = NO;
            //手势完成后结束标记并且判断移动距离
            if (fabsf(transitionY) > _superViewRect.size.height/4) {
                [self dissMissWithAnimation:NO];
            }else{
                [self updateInteractiveTransition:0];
                [self setupTextScrollView];
            }
            break;
        }
        default:
            break;
    }
}

- (void)updateInteractiveTransition:(float)transition
{
    if (transition != 0) {
        self.collectionView.y = transition;
        transition = fabsf(transition);
        self.alpha = 1- transition/self.height;
        self.bottomBgView.y = _bottomBgViewY + transition;
        if (_topView) {
            _topView.y = -transition;
        }
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            if (_topView) {
                _topView.y = transition;
            }
            self.collectionView.y = transition;
            self.alpha = 1- transition/self.height;
            [self setupTextScrollView];
        }];
    }
}

#pragma mark -- lazy load

- (GQTextScrollView *)textScrollView {
    if (!_textScrollView) {
        _textScrollView = [[GQTextScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_superViewRect), 0)];
    }
    return _textScrollView;
}

- (UIView *)bottomBgView {
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_superViewRect), 0)];
    }
    return _bottomBgView;
}

- (GQImageCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[GQImageCollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_superViewRect) ,CGRectGetHeight(_superViewRect)) collectionViewLayout:[UICollectionViewLayout new]];
        _collectionView.gqDelegate = self;
        _collectionView.gqDataSource = self;
        _collectionView.pagingEnabled  = YES;
    }
    return _collectionView;
}

- (UILongPressGestureRecognizer *)longTapGesture {
    if (!_longTapGesture) {
        _longTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapAction:)];
    }
    return _longTapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

@end

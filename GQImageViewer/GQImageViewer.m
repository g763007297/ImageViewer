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

#import "GQImageCacheManager.h"
#import "GQImageViewerModel.h"

#import "GQImageView.h"

@interface GQImageViewer()<GQCollectionViewDelegate,GQCollectionViewDataSource,UIGestureRecognizerDelegate>
{
    CGRect _superViewRect;//superview的rect
    CGRect _initialRect;//初始化rect
    CGFloat _bottomBgViewY;
    BOOL interation;
    
    @private
    /*
     *  显示PageControl传yes   默认 : yes
     *  显示label就传no
     */
    BOOL _usePageControl;
    
    /**
     是否需要循环滚动
     */
    BOOL _needLoopScroll;
    
    /**
     是否需要滑动消失手势
     */
    BOOL _needPanGesture;
    
    /**
     *  如果有网络图片则设置默认图片
     */
    UIImage *_placeholderImage;
    
    /**
     自定义图片浏览界面class名称 必须继承GQImageView  需在设置DataSource之前设置 否则没有效果
     */
    NSString *_imageViewClassName;
    
    /**
     *  推出方向  默认GQLaunchDirectionBottom
     */
    GQLaunchDirection _laucnDirection;
}

@property (nonatomic, strong) GQTextScrollView *textScrollView;
@property (nonatomic, strong) UIView *bottomBgView;//包含文字部分
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) GQImageViewrConfigure *imageViewerConfigure;//配置信息
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
        _usePageControl = YES;
        _needLoopScroll = NO;
    }
    return self;
}

//清除通知，防止崩溃
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

GQChainObjectDefine(selectIndexChain, SelectIndex, NSInteger, GQSelectIndexChain);
GQChainObjectDefine(configureChain, Configure, GQConfigureBlock, GQConfigureChain);
GQChainObjectDefine(achieveSelectIndexChain, AchieveSelectIndex, GQAchieveIndexBlock, GQAchieveIndexChain);
GQChainObjectDefine(singleTapChain, SingleTap, GQAchieveIndexBlock, GQAchieveIndexChain);
GQChainObjectDefine(longTapIndexChain, LongTapIndex, GQLongTapIndexBlock, GQLongTapIndexChain);
GQChainObjectDefine(dissMissChain, DissMiss, GQVoidBlock, GQVoidChain);
GQChainObjectDefine(topViewConfigureChain, TopViewConfigure, GQSubViewConfigureBlock, GQSubViewConfigureChain);
GQChainObjectDefine(bottomViewConfigureChain, BottomViewConfigure, GQSubViewConfigureBlock, GQSubViewConfigureChain);

@synthesize dataSouceArrayChain =_dataSouceArrayChain;
@synthesize showInViewChain = _showInViewChain;

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
    _bottomViewConfigure = nil;
    _configure = nil;
    _imageViewerConfigure = nil;
    _topViewConfigure = nil;
    _collectionView = nil;
    _textScrollView = nil;
    _collectionView.gqDelegate = nil;
    _collectionView.gqDataSource = nil;
    _isVisible = NO;
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

- (void)setBottomViewConfigure:(GQSubViewConfigureBlock)bottomViewConfigure {
    _bottomViewConfigure = [bottomViewConfigure copy];
    _bottomViewConfigure(_bottomView);
    [self setupTextScrollView];
}

- (void)setTopViewConfigure:(GQSubViewConfigureBlock)topViewConfigure {
    _topViewConfigure = [topViewConfigure copy];
    _topViewConfigure(_topView);
}

- (void)setConfigure:(GQConfigureBlock )configure
{
    _configure = [configure copy];
    _configure(self.imageViewerConfigure);
    self.backgroundColor = self.imageViewerConfigure.imageViewBgColor?:[UIColor clearColor];
    
    _usePageControl = self.imageViewerConfigure.usePageControl;
    
    _needLoopScroll = self.imageViewerConfigure.needLoopScroll;
    _collectionView.needLoopScroll = _needLoopScroll;
    
    _needPanGesture = self.imageViewerConfigure.needPanGesture;
    if (_needPanGesture) {
        [self.panGesture setEnabled:YES];
    }else {
        [self.panGesture setEnabled:NO];
    }
    _placeholderImage = self.imageViewerConfigure.placeholderImage;
    _collectionView.placeholderImage = _placeholderImage;
    _imageViewClassName = self.imageViewerConfigure.imageViewClassName;
    _laucnDirection = self.imageViewerConfigure.laucnDirection;
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
    return _imageViewerConfigure;
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
                [self -> _bottomBgView setAlpha:1];
                [self -> _bottomBgView setHidden:NO];
            }else {
                [UIView animateWithDuration:0.2 animations:^{
                    if (self -> _topView) {
                        [self -> _topView setAlpha:0];
                    }
                    [self -> _bottomBgView setAlpha:0];
                }completion:^(BOOL finished) {
                    [self -> _bottomBgView setHidden:YES];
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
        if (self.dissMiss) {
            self.dissMiss();
        }
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
                                        withConfigure:_imageViewerConfigure
                                     withCurrentIndex:_selectIndex
                                   withUsePageControl:_usePageControl
                                   withSuperViewWidth:_superViewRect.size.width];
    CGFloat bottomViewHeight = 0;
    
    if (_bottomViewConfigure) {
        bottomViewHeight = _bottomView.height;
        _bottomView.frame = CGRectMake(_bottomView.x, height, _bottomView.width, bottomViewHeight);
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
    
    if (self.topViewConfigure) {
        [self addSubview:self.topView];
        _topViewConfigure(_topView);
    }

    [self addSubview:self.bottomBgView];
    if (self.bottomViewConfigure) {
        [self.bottomBgView addSubview:self.bottomView];
        _bottomViewConfigure(_bottomView);
    }
    
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
        
        if ([NSClassFromString(_imageViewClassName) isSubclassOfClass:[GQImageView class]]  ) {
            model.GQImageViewClassName = _imageViewClassName;
        }else {
            model.GQImageViewClassName = NSStringFromClass([GQImageView class]);
        }
        
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

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_superViewRect), 0)];
    }
    return _bottomView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_superViewRect), 0)];
    }
    return _topView;
}

- (GQImageViewrConfigure *)imageViewerConfigure {
    if (!_imageViewerConfigure) {
        _imageViewerConfigure = [[GQImageViewrConfigure alloc] init];
    }
    return _imageViewerConfigure;
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

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

@interface GQImageViewer()<GQCollectionViewDelegate,GQCollectionViewDataSource,UIGestureRecognizerDelegate>
{
    CGRect _superViewRect;//superview的rect
    CGRect _initialRect;//初始化rect
    CGFloat _bottomBgViewY;
    BOOL _interation;
    
@private
    /**
     *  推出方向  默认GQLaunchDirectionBottom
     */
    GQLaunchDirection _laucnDirection;
}

@property (nonatomic, strong) GQTextScrollView *textScrollView;//文字滑动视图
@property (nonatomic, strong) UIView *bottomBgView;//包含文字部分
@property (nonatomic, strong) UIView *bottomView;//文字以下部分
@property (nonatomic, strong) UIView *topView;//顶部视图

@property (nonatomic, strong) GQImageViewrConfigure *imageViewerConfigure;//配置信息

@property (nonatomic, strong) GQImageCollectionView *collectionView;//collectionView

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;//滑动手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longTapGesture;//长按手势

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
        //添加屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self setClipsToBounds:YES];
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
//重设初始值
- (void)resetConfigure {
    _selectIndex = 0;
    _imageArray = nil;
    _textArray = nil;
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
    
    if (!_isVisible) return;
    
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
        //如果文字数组和图片数组长度不相等，主动抛出异常
        NSAssert([_textArray count] == [_imageArray count], @"imageArray count must be equal to textArray");
    }
    //如果无文字，图片数组长度必须大于0
    NSAssert([_imageArray count] > 0, @"imageArray count must be greater than zero");
    
    if (!_isVisible) return;
    
    //做选中下标容错处理，避免越界
    if (_selectIndex > [imageArray count] - 1 && [_imageArray count] > 0) {
        _selectIndex = [imageArray count] - 1;
        
        [self setupTextScrollView];
        [self scrollToSettingIndex];
    }
}

- (void)setBottomViewConfigure:(GQSubViewConfigureBlock)bottomViewConfigure {
    _bottomViewConfigure = [bottomViewConfigure copy];
    
    if (!_bottomView) return;//如果使用autolayout布局，当_bottomView为空时会奔溃
    
    //返回_bottomView进行配置
    _bottomViewConfigure(_bottomView);
    
    //设置了bottomView则重新配置底部文字视图
    [self setupTextScrollView];
}

- (void)setTopViewConfigure:(GQSubViewConfigureBlock)topViewConfigure {
    _topViewConfigure = [topViewConfigure copy];
    
    //如果使用autolayout布局，当_topView为空时会奔溃
    if (!_topView) return;
    
    //返回_topView进行配置
    _topViewConfigure(_topView);
}

- (void)setConfigure:(GQConfigureBlock )configure
{
    _configure = [configure copy];
    _configure(self.imageViewerConfigure);
    
    //设置界面配置信息
    self.backgroundColor = self.imageViewerConfigure.imageViewBgColor?:[UIColor clearColor];
    
    if (self.imageViewerConfigure.needPanGesture) {
        [self.panGesture setEnabled:YES];
    }else {
        [self.panGesture setEnabled:NO];
    }
    
    _laucnDirection = self.imageViewerConfigure.laucnDirection;
    
    //当_laucnDirection为GQLaunchDirectionFromRect时，必须配置launchFromView，否则会主动抛出异常
    if (_laucnDirection == GQLaunchDirectionFromRect) {
        NSAssert([self.imageViewerConfigure.launchFromView isKindOfClass:[UIView class]], @"launchFromView must be subClass of UIView");
        NSAssert(self.imageViewerConfigure.launchFromView.superview, @"launchFromView must be have superview");
    }
    
    //如果GQImageViewrBaseURLRequest文件丢失或者未加入当前target则会抛出此异常
    if (!NSClassFromString(@"GQImageViewrBaseURLRequest")) {
        NSAssert(0, @"GQImageViewrBaseURLRequest class is miss, please check!");
    }
    
    //如果GQImageView文件丢失或者未加入当前target则会抛出此异常
    if (!NSClassFromString(@"GQImageView")) {
        NSAssert(0, @"GQImageView class is miss, please check!");
    }
    
    if (![NSClassFromString(self.imageViewerConfigure.requestClassName) isSubclassOfClass:NSClassFromString(@"GQImageViewrBaseURLRequest")]) {
        self.imageViewerConfigure.requestClassName = @"GQImageViewrBaseURLRequest";
    }
    
    if (![NSClassFromString(self.imageViewerConfigure.imageViewClassName) isSubclassOfClass:NSClassFromString(@"GQImageView")]  ) {
        self.imageViewerConfigure.imageViewClassName = @"GQImageView";
    }
    
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
    return [self.imageArray count];
}

- (id)GQCollectionView:(GQBaseCollectionView *)collectionView dataSourceInIndex:(NSInteger)index {
    return self.imageArray[index];
}

- (GQImageViewrConfigure *)configureOfGQCollectionView:(GQBaseCollectionView *)collectionView {
    return self.imageViewerConfigure;
}

#pragma mark -- GQCollectionViewDelegate

- (void)GQCollectionViewDidSigleTap:(GQBaseCollectionView *)collectionView withCurrentSelectIndex:(NSInteger)index
{
    if (_singleTap) {
        _singleTap(_selectIndex);
    }
    if (self.imageViewerConfigure.needTapAutoHiddenTopBottomView) {
        [self configureTopAndBottomViewHidden:!_bottomBgView.hidden];
        return;
    }
    [self dissMissWithAnimation:YES];
}

- (void)GQCollectionViewDidEndScroll:(GQBaseCollectionView *)collectionView
{
    
}

- (void)GQCollectionViewCurrentSelectIndex:(NSInteger)index
{
    if (_selectIndex == index) return;
    
    self->_selectIndex = index;
    
    //当collectionView停止滑动时，去配置文字视图
    [self setupTextScrollView];
    
    if (self.achieveSelectIndex) {
        self.achieveSelectIndex(_selectIndex);
    }
}

#pragma mark -- public method

- (void)showInView:(UIView *)showView animation:(BOOL)animation
{
    if ([_imageArray count] == 0) {
        return;
    }
    
    if (_isVisible) {
        
        [self dissMissWithAnimation:NO];
        return;
    }else{
        _isVisible = YES;
    }
    
    
    self.alpha = 0;
    
    //设置superview的rect
    _superViewRect = showView.bounds;
    
    //更新初始化rect
    [self updateInitialRect];
    
    self.frame = _initialRect;
    
    //初始化子view
    [self initSubViews];
    
    [showView addSubview:self];
    
    if (animation) {
        //设置初始值
        [UIView animateWithDuration:GQImageViewerAnimationTimeInterval
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 1;
                             self.frame = self->_superViewRect;
                         }completion:^(BOOL finished) {
                             [self configureTopAndBottomView];
                         }];
    }else {
        self.alpha = 1;
        self.frame = self->_superViewRect;
        [showView addSubview:self];
        [self configureTopAndBottomView];
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
        self.userInteractionEnabled = YES;
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
        [self resetConfigure];
    };
    
    [self configureTopAndBottomViewHidden:YES];
    self.userInteractionEnabled = NO;
    
    if (animation) {
        [UIView animateWithDuration:GQImageViewerAnimationTimeInterval
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.alpha = 0.5;
                             self.frame = self->_initialRect;
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
    CGFloat height = [_textScrollView configureSource:_textArray[_selectIndex]
                                        withConfigure:self.imageViewerConfigure
                                     withCurrentIndex:_selectIndex
                                       withTotalCount:[_textArray count]
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
    
    [self scrollToSettingIndex];
}

//配置头部与底部视图
- (void)configureTopAndBottomView {
    if (self.topViewConfigure) [self addSubview:self.topView];
    
    [self addSubview:self.bottomBgView];
    if (self.bottomViewConfigure) {
        [self.bottomBgView addSubview:self.bottomView];
        _bottomViewConfigure(_bottomView);
    }
    
    [_bottomBgView addSubview:self.textScrollView];
    
    [UIView animateWithDuration:GQImageViewerAnimationTimeInterval
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            if (self.topViewConfigure) self->_topViewConfigure(self->_topView);
                            self->_topView.alpha = 1;
                            self->_bottomBgView.alpha = 1;
                            [self setupTextScrollView];
                        } completion:nil];
}

//配置头部与底部视图的隐藏
- (void)configureTopAndBottomViewHidden:(BOOL)hidden {
    if (!hidden) {
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
        case GQLaunchDirectionFromRect: {
            _initialRect = [self.imageViewerConfigure.launchFromView.superview convertRect:self.imageViewerConfigure.launchFromView.frame toView:self.superview];
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
        if (_selectIndex > [_imageArray count] - 1) {
            _selectIndex = [_imageArray count] - 1;
        } else if (_selectIndex < 0) {
            _selectIndex = 0;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectIndex+(self.imageViewerConfigure.needLoopScroll?[_imageArray count]*maxSectionNum/2:0) inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

//数据源转换处理
- (NSArray *)handleImageUrlArray:(NSArray *)imageURlArray withTextArray:(NSArray *)textArray
{
    NSMutableArray *handleSouces = [[NSMutableArray alloc] initWithCapacity:[imageURlArray count]];
    for (int i = 0; i <[imageURlArray count]; i++) {
        GQImageViewerModel *model = [GQImageViewerModel new];
        id imageObject = imageURlArray[i];
        if ([imageObject isKindOfClass:[NSString class]]) {
            imageObject = [NSURL URLWithString:imageObject];
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
            _interation = YES;
            break;
        case UIGestureRecognizerStateChanged:{
            //手势过程中，通过updateInteractiveTransition设置frame
            [self updateInteractiveTransition:transitionY];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            _interation = NO;
            //手势完成后结束标记并且判断移动距离
            if (fabsf(transitionY) > _superViewRect.size.height/4) {
                [self dissMissWithAnimation:YES];
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
        [UIView animateWithDuration:GQImageViewerAnimationTimeInterval animations:^{
            if (self->_topView) {
                self->_topView.y = transition;
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
        _bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_superViewRect), CGRectGetWidth(_superViewRect), 0)];
        [_bottomBgView setAlpha:0];
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
        [_topView setAlpha:0];
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


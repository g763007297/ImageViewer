//
//  GQImagePreviewer.m
//  ImageViewer
//
//  Created by tusm on 2018/11/16.
//  Copyright © 2018年 tusm. All rights reserved.
//

#import "GQImagePreviewer.h"
#import "GQImageCollectionView.h"
#import "GQTextScrollView.h"

#import "GQImageCacheManager.h"
#import "GQImageViewerModel.h"

#import "UIView+GQImageViewrCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface GQImagePreviewer() <GQCollectionViewDelegate,GQCollectionViewDataSource,UIGestureRecognizerDelegate>
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

@property (nonatomic, strong) GQImageCollectionView *collectionView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;//滑动手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longTapGesture;//长按手势

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL isVisible;//是否正在显示

@end

@implementation GQImagePreviewer

+ (instancetype)imageViewer {
    GQImagePreviewer *imageViewer = [[GQImagePreviewer alloc] init];
    return imageViewer;
}

+ (instancetype)imageViewerWithCurrentIndex:(NSInteger)index {
    GQImagePreviewer *imageViewer = [[GQImagePreviewer alloc] init];
    imageViewer.currentIndex = index;
    return imageViewer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
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

#pragma mark -- set method
//重设初始值
- (void)resetConfigure {
    self.currentIndex = 0;
    _bottomBgView = nil;
    _bottomView = nil;
    _topView = nil;
    _imageViewerConfigure = nil;
    _collectionView = nil;
    _textScrollView = nil;
    _collectionView.gqDelegate = nil;
    _collectionView.gqDataSource = nil;
    _isVisible = NO;
}

- (void)setDelegate:(_Nullable id<GQImagePreviewerDelegate>)delegate {
    _delegate = delegate;
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:didLongTapIndex:data:)]) {
        //长按手势
        [self addGestureRecognizer:self.longTapGesture];
    }
}

- (void)setDataSource:(_Nullable id<GQImagePreviewerDataSource>)dataSource {
    _dataSource = dataSource;
    [self setupConfigure];
}

#pragma mark -- GQCollectionViewDataSource

- (NSInteger)totalPagesInGQCollectionView:(GQBaseCollectionView *)collectionView {
    return self.numberOfItem;
}

- (id)GQCollectionView:(GQBaseCollectionView *)collectionView dataSourceInIndex:(NSInteger)index {

    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageViewer:dataForItemAtIndex:)]) {
        id imageObject = [self.dataSource imageViewer:self dataForItemAtIndex:index];;
        if ([imageObject isKindOfClass:[NSString class]]) {
            imageObject = [NSURL URLWithString:imageObject];
        }
        return imageObject;
    }
    return nil;
}

- (GQImageViewrConfigure *)configureOfGQCollectionView:(GQBaseCollectionView *)collectionView {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageViewer:configure:)]) {
        [self.dataSource imageViewer:self configure:self.imageViewerConfigure];
    }
    return self.imageViewerConfigure;
}

#pragma mark -- GQCollectionViewDelegate

- (void)GQCollectionViewDidSigleTap:(GQBaseCollectionView *)collectionView withCurrentSelectIndex:(NSInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:didSingleTapIndex:)]) {
        [self.delegate imageViewer:self didSingleTapIndex:index];
    }
    if (self.imageViewerConfigure.needTapAutoHiddenTopBottomView) {
        [self configureTopAndBottomViewHidden:!_bottomBgView.hidden];
        return;
    }
    [self dissMissWithAnimation:YES];
}

- (void)GQCollectionViewCurrentSelectIndex:(NSInteger)index
{
    if (self.currentIndex == index) return;
    
    self.currentIndex = index;
    
    //当collectionView停止滑动时，去配置文字视图
    [self setupTextScrollView];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:didSelectIndex:)]) {
        [self.delegate imageViewer:self didSelectIndex:self.currentIndex];
    }
}

#pragma mark -- public method

- (void)scrollToIndex:(NSInteger)index animation:(BOOL)animation {
    self.currentIndex = index;
    
    if (!_isVisible) return;
    
    NSAssert(self.currentIndex>=0, @"_selectIndex must be greater than zero");
    NSAssert(self.numberOfItem > 0, @"imageArray count must be greater than zero");
    
    [self scrollToSettingIndexWithAnimation:animation];
    [self setupTextScrollView];
}

- (void)reloadData {
    if (self.numberOfItem <= 0) {
        [self dissMissWithAnimation:YES];
        return;
    }
    
    [self.collectionView reloadData];
}

- (void)deleteIndex:(NSInteger)index
          animation:(BOOL)animation
           complete:(void (^ _Nullable)(BOOL finished))complete {
    if (self.numberOfItem <= 0) {
        [self dissMissWithAnimation:YES];
        return;
    }
    
    if (index == _currentIndex && animation) {
        [self.collectionView performBatchUpdates:^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        } completion:^(BOOL finished) {
            [self.collectionView reloadData];
            if (complete) {
                complete(finished);
            }
        }];
    } else
        [self.collectionView reloadData];
}

- (void)showInView:(UIView *)showView animation:(BOOL)animation
{
    if (self.numberOfItem == 0) {
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
    }
}

//view消失
- (void)dissMissWithAnimation:(BOOL)animation
{
    GQWeakify(self);
    dispatch_block_t completionBlock = ^(){
        GQStrongify(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewerDidDissmiss:)]) {
            [self.delegate imageViewerDidDissmiss:self];
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

- (void)setupConfigure {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageViewer:configure:)]) {
        [self.dataSource imageViewer:self configure:self.imageViewerConfigure];
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
}

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
    id textDataSource = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageViewer:textForItemAtIndex:)]) {
        textDataSource = [self.dataSource imageViewer:self textForItemAtIndex:self.currentIndex];
    }
    CGFloat height = [_textScrollView configureSource:textDataSource
                                        withConfigure:self.imageViewerConfigure
                                     withCurrentIndex:self.currentIndex
                                       withTotalCount:self.numberOfItem
                                   withSuperViewWidth:_superViewRect.size.width];
    CGFloat bottomViewHeight = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:bottomViewConfigure:)]) {
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
    
    [self scrollToSettingIndexWithAnimation:NO];
}

//配置头部与底部视图
- (void)configureTopAndBottomView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:topViewConfigure:)]) {
        [self addSubview:self.topView];
    }
    
    [self addSubview:self.bottomBgView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:bottomViewConfigure:)]) {
        [self.bottomBgView addSubview:self.bottomView];
    }
    
    [_bottomBgView addSubview:self.textScrollView];
    
    [UIView animateWithDuration:GQImageViewerAnimationTimeInterval
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:topViewConfigure:)]) {
                                [self.delegate imageViewer:self topViewConfigure:self.topView];
                            }
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

- (void)scrollToSettingIndexWithAnimation:(BOOL)animation
{
    //滚动到指定的单元格
    if (_collectionView) {
        if (self.currentIndex > self.numberOfItem - 1) {
            self.currentIndex = self.numberOfItem - 1;
        } else if (self.currentIndex < 0) {
            self.currentIndex = 0;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex+(self.imageViewerConfigure.needLoopScroll?self.numberOfItem * maxSectionNum/2:0) inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:animation];
    }
}

#pragma mark -- 长按手势响应处理

- (void)longTapAction:(UILongPressGestureRecognizer *)ges
{
    if (ges.state == UIGestureRecognizerStateBegan)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewer:didLongTapIndex:data:)]) {
            
            if (self.numberOfItem > self.currentIndex)
            {
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageViewer:dataForItemAtIndex:)]) {
                    id imageData = [self.dataSource imageViewer:self dataForItemAtIndex:self.currentIndex];
                    UIImage *image = nil;
                    if ([imageData isKindOfClass:[NSString class]]||[imageData isKindOfClass:[NSURL class]]) {
                        if ([imageData isKindOfClass:[NSURL class]]) {
                            imageData = ((NSURL *)imageData).absoluteString;
                        }
                        if ([[GQImageCacheManager sharedManager] isImageInMemoryCacheWithUrl:imageData]) {
                            image = [[GQImageCacheManager sharedManager] getImageFromCacheWithUrl:imageData];
                        }
                    } else if ([imageData isKindOfClass:[UIImageView class]]) {
                        image = ((UIImageView *)imageData).image;
                    } else {
                        image = imageData;
                    }
                    [self.delegate imageViewer:self didLongTapIndex:self.currentIndex data:image];
                }
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

- (NSInteger)numberOfItem {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemInImageViewer:)]) {
        return [self.dataSource numberOfItemInImageViewer:self];
    }
    
    return 0;
}

@end

NS_ASSUME_NONNULL_END

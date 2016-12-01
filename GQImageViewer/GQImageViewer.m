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

@interface GQImageViewer()<GQCollectionViewDelegate>
{
    GQTextScrollView *textScrollView;
    GQImageCollectionView *_tableView;//tableview
    CGRect _superViewRect;//superview的rect
    CGRect _initialRect;//初始化rect
    UILongPressGestureRecognizer *longTap;//长按手势
    NSArray <GQImageViewerModel *>*dataSources;//数据源
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
        self.backgroundColor = [UIColor blackColor];
        [self setClipsToBounds:YES];
        self.laucnDirection = GQLaunchDirectionBottom;
        self.usePageControl = YES;
        self.needLoopScroll = NO;
    }
    return self;
}

@synthesize usePageControlChain = _usePageControlChain;
@synthesize needLoopScrollChain = _needLoopScrollChain;
@synthesize dataSouceArrayChain =_dataSouceArrayChain;
@synthesize selectIndexChain = _selectIndexChain;
@synthesize configureChain = _configureChain;
@synthesize showInViewChain = _showInViewChain;
@synthesize launchDirectionChain = _launchDirectionChain;
@synthesize achieveSelectIndexChain = _achieveSelectIndexChain;
@synthesize singleTapChain = _singleTapChain;
@synthesize longTapIndexChain = _longTapIndexChain;

GQChainObjectDefine(usePageControlChain, UsePageControl, BOOL, GQUsePageControlChain);
GQChainObjectDefine(needLoopScrollChain, NeedLoopScroll, BOOL, GQUsePageControlChain);
GQChainObjectDefine(selectIndexChain, SelectIndex, NSInteger, GQSelectIndexChain);
GQChainObjectDefine(configureChain, Configure, GQImageViewrConfigure*, GQConfigureChain);
GQChainObjectDefine(launchDirectionChain, LaucnDirection, GQLaunchDirection, GQLaunchDirectionChain);
GQChainObjectDefine(achieveSelectIndexChain, AchieveSelectIndex, GQAchieveIndexBlock, GQAchieveIndexChain);
GQChainObjectDefine(singleTapChain, SingleTap, GQAchieveIndexBlock, GQAchieveIndexChain);
GQChainObjectDefine(longTapIndexChain, LongTapIndex, GQLongTapIndexBlock, GQLongTapIndexChain);

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
    _tableView.needLoopScroll = _needLoopScroll;
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    
    if (selectIndex>[_imageArray count]-1){
        _selectIndex = [_imageArray count]-1;
    }else if (selectIndex < 0){
        _selectIndex = 0;
    }
    
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
    
    dataSources = [self handleImageUrlArray:_imageArray withTextArray:_textArray];
    
    if (!_isVisible) {
        return;
    }
    
    _tableView.dataArray = [dataSources copy];
    
    if (_selectIndex>[imageArray count]-1&&[_imageArray count]>0){
        _selectIndex = [imageArray count]-1;
        
        [self setupTextScrollView];
        [self scrollToSettingIndex];
    }
}

- (void)setConfigure:(GQImageViewrConfigure *)configure
{
    _configure = [configure copy];
    _tableView.configure = _configure;
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

- (void)showInView:(UIView *)showView animation:(BOOL)animation
{
    if ([_imageArray count]==0) {
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
- (void)dissMissWithAnimation:(BOOL)animation
{
    dispatch_block_t completionBlock = ^(){
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self removeFromSuperview];
        _tableView = nil;
        _isVisible = NO;
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

#pragma mark -- GQCollectionViewDelegate

- (void)GQCollectionViewDidSigleTap:(GQBaseCollectionView *)collectionView withCurrentSelectIndex:(NSInteger)index
{
    if (_singleTap||[_textArray count] > 0) {
        if (self.singleTap) {
            self.singleTap(self.selectIndex);
        }
        if ([_textArray count] > 0) {
            [self->textScrollView setHidden:!self->textScrollView.hidden];
        }else {
            [self dissMissWithAnimation:YES];
        }
    }
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

#pragma mark -- privateMethod

- (void)setupTextScrollView
{
    textScrollView.backgroundColor = _configure.textViewBgColor?:[[UIColor blackColor] colorWithAlphaComponent:0.3];
    CGFloat height = [textScrollView configureSource:dataSources
                                     withConfigure:_configure
                                  withCurrentIndex:_selectIndex
                                    usePageControl:_usePageControl];
    textScrollView.frame = CGRectMake(0, _superViewRect.size.height - height, _superViewRect.size.width, height);
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
    _tableView.frame = _superViewRect;
    [self setupTextScrollView];
    [self updateInitialRect];
}

//初始化子view
- (void)initSubViews
{
    if (!_tableView) {
        _tableView = [[GQImageCollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_superViewRect) ,CGRectGetHeight(_superViewRect)) collectionViewLayout:[UICollectionViewLayout new]];
        _tableView.gqDelegate = self;
        _tableView.pagingEnabled  = YES;
    }
    
    _tableView.needLoopScroll = _needLoopScroll;
    
    [self insertSubview:_tableView atIndex:0];
    
    if (!textScrollView) {
        textScrollView = [[GQTextScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_superViewRect), 0)];
    }
    [self addSubview:textScrollView];
    [self setupTextScrollView];
    
    //将所有的图片url赋给tableView显示
    _tableView.dataArray = [dataSources copy];
    
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
    if (_tableView) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_selectIndex+(_needLoopScroll?[dataSources count]*maxSectionNum/2:0) inSection:0];
        [_tableView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
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

//清除通知，防止崩溃
- (void)dealloc
{
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

//
//  GQBaseCollectionView.m
//  ImageViewer
//
//  Created by 高旗 on 16/11/29.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQBaseCollectionView.h"
#import "GQImageViewrConfigure.h"

@interface GQReuseTabViewFlowLayout : UICollectionViewFlowLayout

@end

@implementation GQReuseTabViewFlowLayout
- (void)prepareLayout
{
    [super prepareLayout];
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    if (self.collectionView.bounds.size.height) {
        self.itemSize = self.collectionView.bounds.size;
    }
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

@end

@implementation GQBaseCollectionView

@synthesize selectedInexPath = _selectedInexPath;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:[[GQReuseTabViewFlowLayout alloc] init]];
    if (self) {
        [self _initViews:frame];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self _initViews:self.frame];
}

- (void)_initViews:(CGRect)frame
{
    self.backgroundColor = [UIColor clearColor];
    
    //去掉垂直方向的滚动条
    self.showsHorizontalScrollIndicator = NO;
    
    self.delegate = self;
    self.dataSource = self;
    
    //设置减速的方式， UIScrollViewDecelerationRateFast 为快速减速
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    
    _selectedInexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.collectionViewLayout prepareLayout];
}

#pragma mark -- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   return [self numberOfPages]*(_needLoopScroll?maxSectionNum:1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"default" forIndexPath:indexPath];
}

#pragma mark -- GQCollectionViewDataSource Configure

- (NSInteger)numberOfPages {
    if (self.gqDataSource && [self.gqDataSource respondsToSelector:@selector(totalPagesInGQCollectionView:)]) {
        return [self.gqDataSource totalPagesInGQCollectionView:self];
    }else {
        return 0;
    }
}

- (GQImageViewerModel *)dataSourceInIndex:(NSInteger)index {
    if (self.gqDataSource && [self.gqDataSource respondsToSelector:@selector(GQCollectionView:dataSourceInIndex:)]) {
        return [self.gqDataSource GQCollectionView:self dataSourceInIndex:index];
    }else {
        return nil;
    }
}

- (GQImageViewrConfigure *)configure {
    if (self.gqDataSource && [self.gqDataSource respondsToSelector:@selector(configureOfGQCollectionView:)]) {
        return [self.gqDataSource configureOfGQCollectionView:self];
    }else {
        return nil;
    }
}

#pragma mark - UIScrollView delegate

//手指离开屏幕时调用的协议方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //判断手指离开屏幕时，视图是否正在减速，如果是减速说明视图还在滚动中，如果不是则说明视图停止了
    if(!decelerate) {
        [self scrollCellToCenter];
    }
}

//已经减速停止后调用的协议方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollCellToCenter];
}

- (void) scrollViewDidScroll:(UIScrollView *)sender
{
    [self getPageIndex];
}

//将单元格滚动至中间位置
- (void)scrollCellToCenter
{
    CGFloat edge = self.contentInset.right;
    
    float y = self.contentOffset.x + edge + self.frame.size.width/2;
    int row = y/self.frame.size.width;
    
    NSInteger totalPages = [self numberOfPages];
    
    if (_needLoopScroll) {
        if (row >= totalPages && totalPages != 0) {
            row = row%totalPages;
        }
    }else {
        if (row >= totalPages || row < 0) {
            return;
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row+(_needLoopScroll?totalPages*maxSectionNum/2:0) inSection:0];
    
    [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    if (self.gqDelegate&&[self.gqDelegate respondsToSelector:@selector(GQCollectionViewDidEndScroll:)]) {
        [self.gqDelegate GQCollectionViewDidEndScroll:self];
    }
}

- (void)getPageIndex
{
    CGFloat edge = self.contentInset.right;
    
    float y = self.contentOffset.x + edge + self.frame.size.width/2;
    int row = y/self.frame.size.width;
    
    NSInteger totalPages = [self numberOfPages];
    
    if (_needLoopScroll && totalPages != 0) {
        //如果超过边界则返回中间位置
        if ((self.contentOffset.x > self.contentSize.width-self.frame.size.width)&&self.contentSize.width > 0) {
            row = (int)(_needLoopScroll?totalPages*maxSectionNum/2:0);
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }else if (self.contentOffset.x < 0){
            row = (int)(totalPages - 1 + (_needLoopScroll?totalPages*maxSectionNum/2:0));
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    }else {
        if (row >= totalPages || row < 0) {
            return;
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row%totalPages inSection:0];
    
    if (indexPath.row != _selectedInexPath.row) {
        if (self.gqDelegate&&[self.gqDelegate respondsToSelector:@selector(GQCollectionViewCurrentSelectIndex:)]) {
            [self.gqDelegate GQCollectionViewCurrentSelectIndex:row%totalPages];
        }
        //记录选中的单元格IndexPath
        _selectedInexPath = indexPath;
    }
}

@end

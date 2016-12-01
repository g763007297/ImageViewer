//
//  PhotoTableView.m
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import "GQImageCollectionView.h"
#import "GQImageScrollView.h"
#import "GQTextScrollView.h"
#import "GQImageViewerModel.h"
#import "GQImageViewerConst.h"
#import "GQImageViewrConfigure.h"

typedef void (^GQSingleTap)();

@interface GQImageVideoCollectionViewCell : UICollectionViewCell

@property (nonatomic, readonly, strong) GQImageViewrConfigure *configure;
@property (nonatomic, readonly, strong) GQImageViewerModel *data;

@property (nonatomic, copy) GQSingleTap sigleTap;

- (void)configureCell:(GQImageViewrConfigure *)configure model:(GQImageViewerModel *)data;

@end

@implementation GQImageVideoCollectionViewCell

@synthesize configure = _configure;
@synthesize data = _data;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    GQImageScrollView *photoSV = [[GQImageScrollView alloc] init];
    self.backgroundColor = [UIColor clearColor];
    photoSV.tag = 100;
    [self.contentView addSubview:photoSV];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    GQImageScrollView *photoSV = (GQImageScrollView *)[self.contentView viewWithTag:100];
    if (self.sigleTap) {
        GQWeakify(self);
        photoSV.singleTap = ^void(){
            weak_self.sigleTap();
        };
    }
    photoSV.data = _data.imageSource;
    photoSV.frame = self.bounds;
}

- (void)configureCell:(GQImageViewrConfigure *)configure model:(GQImageViewerModel *)data
{
    _data = [data copy];
    _configure = [configure copy];
    [self setNeedsLayout];
}

@end

@implementation GQImageCollectionView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self registerClass:[GQImageVideoCollectionViewCell class] forCellWithReuseIdentifier:@"GQImageVideoScrollViewIdentify"];
        self.pagingEnabled = YES;
    }
    return self;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"GQImageVideoScrollViewIdentify";
    
    GQImageVideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    if (self.gqDelegate&&[self.gqDelegate respondsToSelector:@selector(GQCollectionViewDidSigleTap:withCurrentSelectIndex:)]) {
        GQWeakify(self);
        cell.sigleTap = ^(){
            [weak_self.gqDelegate GQCollectionViewDidSigleTap:self withCurrentSelectIndex:weak_self.selectedInexPath.row];
        };
    }
    
    [cell configureCell:self.configure model:self.dataArray[indexPath.row%[self.dataArray count]]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(nonnull UICollectionViewCell *)cell
    forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    GQImageScrollView *photoSV = (GQImageScrollView *)[cell.contentView viewWithTag:100];
    [photoSV setZoomScale:1.0 animated:YES];
}

@end

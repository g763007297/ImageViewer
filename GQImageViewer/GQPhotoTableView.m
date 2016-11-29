//
//  PhotoTableView.m
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import "GQPhotoTableView.h"
#import "GQPhotoScrollView.h"
#import "GQImageViewerConst.h"

@interface GQImageVideoCollectionViewCell : UICollectionViewCell

@end

@implementation GQImageVideoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    GQPhotoScrollView *photoSV = [[GQPhotoScrollView alloc] init];
    self.backgroundColor = [UIColor clearColor];
    photoSV.tag = 100;
    [self.contentView addSubview:photoSV];
}

- (void)layoutSubviews {
    GQPhotoScrollView *photoSV = (GQPhotoScrollView *)[self.contentView viewWithTag:100];
    photoSV.frame = self.bounds;
}

@end

@implementation GQPhotoTableView

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
    
    GQPhotoScrollView *photoSV = (GQPhotoScrollView *)[cell.contentView viewWithTag:100];
    
    photoSV.data = self.dataArray[indexPath.row];
    
    photoSV.row = indexPath.row;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    GQPhotoScrollView *photoSV = (GQPhotoScrollView *)[cell.contentView viewWithTag:100];
    
    [photoSV setZoomScale:1.0 animated:YES];
}

@end

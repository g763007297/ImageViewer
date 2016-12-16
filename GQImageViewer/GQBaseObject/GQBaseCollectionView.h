//
//  GQBaseCollectionView.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/29.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GQBaseCollectionView;

@protocol GQCollectionViewDelegate <NSObject>

@optional
- (void)GQCollectionViewDidSigleTap:(GQBaseCollectionView *)collectionView withCurrentSelectIndex:(NSInteger)index;

- (void)GQCollectionViewDidEndScroll:(GQBaseCollectionView *)collectionView;

- (void)GQCollectionViewDidScroll:(GQBaseCollectionView *)collectionView;

- (void)GQCollectionViewCurrentSelectIndex:(NSInteger)index;

@end

static NSInteger const maxSectionNum = 100;

@class GQImageViewerModel;
@class GQImageViewrConfigure;

@interface GQBaseCollectionView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSArray <GQImageViewerModel *>*dataArray;

@property (nonatomic, strong) GQImageViewrConfigure *configure;

@property (nonatomic, strong) UIImage *placeholderImage;

@property (nonatomic, assign) id<GQCollectionViewDelegate> gqDelegate;

@property (nonatomic, assign) BOOL needLoopScroll;

//当前选中的单元格IndexPath
@property (nonatomic, copy) NSIndexPath *selectedInexPath;

@end

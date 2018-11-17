//
//  GQBaseCollectionView.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/29.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GQBaseCollectionView;
@class GQImageViewerModel;
@class GQImageViewrConfigure;

@protocol GQCollectionViewDataSource <NSObject>

@required
- (NSInteger)totalPagesInGQCollectionView:(GQBaseCollectionView *)collectionView;

- (id)GQCollectionView:(GQBaseCollectionView *)collectionView dataSourceInIndex:(NSInteger)index;

- (GQImageViewrConfigure *)configureOfGQCollectionView:(GQBaseCollectionView *)collectionView;

@end

@protocol GQCollectionViewDelegate <NSObject>

@optional
- (void)GQCollectionViewDidSigleTap:(GQBaseCollectionView *)collectionView withCurrentSelectIndex:(NSInteger)index;

- (void)GQCollectionViewDidEndScroll:(GQBaseCollectionView *)collectionView;

- (void)GQCollectionViewDidScroll:(GQBaseCollectionView *)collectionView;

- (void)GQCollectionViewCurrentSelectIndex:(NSInteger)index;

@end

static NSInteger const maxSectionNum = 100;

@interface GQBaseCollectionView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) id<GQCollectionViewDelegate> gqDelegate;

@property (nonatomic, weak) id<GQCollectionViewDataSource> gqDataSource;

//当前选中的单元格IndexPath
@property (nonatomic, strong, readonly) NSIndexPath *selectedInexPath;

//获取当前配置
- (GQImageViewrConfigure *)configure;

//获取指定页的datasource
- (id)dataSourceInIndex:(NSInteger)index;

//获取总页数
- (NSInteger)numberOfPages;

@end

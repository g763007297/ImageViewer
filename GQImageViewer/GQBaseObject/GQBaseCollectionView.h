//
//  GQBaseCollectionView.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/29.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSInteger const maxSectionNum = 100;

typedef void (^GQSingleTap)();

@class GQImageViewerModel;
@class GQImageViewrConfigure;

@interface GQBaseCollectionView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSArray <GQImageViewerModel *>*dataArray;

@property (nonatomic, strong) GQImageViewrConfigure *configure;

@property (nonatomic, assign) BOOL needLoopScroll;

@property (nonatomic, copy) void (^block)(NSInteger index);

@property (nonatomic, copy) GQSingleTap sigleTap;

//当前选中的单元格IndexPath
@property (nonatomic, copy) NSIndexPath *selectedInexPath;

@end

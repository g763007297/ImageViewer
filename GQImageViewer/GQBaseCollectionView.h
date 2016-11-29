//
//  GQBaseCollectionView.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/29.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GQBaseCollectionView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, copy) void (^block)(NSInteger index);

//当前选中的单元格IndexPath
@property (nonatomic, copy) NSIndexPath *selectedInexPath;

@end

//
//  BasePictureTableView.h
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasePictureTableView : UITableView<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, retain) NSArray *imageArray;

@property (nonatomic , copy) void (^block)(NSInteger index);
//当前选中的单元格IndexPath
@property(nonatomic,retain)NSIndexPath *selectedInexPath;

@end

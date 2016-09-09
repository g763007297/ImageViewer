//
//  BasePictureTableView.m
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import "GQBasePictureTableView.h"

@implementation GQBasePictureTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
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
    //逆时针旋转90度
    self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    //旋转之后宽、高互换了,所以重新设置frame
    self.frame = frame;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉垂直方向的滚动条
    self.showsVerticalScrollIndicator = NO;
    
    self.delegate = self;
    self.dataSource = self;
    
    //设置减速的方式， UIScrollViewDecelerationRateFast 为快速减速
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    
    self.selectedInexPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)setImageArray:(NSMutableArray *)imageArray
{
    _imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    [_imageArray addObjectsFromArray:imageArray];
    [self reloadData];
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    [super setRowHeight:rowHeight];
    
    //设置tableView滚动的起始位置、与终止位置
    CGFloat edge = (rowHeight-self.rowHeight)/2;
    self.contentInset = UIEdgeInsetsMake(edge,0,edge, 0);
}

#pragma mark - UITableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _imageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identify = @"GQBaseCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //将cell.contentView顺时针旋转90度
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
        cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
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

- (void) scrollViewDidScroll:(UIScrollView *)sender {
    [self getPageIndex];
}

//将单元格滚动至中间位置
- (void)scrollCellToCenter
{
    CGFloat edge = self.contentInset.top;
    
    float y = self.contentOffset.y + edge + self.rowHeight/2;
    int row = y/self.rowHeight;
    
    if (row >= self.imageArray.count || row < 0) {
        return;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)getPageIndex
{
    CGFloat edge = self.contentInset.top;
    
    float y = self.contentOffset.y + edge + self.rowHeight/2;
    int row = y/self.rowHeight;
    
    if (row >= self.imageArray.count || row < 0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    if (indexPath.row != self.selectedInexPath.row) {
        if (self.block) {
            self.block(row);
        }
        //记录选中的单元格IndexPath
        self.selectedInexPath = indexPath;
    }
}

@end

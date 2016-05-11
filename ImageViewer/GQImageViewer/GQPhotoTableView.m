//
//  PhotoTableView.m
//  Sunshine_mall
//
//  Created by apple on 15/4/23.
//  Copyright (c) 2015年 GQ. All rights reserved.
//

#import "GQPhotoTableView.h"
#import "GQPhotoScrollView.h"

@implementation GQPhotoTableView


- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.pagingEnabled = YES;
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"identifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //将cell.contentView顺时针旋转90度
        cell.contentView.transform = CGAffineTransformMakeRotation(M_PI_2);
        cell.backgroundColor = [UIColor clearColor];
        
        GQPhotoScrollView *photoSV = [[GQPhotoScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        photoSV.backgroundColor = [UIColor clearColor];
        photoSV.tag = 100;
        [cell.contentView addSubview:photoSV];
    }
    
    GQPhotoScrollView *photoSV = (GQPhotoScrollView *)[cell.contentView viewWithTag:100];
    
    photoSV.data = self.imageArray[indexPath.row];
    
    photoSV.row = indexPath.row;
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GQPhotoScrollView *photoSV = (GQPhotoScrollView *)[cell.contentView viewWithTag:100];
    [photoSV setZoomScale:1.0 animated:YES];
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (self.pageControl) {
//        UIPageControl *page = (UIPageControl *)[cell.contentView viewWithTag:101];
//        page.currentPage = indexPath.row;
//    }else{
//        UILabel *label = (UILabel *)[cell.contentView viewWithTag:101];
//        label.text = [NSString stringWithFormat:@"%@/%@",StringFormat(indexPath.row+1),StringFormat(self.imageArray?self.imageArray.count:self.data.count)];
//    }
}

@end

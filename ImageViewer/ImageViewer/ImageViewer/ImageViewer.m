//
//  ImageViewer.m
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import "ImageViewer.h"
#import "PhotoTableView.h"

@interface ImageViewer()

@property (nonatomic, assign) BOOL isVisible;

@end

@implementation ImageViewer

__strong static ImageViewer *imageViewerManager;

+ (ImageViewer *)sharedInstance {
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        imageViewerManager = [[super allocWithZone:nil] init];
    });
    return imageViewerManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone*)zone {
    return self;
}

- (void)initViewWithFrame:(CGRect)rect{
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    UIPageControl *page;
    UILabel *label ;
    if (self.pageControl) {
        page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(rect)-10, 0, 10)];
        page.numberOfPages = self.imageArray.count;
        page.tag = 101;
        page.currentPage = self.index;
        [self insertSubview:page atIndex:1];
    }else{
        label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(rect)/2 - 30, CGRectGetHeight(rect) - 20, 60, 15)];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 101;
        label.text = [NSString stringWithFormat:@"%ld/%ld",(self.index+1),self.imageArray.count];
        label.textColor = [UIColor darkGrayColor];
        [self insertSubview:label atIndex:1];
    }
    
    PhotoTableView *_tableView = [[PhotoTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(rect), CGRectGetMaxY(rect)) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.block = ^(NSInteger index){
        if (page) {
            page.currentPage = index;
        }else{
            label.text = [NSString stringWithFormat:@"%ld/%ld",(self.index+1),self.imageArray.count];
        }
    };
    _tableView.rowHeight = CGRectGetMaxX(rect);
    [self insertSubview:_tableView belowSubview:page?page:label];
    
    _tableView.pagingEnabled  = YES;
    
    //将所有的图片url赋给tableView显示
    _tableView.imageArray = self.imageArray;
    
    //滚动到指定的单元格
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.index inSection:0];
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)showView:(UIViewController *)viewController{
    if (_isVisible) {
        return;
    }else{
        _isVisible = YES;
    }
    CGRect rect;
    
    UIView *showView = viewController.navigationController.view?viewController.navigationController.view:viewController.view;
    
    rect = CGRectMake(0, 0, CGRectGetMaxX(showView.frame), CGRectGetMaxY(showView.frame));
    
    [self initViewWithFrame:rect];
    
    self.frame = CGRectMake(0, CGRectGetMaxY(showView.frame), CGRectGetMaxX(showView.frame), CGRectGetMaxY(showView.frame));
    
    [showView addSubview:self];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = rect;
                     } completion:^(BOOL finished) {
                     }];
}

- (void)dissMiss{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, CGRectGetMaxY(self.frame), CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
                     } completion:^(BOOL finished) {
                         [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                         self.frame = CGRectZero;
                         [self removeFromSuperview];
                         _isVisible = NO;
                     }];
}


@end

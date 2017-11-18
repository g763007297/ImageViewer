//
//  GQImageView.h
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GQImageView : UIImageView

@property (nonatomic,assign) BOOL showLoadingView;

/**
 配置图片显示界面
 */
- (void)configureImageView;

-(void)showLoading;

-(void)hideLoading;

@end

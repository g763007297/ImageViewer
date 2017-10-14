//
//  GQImageView.h
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GQImageCompletionBlock)(UIImage *image, NSError *error, NSURL *imageUrl);
typedef void(^GQImageProgressBlock) (CGFloat progress);

@interface GQImageView : UIImageView

@property (nonatomic,assign) BOOL showLoadingView;
@property (nonatomic,strong) NSURL *imageUrl;

/**
 配置图片显示界面
 */
- (void)configureImageView;

- (void)loadImage:(NSURL*)url
         progress:(GQImageProgressBlock)progress
         complete:(GQImageCompletionBlock)complete;

- (void)loadImage:(NSURL*)url
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageProgressBlock)progress
         complete:(GQImageCompletionBlock)complete;

- (void)loadImage:(NSURL*)url
 requestClassName:(NSString *)className
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageProgressBlock)progress
         complete:(GQImageCompletionBlock)complete;

- (void)cancelCurrentImageRequest;     //caller must call this method in its dealloc method

@end

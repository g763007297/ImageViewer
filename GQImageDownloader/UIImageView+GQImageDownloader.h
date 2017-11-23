//
//  UIImageView+GQImageDownloader.h
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GQImageCompletionBlock)(UIImage *image, NSError *error, NSURL *imageUrl);
typedef void(^GQImageProgressBlock) (CGFloat progress);

@interface UIImageView (GQImageDownloader)

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

//
//  UIImageView+GQImageDownloader.h
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GQImageDownloaderOperationManager.h"

@interface UIImageView (GQImageDownloader)

- (void)loadImage:(NSURL*)downloadUrl
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete;

- (void)loadImage:(NSURL*)downloadUrl
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete;

- (void)loadImage:(NSURL*)downloadUrl
 requestClassName:(NSString *)className
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete;

- (void)loadImage:(NSURL*)downloadUrl
 requestClassName:(NSString *)className
        cacheType:(GQImageDownloaderCacheType)cacheType
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete;

- (void)cancelCurrentImageRequest;

@end

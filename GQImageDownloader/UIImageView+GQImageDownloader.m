//
//  UIImageView+GQImageDownloader.m
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import "UIImageView+GQImageDownloader.h"
#import "GQImageDownloaderConst.h"
#import <objc/runtime.h>

@implementation UIImageView (GQImageDownloader)

GQ_DYNAMIC_PROPERTY_OBJECT(imageUrl, setImageUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC, NSURL*);
GQ_DYNAMIC_PROPERTY_OBJECT(progress, setProgress, OBJC_ASSOCIATION_COPY_NONATOMIC, GQImageDownloaderProgressBlock);
GQ_DYNAMIC_PROPERTY_OBJECT(complete, setComplete, OBJC_ASSOCIATION_COPY_NONATOMIC, GQImageDownloaderCompleteBlock);
GQ_DYNAMIC_PROPERTY_OBJECT(downloadOperation, setDownloadOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC, id<GQImageDownloaderOperationDelegate>);

- (void)dealloc
{
    [self cancelCurrentImageRequest];
}

- (void)cancelCurrentImageRequest
{
    [[self downloadOperation] cancel];
    [self setDownloadOperation:nil];
}

- (void)loadImage:(NSURL*)url
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete
{
    [self loadImage:url
        placeHolder:nil
           progress:progress
           complete:complete];
}

- (void)loadImage:(NSURL*)url
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete
{
    [self loadImage:url
   requestClassName:nil
        placeHolder:placeHolderImage
           progress:progress
           complete:complete];
}

- (void)loadImage:(NSURL*)url
 requestClassName:(NSString *)className
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete {
    [self loadImage:url
   requestClassName:className
          cacheType:GQImageDownloaderCacheTypeDisk
        placeHolder:placeHolderImage
           progress:progress
           complete:complete];
}

- (void)loadImage:(NSURL*)url
 requestClassName:(NSString *)className
        cacheType:(GQImageDownloaderCacheType)cacheType
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageDownloaderProgressBlock)progress
         complete:(GQImageDownloaderCompleteBlock)complete {
    if(nil == url || [@"" isEqualToString:url.absoluteString] ) {
        return;
    }
    self.complete = [complete copy];
    self.progress = [progress copy];
    self.imageUrl = url;
    [self cancelCurrentImageRequest];
    
    self.image = placeHolderImage;
    GQWeakify(self);
    __strong id<GQImageDownloaderOperationDelegate> _downloadOperation = [[GQImageDownloaderOperationManager sharedManager]
                                                                          loadWithURL:self.imageUrl
                                                                          withURLRequestClassName:className
                                                                          progress:^(CGFloat progress) {
                                                                              GQStrongify(self);
                                                                              if (self.progress) {
                                                                                  self.progress(progress);
                                                                              }
                                                                          }complete:^(UIImage *image, NSURL *url, NSError *error) {
                                                                              GQStrongify(self);
                                                                              if (image) {
                                                                                  self.image = image;
                                                                              }
                                                                              if (self.complete) {
                                                                                  self.complete(image,url,error);
                                                                              }
                                                                          }];
    [self setDownloadOperation:_downloadOperation];
}

@end

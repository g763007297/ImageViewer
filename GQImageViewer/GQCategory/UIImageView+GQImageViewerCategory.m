//
//  UIImageView+GQImageViewerCategory.m
//  ImageViewer
//
//  Created by 高旗 on 2017/11/18.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import "UIImageView+GQImageViewerCategory.h"
#import "GQImageViewerOperationManager.h"
#import "GQImageViewerConst.h"
#import <objc/runtime.h>

@implementation UIImageView (GQImageViewerCategory)

GQ_DYNAMIC_PROPERTY_OBJECT(imageUrl, setImageUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC, NSURL*);
GQ_DYNAMIC_PROPERTY_OBJECT(progress, setProgress, OBJC_ASSOCIATION_COPY_NONATOMIC, GQImageProgressBlock);
GQ_DYNAMIC_PROPERTY_OBJECT(complete, setComplete, OBJC_ASSOCIATION_COPY_NONATOMIC, GQImageCompletionBlock);
GQ_DYNAMIC_PROPERTY_OBJECT(downloadOperation, setDownloadOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC, id<GQImageViwerOperationDelegate>);

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
         progress:(GQImageProgressBlock)progress
         complete:(GQImageCompletionBlock)complete
{
    [self loadImage:url
        placeHolder:nil
           progress:progress
           complete:complete];
}

- (void)loadImage:(NSURL*)url
      placeHolder:(UIImage *)placeHolderImage
         progress:(GQImageProgressBlock)progress
         complete:(GQImageCompletionBlock)complete
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
         progress:(GQImageProgressBlock)progress
         complete:(GQImageCompletionBlock)complete {
    
    if(nil == url || [@"" isEqualToString:url.absoluteString] ) {
        return;
    }
    self.complete = [complete copy];
    self.progress = [progress copy];
    self.imageUrl = url;
    [self cancelCurrentImageRequest];
    
    self.image = placeHolderImage;
    GQWeakify(self);
    __strong id<GQImageViwerOperationDelegate> _downloadOperation = [[GQImageViewerOperationManager sharedManager]
                                                                      loadWithURL:self.imageUrl
                                                                      withURLRequestClassName:className
                                                                      progress:^(CGFloat progress) {
                                                                          GQStrongify(self);
                                                                          if (self.progress) {
                                                                              self.progress(progress);
                                                                          }
                                                                      }complete:^(NSURL *url, UIImage *image, NSError *error) {
                                                                          GQStrongify(self);
                                                                          if (image) {
                                                                              self.image = image;
                                                                          }
                                                                          if (self.complete) {
                                                                              self.complete(image,error,url);
                                                                          }
                                                                      }];
    [self setDownloadOperation:_downloadOperation];
}

@end

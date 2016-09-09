//
//  GQImageView.m
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageView.h"
#import "GQImageDataDownload.h"
#import "GQImageViewerConst.h"

@interface GQImageView()

@property (nonatomic, copy) GQImageCompletionBlock complete;
@property (nonatomic, strong) GQImageDataDownload *download;

@end

@implementation GQImageView

- (void)dealloc
{
    _download = nil;
    [self cancelCurrentImageRequest];
}

- (void)cancelCurrentImageRequest
{
    [_download cancel];
}

- (void)loadImage:(NSURL*)url complete:(GQImageCompletionBlock)complete
{
    [self loadImage:url placeHolder:nil complete:complete];
}

- (void)loadImage:(NSURL*)url placeHolder:(UIImage *)placeHolderImage complete:(GQImageCompletionBlock)complete
{
    if(nil == url || [@"" isEqualToString:url.absoluteString] ) {
        return;
    }
    self.complete = [complete copy];
    self.imageUrl = url;
    [self cancelCurrentImageRequest];
    self.image = placeHolderImage;
    GQWeakify(self);
    _download = [[GQImageDataDownload alloc]
                 initWithURL:_imageUrl
                 progress:^(CGFloat progress) {
                     
                 }complete:^(NSURL *url, UIImage *image, NSError *error) {
                     GQStrongify(self);
                     self.image = image;
                     if (self.complete) {
                         self.complete(image,error,url);
                     }
                 }];
}

@end

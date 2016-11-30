//
//  GQImageDataOperation.m
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageDataDownload.h"
#import "GQImageViewerConst.h"
#import "GQImageCacheManager.h"
#import "GQURLOperation.h"
#import "GQHttpRequestManager.h"
#import "NSData+GQImageViewrCategory.h"

@interface GQImageDataDownload()

@property (nonatomic, copy) completeBlock complete;
@property (nonatomic, copy) progressBlock progress;
@property (nonatomic, copy) GQURLOperation *operation;

@end

@implementation GQImageDataDownload

- (id)initWithURL:(NSURL *)url progress:(progressBlock)progress complete:(completeBlock)complete
{
    self = [super init];
    if (self) {
        _imageUrl = url;
        _complete = [complete copy];
        _progress = [progress copy];
        [self startRequest];
    }
    return self;
}

- (void)cancel
{
    [_operation cancel];
    _operation = nil;
    _complete = nil;
    _progress = nil;
}

- (void)startRequest
{
    __block UIImage *image = nil;
    if(![[GQImageCacheManager sharedManager] isImageInMemoryCacheWithUrl:_imageUrl.absoluteString]){
        GQWeakify(self);
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:_imageUrl];
        _operation = [[GQURLOperation alloc]
                      initWithURLRequest:request
                      progress:^(float progress) {
                          GQStrongify(self);
                          if (self.progress) {
                              self.progress(progress);
                          }
                      } completion:^(GQURLOperation *urlOperation, BOOL requestSuccess, NSError *error) {
                          GQStrongify(self);
                          NSData *data = urlOperation.operationData;
                          image = [data gqImageWithData];
                          if (image) {
                              [[GQImageCacheManager sharedManager] saveImage:image withUrl:_imageUrl.absoluteString];
                          }
                          if (self.complete) {
                              self.complete(self.imageUrl,image,error);
                          }
                      }];
        [[GQHttpRequestManager sharedHttpRequestManager] addOperation:_operation];
    }else{
        image = [[GQImageCacheManager sharedManager] getImageFromCacheWithUrl:_imageUrl.absoluteString];
        if (self.complete) {
            self.complete(self.imageUrl,image,nil);
        }
    }
}

@end

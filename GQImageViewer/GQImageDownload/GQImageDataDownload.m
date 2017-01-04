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
#import "GQImageRequestOperation.h"
#import "GQImageHttpRequestManager.h"
#import "NSData+GQImageViewrCategory.h"
#import "GQBaseURLRequest.h"

@interface GQImageDataDownload()

@property (nonatomic, copy) completeBlock complete;
@property (nonatomic, copy) progressBlock progress;
@property (nonatomic, copy) GQImageRequestOperation *operation;
@property (assign, nonatomic) Class requstClass;

@end

@implementation GQImageDataDownload

- (id)initWithURL:(NSURL *)url progress:(progressBlock)progress complete:(completeBlock)complete
{
    self = [super init];
    if (self) {
        _requstClass = [GQBaseURLRequest class];
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

- (void)setURLRequestClass:(Class)requestClass {
    _requstClass = requestClass ?: [GQBaseURLRequest class];
}

- (void)startRequest
{
    __block UIImage *image = nil;
    if(![[GQImageCacheManager sharedManager] isImageInMemoryCacheWithUrl:_imageUrl.absoluteString]){
        GQWeakify(self);
        GQBaseURLRequest *request = [[_requstClass alloc] initWithURL:_imageUrl];
        _operation = [[GQImageRequestOperation alloc]
                      initWithURLRequest:request
                      progress:^(float progress) {
                          GQStrongify(self);
                          if (self.progress) {
                              self.progress(progress);
                          }
                      } completion:^(GQImageRequestOperation *urlOperation, BOOL requestSuccess, NSError *error) {
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
        [[GQImageHttpRequestManager sharedHttpRequestManager] addOperation:_operation];
    }else{
        image = [[GQImageCacheManager sharedManager] getImageFromCacheWithUrl:_imageUrl.absoluteString];
        if (self.complete) {
            self.complete(self.imageUrl,image,nil);
        }
    }
}

@end

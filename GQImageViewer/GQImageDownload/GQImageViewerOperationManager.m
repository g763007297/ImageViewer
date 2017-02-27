//
//  GQImageViewerOperationManager.m
//  ImageViewer
//
//  Created by 高旗 on 17/2/27.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import "GQImageViewerOperationManager.h"
#import "GQImageViewerConst.h"
#import "GQImageCacheManager.h"
#import "GQImageDataDownload.h"

@interface GQImageViewerOperationManager()
#if !OS_OBJECT_USE_OBJC
@property (nonatomic, assign) dispatch_queue_t saveDataDispatchQueue;
@property (nonatomic, assign) dispatch_group_t saveDataDispatchGroup;
#else
@property (nonatomic, strong) dispatch_queue_t saveDataDispatchQueue;
@property (nonatomic, strong) dispatch_group_t saveDataDispatchGroup;
#endif

@end

@implementation GQImageViewerOperationManager

GQOBJECT_SINGLETON_BOILERPLATE(GQImageViewerOperationManager, sharedManager)

- (id<GQImageViwerOperationDelegate>)loadWithURL:(NSURL *)url progress:(GQImageViwerProgressBlock)progressBlock complete:(GQImageViwerCompleteBlock)completeBlock {
    __block UIImage *image = nil;
    if(![[GQImageCacheManager sharedManager] isImageInMemoryCacheWithUrl:url.absoluteString]){
        id<GQImageViwerOperationDelegate> operation = [[GQImageDataDownload sharedDownloadManager]
                                                       downloadWithURL:url
                                                       progress:^(CGFloat progress) {
                                                           dispatch_main_async_safe(^{
                                                               if (progress) {
                                                                   progressBlock(progress);
                                                               }
                                                           });
                                                       } complete:^(NSURL *url, UIImage *image, NSError *error) {
                                                           [[GQImageCacheManager sharedManager] saveImage:image withUrl:url.absoluteString];
                                                           dispatch_main_async_safe(^{
                                                               if (completeBlock) {
                                                                   completeBlock(url,image,error);
                                                               }
                                                           });
                                                       }];
        return operation;
    }else{
        dispatch_group_async(dispatch_group_create(), dispatch_queue_create("com.ISS.GQImageCacheManager", DISPATCH_QUEUE_SERIAL), ^{
            image = [[GQImageCacheManager sharedManager] getImageFromCacheWithUrl:url.absoluteString];
            dispatch_main_async_safe(^{
                completeBlock(url,image,nil);
            });
        });
        return nil;
    }
}

@end

//
//  GQImageDownloaderOperationManager.m
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import "GQImageDownloaderOperationManager.h"
#import "GQImageDownloaderConst.h"
#import "GQImageCacheManager.h"

@interface GQImageDownloaderOperationManager()
#if !OS_OBJECT_USE_OBJC
@property (nonatomic, assign) dispatch_queue_t saveDataDispatchQueue;
@property (nonatomic, assign) dispatch_group_t saveDataDispatchGroup;
#else
@property (nonatomic, strong) dispatch_queue_t saveDataDispatchQueue;
@property (nonatomic, strong) dispatch_group_t saveDataDispatchGroup;
#endif

@end

@implementation GQImageDownloaderOperationManager

GQOBJECT_SINGLETON_BOILERPLATE(GQImageDownloaderOperationManager, sharedManager)

- (id<GQImageDownloaderOperationDelegate>)loadWithURL:(NSURL *)url
                         withURLRequestClassName:(NSString *)className
                                        progress:(GQImageDownloaderProgressBlock)progressBlock
                                        complete:(GQImageDownloaderCompleteBlock)completeBlock {
    [[GQImageDataDownloader sharedDownloadManager] setURLRequestClass:NSClassFromString(className)];
    __block UIImage *image = nil;
    if(![[GQImageCacheManager sharedManager] isImageInMemoryCacheWithUrl:url.absoluteString]){
        id<GQImageDownloaderOperationDelegate> operation = [[GQImageDataDownloader sharedDownloadManager]
                                                       downloadWithURL:url
                                                       progress:^(CGFloat progress) {
                                                           dispatch_main_async_safe(^{
                                                               if (progress) {
                                                                   progressBlock(progress);
                                                               }
                                                           });
                                                       } complete:^(UIImage *image, NSURL *url, NSError *error) {
                                                           [[GQImageCacheManager sharedManager] saveImage:image withUrl:url.absoluteString];
                                                           dispatch_main_async_safe(^{
                                                               if (completeBlock) {
                                                                   completeBlock(image, url ,error);
                                                               }
                                                           });
                                                       }];
        return operation;
    }else{
        dispatch_group_async(dispatch_group_create(), dispatch_queue_create("com.ISS.GQImageCacheManager", DISPATCH_QUEUE_SERIAL), ^{
            image = [[GQImageCacheManager sharedManager] getImageFromCacheWithUrl:url.absoluteString];
            dispatch_main_async_safe(^{
                completeBlock(image,url,nil);
            });
        });
        return nil;
    }
}

@end

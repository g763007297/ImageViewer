//
//  GQImageDownloaderOperationManager.m
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import "GQImageDownloaderOperationManager.h"
#import "GQImageDownloaderConst.h"

@implementation GQImageDownloaderOperationManager

GQOBJECT_SINGLETON_BOILERPLATE(GQImageDownloaderOperationManager, sharedManager)

- (id<GQImageDownloaderOperationDelegate>)loadWithURL:(NSURL *)url
                              withURLRequestClassName:(NSString *)className
                                             progress:(GQImageDownloaderProgressBlock)progressBlock
                                             complete:(GQImageDownloaderCompleteBlock)completeBlock {
    return [self loadWithURL:url
     withURLRequestClassName:className
                   cacheType:GQImageDownloaderCacheTypeDisk
                    progress:progressBlock
                    complete:completeBlock];
}

- (id<GQImageDownloaderOperationDelegate>)loadWithURL:(NSURL *)url
                              withURLRequestClassName:(NSString *)className
                                            cacheType:(GQImageDownloaderCacheType)type
                                             progress:(GQImageDownloaderProgressBlock)progressBlock
                                             complete:(GQImageDownloaderCompleteBlock)completeBlock {
    [[GQImageDataDownloader sharedDownloadManager] setURLRequestClass:NSClassFromString(className)];
    __block UIImage *image = nil;
    
    BOOL isCacheToDisk = ( type == GQImageDownloaderCacheTypeDisk );
    
    BOOL isExistDisk = [[GQImageCacheManager sharedManager] isImageExistDiskWithUrl:url.absoluteString];
    
    BOOL isExistMemory = [[GQImageCacheManager sharedManager] isImageInMemoryCacheWithUrl:url.absoluteString];
    
    if(!isExistMemory || (isCacheToDisk && !isExistDisk)) {
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
    } else {
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

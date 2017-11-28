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
                                            cacheType:(GQImageDownloaderCacheType)cacheType
                                             progress:(GQImageDownloaderProgressBlock)progressBlock
                                             complete:(GQImageDownloaderCompleteBlock)completeBlock {
    [[GQImageDataDownloader sharedDownloadManager] setURLRequestClass:NSClassFromString(className)];
    __block UIImage *image = nil;
    
    BOOL isCacheToDisk = ( cacheType == GQImageDownloaderCacheTypeDisk );
    BOOL isCacheToMemory = ( cacheType == GQImageDownloaderCacheTypeOnlyMemory );
    
    BOOL isExistDisk = [[GQImageCacheManager sharedManager] isImageExistDiskWithUrl:url.absoluteString];
    BOOL isExistMemory = [[GQImageCacheManager sharedManager] isImageInMemoryCacheWithUrl:url.absoluteString];
    
    BOOL needDownloadFromNetwork = NO;
    
    //如果缓存类型为缓存至硬盘但是不存在于硬盘中、缓存类型为缓存至内存中但是不存在于内存中。
    if ( ( isCacheToDisk && !isExistDisk ) || ( isCacheToMemory && !isExistMemory ) ) {
        if (isExistMemory) { //如果此时存在于内存中就需要清理掉。
            [[GQImageCacheManager sharedManager] removeImageFromCacheWithUrl:url.absoluteString];
        }
        needDownloadFromNetwork = YES;
    }
    
    if(needDownloadFromNetwork) {
        id<GQImageDownloaderOperationDelegate> operation = [[GQImageDataDownloader sharedDownloadManager]
                                                            downloadWithURL:url
                                                            progress:^(CGFloat progress) {
                                                                dispatch_main_async_safe(^{
                                                                    if (progress) {
                                                                        progressBlock(progress);
                                                                    }
                                                                });
                                                            } complete:^(UIImage *image, NSURL *url, NSError *error) {
                                                                
                                                                [[GQImageCacheManager sharedManager] saveImage:image withUrl:url.absoluteString withCacheType:cacheType];
                                                                
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

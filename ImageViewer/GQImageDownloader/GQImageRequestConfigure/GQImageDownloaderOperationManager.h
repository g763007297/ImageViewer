//
//  GQImageDownloaderOperationManager.h
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GQImageCacheManager.h"
#import "GQImageDataDownloader.h"

@interface GQImageDownloaderOperationManager : NSObject

+ (instancetype)sharedManager;

- (id<GQImageDownloaderOperationDelegate>)loadWithURL:(NSURL *)url
                              withURLRequestClassName:(NSString *)className
                                             progress:(GQImageDownloaderProgressBlock)progressBlock
                                             complete:(GQImageDownloaderCompleteBlock)completeBlock;

- (id<GQImageDownloaderOperationDelegate>)loadWithURL:(NSURL *)url
                              withURLRequestClassName:(NSString *)className
                                            cacheType:(GQImageDownloaderCacheType)type
                                             progress:(GQImageDownloaderProgressBlock)progressBlock
                                             complete:(GQImageDownloaderCompleteBlock)completeBlock;

@end

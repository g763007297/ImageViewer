//
//  GQImageDataDownloader.h
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GQImageDownloaderURLConnectionOperation.h"
#import "GQImageDownloaderSessionOperation.h"

typedef void(^GQImageDownloaderCompleteBlock)(UIImage* image, NSURL *url, NSError *error);
typedef void(^GQImageDownloaderProgressBlock)(CGFloat progress);

@interface GQImageDataDownloader : NSObject

+ (instancetype)sharedDownloadManager;

/**
 设置图片处理请求class
 
 param requestClass
 */
- (void)setURLRequestClass:(Class)requestClass;

- (id<GQImageDownloaderOperationDelegate>)downloadWithURL:(NSURL *)url
                                                 progress:(GQImageDownloaderProgressBlock)progressBlock
                                                 complete:(GQImageDownloaderCompleteBlock)completeBlock;

- (void)suspendLoading;

- (void)restoreLoading;

- (void)cancelAllOpration;

@end

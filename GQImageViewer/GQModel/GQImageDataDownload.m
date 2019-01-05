//
//  GQImageDataDownload.m
//  ImageViewer
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import "GQImageDataDownload.h"
#import "GQImageViewerConst.h"

#ifndef GQ_CoreSD
#import "GQImageDataDownloader.h"
#endif

@implementation GQImageDataDownload

GQOBJECT_SINGLETON_BOILERPLATE(GQImageDataDownload, sharedDownloadManager)

/**
 设置图片处理请求class
 
 param requestClass
 */
- (void)setURLRequestClass:(Class)requestClass {
#ifndef GQ_CoreSD
    [[GQImageDataDownloader sharedDownloadManager] setURLRequestClass:requestClass];
#endif
}

@end

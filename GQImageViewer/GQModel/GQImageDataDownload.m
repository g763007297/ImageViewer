//
//  GQImageDataDownload.m
//  ImageViewer
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import "GQImageDataDownload.h"
#import "GQImageViewerConst.h"

#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")

#else
#import "GQImageDataDownloader.h"
#endif

@implementation GQImageDataDownload

GQOBJECT_SINGLETON_BOILERPLATE(GQImageDataDownload, sharedDownloadManager)

/**
 设置图片处理请求class
 
 param requestClass
 */
- (void)setURLRequestClass:(Class)requestClass {
#if __has_include(<SDWebImage/UIImageView+WebCache.h>) || __has_include("UIImageView+WebCache.h")
    
#else
    [[GQImageDataDownloader sharedDownloadManager] setURLRequestClass:requestClass];
#endif
}

@end

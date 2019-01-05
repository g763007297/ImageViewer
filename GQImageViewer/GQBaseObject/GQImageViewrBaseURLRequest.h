//
//  GQImageViewrBaseURLRequest.m
//  ImageViewer
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 tusm. All rights reserved.
//

#ifdef GQ_CoreSD
    #import <UIKit/UIKit.h>
@interface GQImageViewrBaseURLRequest : NSObject
#else
    #import "GQImageDownloaderBaseURLRequest.h"
@interface GQImageViewrBaseURLRequest : GQImageDownloaderBaseURLRequest
#endif

@end

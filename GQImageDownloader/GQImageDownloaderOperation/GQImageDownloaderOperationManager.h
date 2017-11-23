//
//  GQImageDownloaderOperationManager.h
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GQImageDataDownloader.h"

@interface GQImageDownloaderOperationManager : NSObject

+ (instancetype)sharedManager;

- (id<GQImageDownloaderOperationDelegate>)loadWithURL:(NSURL *)url
                         withURLRequestClassName:(NSString *)className
                                        progress:(GQImageDownloaderProgressBlock)progress
                                        complete:(GQImageDownloaderCompleteBlock)complete;

@end

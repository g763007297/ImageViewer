//
//  GQImageViewerOperationManager.h
//  ImageViewer
//
//  Created by 高旗 on 17/2/27.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GQImageDataDownload.h"

@interface GQImageViewerOperationManager : NSObject

+ (instancetype)sharedManager;

- (id<GQImageViwerOperationDelegate>)loadWithURL:(NSURL *)url progress:(GQImageViwerProgressBlock)progress complete:(GQImageViwerCompleteBlock)complete;

@end

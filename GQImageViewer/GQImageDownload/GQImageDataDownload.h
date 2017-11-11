//
//  GQImageDataOperation.h
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GQImageRequestOperation.h"

typedef void(^GQImageViwerCompleteBlock)(NSURL *url, UIImage* image, NSError *error);
typedef void(^GQImageViwerProgressBlock)(CGFloat progress);
typedef void(^GQImageViwerNoParamsBlock)(void);

@interface GQImageDataDownload : NSObject

+ (instancetype)sharedDownloadManager;

/**
 设置图片处理请求class

 @param requestClass
 */
- (void)setURLRequestClass:(Class)requestClass;

- (id<GQImageViwerOperationDelegate>)downloadWithURL:(NSURL *)url progress:(GQImageViwerProgressBlock)progress complete:(GQImageViwerCompleteBlock)complete;

- (void)suspendLoading;

- (void)restoreLoading;

- (void)cancelAllOpration;

@end

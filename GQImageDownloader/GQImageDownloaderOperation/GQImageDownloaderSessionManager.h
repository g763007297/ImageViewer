//
//  GQImageDownloaderSessionManager.h
//  GQImageDownloaderDemo
//
//  Created by 高旗 on 2017/11/24.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_CLASS_AVAILABLE(NSURLSESSION_AVAILABLE, 8_0)
@interface GQImageDownloaderSessionManager : NSObject<NSURLSessionDelegate,NSURLSessionTaskDelegate>

- (instancetype)initWithOperationQueue:(NSOperationQueue *)operationQueue;

@property (strong, nonatomic) NSURLSession *session;

@end

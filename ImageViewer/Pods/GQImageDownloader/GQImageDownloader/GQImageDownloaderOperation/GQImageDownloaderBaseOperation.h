//
//  GQOperation.h
//  GQNetWorkDemo
//
//  Created by 高旗 on 16/10/23.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GQImageDownloaderOperationDelegate.h"

@class GQImageDownloaderBaseOperation;

typedef void (^GQImageDownloaderChangeHandler) (float progress);
typedef void (^GQImageDownloaderCancelHandler) (void);
typedef void (^GQImageDownloaderCompletionHandler)(GQImageDownloaderBaseOperation *urlOperation,BOOL requestSuccess, NSError *error);

enum {
    GQImageDownloaderStateReady = 0,
    GQImageDownloaderStateExecuting,
    GQImageDownloaderStateFinished
};
typedef NSUInteger GQImageDownloaderState;

@interface GQImageDownloaderBaseOperation : NSOperation <GQImageDownloaderOperationDelegate>

@property (nonatomic, strong) NSURLRequest                      *operationRequest;
@property (nonatomic, strong) NSData                            *responseData;
@property (nonatomic, strong) NSHTTPURLResponse                 *operationURLResponse;
@property (nonatomic, strong) NSFileHandle                      *operationFileHandle;

@property (nonatomic, strong) NSString                          *operationSavePath;

@property (nonatomic, strong) NSData                            *certificateData;

@property (nonatomic, strong) NSURLSession                      *operationSession NS_AVAILABLE_IOS(8_0);

@property (nonatomic, strong) NSMutableData                     *operationData;
@property (nonatomic, assign) CFRunLoopRef                      operationRunLoop;
@property (nonatomic, readwrite) UIBackgroundTaskIdentifier     backgroundTaskIdentifier;

@property (nonatomic, readwrite) GQImageDownloaderState                     state;
@property (nonatomic, readwrite) float                          expectedContentLength;
@property (nonatomic, readwrite) float                          receivedContentLength;

@property (nonatomic, copy) GQImageDownloaderChangeHandler          operationProgressBlock;
@property (nonatomic, copy) GQImageDownloaderCancelHandler          operationCancelBlock;
@property (nonatomic, copy) GQImageDownloaderCompletionHandler      operationCompletionBlock;

- (GQImageDownloaderBaseOperation *)initWithURLRequest:(NSURLRequest *)urlRequest
                                              progress:(GQImageDownloaderChangeHandler)onProgressBlock
                                                cancel:(GQImageDownloaderCancelHandler)onCancelBlock
                                            completion:(GQImageDownloaderCompletionHandler)onCompletionBlock;

- (void)finish;
- (void)handleResponseData:(NSData *)data;
- (void)callCompletionBlockWithResponse:(NSData *)response
                        requestSuccess:(BOOL)requestSuccess
                                 error:(NSError *)error;

@end

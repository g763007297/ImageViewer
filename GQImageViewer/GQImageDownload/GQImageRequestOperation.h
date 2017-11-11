//
//  GQUrlConnectionOperation.h
//  GQNetWorkDemo
//
//  Created by 高旗 on 16/5/27.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GQImageViwerOperationDelegate.h"
@class GQImageRequestOperation;

enum {
    GQImageRequestStateReady = 0,
    GQImageRequestStateExecuting,
    GQImageRequestStateFinished
};
typedef NSUInteger GQImageRequestState;

typedef void (^GQImageRequestChangeHandler) (float progress);
typedef void (^GQImageRequestCancelHandler) (void);
typedef void (^GQImageRequestCompletionHandler)(GQImageRequestOperation *urlOperation,BOOL requestSuccess, NSError *error);

@interface GQImageRequestOperation : NSOperation <GQImageViwerOperationDelegate>

@property (nonatomic, strong) NSURLRequest                      *operationRequest;
@property (nonatomic, strong) NSData                            *responseData;
@property (nonatomic, strong) NSHTTPURLResponse                 *operationURLResponse;
@property (nonatomic, readwrite) NSUInteger                     timeoutInterval;

@property (nonatomic, strong) NSURLSession                      *operationSession;

@property (nonatomic, strong) NSURLSessionDataTask              *operationSessionTask;

@property (nonatomic, strong) NSURLConnection                   *operationConnection;
@property (nonatomic, strong) NSMutableData                     *operationData;
@property (nonatomic, assign) CFRunLoopRef                      operationRunLoop;
@property (nonatomic, readwrite) UIBackgroundTaskIdentifier     backgroundTaskIdentifier;

@property (nonatomic, readwrite) GQImageRequestState            state;
@property (nonatomic, readwrite) float                          expectedContentLength;
@property (nonatomic, readwrite) float                          receivedContentLength;

@property (nonatomic, copy) GQImageRequestChangeHandler          operationProgressBlock;
@property (nonatomic, copy) GQImageRequestCancelHandler          operationCancelBlock;
@property (nonatomic, copy) GQImageRequestCompletionHandler      operationCompletionBlock;

- (GQImageRequestOperation *)initWithURLRequest:(NSURLRequest *)urlRequest
                                       progress:(GQImageRequestChangeHandler)onProgressBlock
                                         cancel:(GQImageRequestCancelHandler)onCancelBlock
                                     completion:(GQImageRequestCompletionHandler)onCompletionBlock;

@end

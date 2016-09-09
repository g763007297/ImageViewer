//
//  GQUrlConnectionOperation.h
//  GQNetWorkDemo
//
//  Created by 高旗 on 16/5/27.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class GQURLOperation;

enum {
    GQURLStateReady = 0,
    GQURLStateExecuting,
    GQURLStateFinished
};
typedef NSUInteger GQURLState;

typedef void (^GQHTTPRequestChangeHandler) (float progress);
typedef void (^GQHTTPRequestCompletionHandler)(GQURLOperation *urlOperation,BOOL requestSuccess, NSError *error);

@interface GQURLOperation : NSOperation

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

@property (nonatomic, readwrite) GQURLState                     state;
@property (nonatomic, readwrite) float                          expectedContentLength;
@property (nonatomic, readwrite) float                          receivedContentLength;

@property (nonatomic, copy) GQHTTPRequestChangeHandler          operationProgressBlock;
@property (nonatomic, copy) GQHTTPRequestCompletionHandler      operationCompletionBlock;

- (GQURLOperation *)initWithURLRequest:(NSURLRequest *)urlRequest
                              progress:(GQHTTPRequestChangeHandler)onProgressBlock
                            completion:(GQHTTPRequestCompletionHandler)onCompletionBlock;

@end

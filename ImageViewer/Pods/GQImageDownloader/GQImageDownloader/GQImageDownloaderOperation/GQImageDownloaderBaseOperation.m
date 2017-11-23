//
//  GQOperation.m
//  GQNetWorkDemo
//
//  Created by 高旗 on 16/10/23.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageDownloaderBaseOperation.h"

@interface GQImageDownloaderBaseOperation()

@end

@implementation GQImageDownloaderBaseOperation

@synthesize state = _state;

static NSInteger GQHTTPRequestTaskCount = 0;

- (void)dealloc
{
    self.operationRequest = nil;
    self.operationURLResponse = nil;
    self.operationData = nil;
    self.responseData = nil;
}

- (GQImageDownloaderBaseOperation *)initWithURLRequest:(NSURLRequest *)urlRequest
                                       progress:(GQImageDownloaderChangeHandler)onProgressBlock
                                         cancel:(GQImageDownloaderCancelHandler)onCancelBlock
                                     completion:(GQImageDownloaderCompletionHandler)onCompletionBlock;

{
    self = [super init];
    self.operationData = [[NSMutableData alloc] init];
    self.operationRequest = urlRequest;
    
    if (onProgressBlock) {
        _operationProgressBlock = [onProgressBlock copy];
    }
    if (onCancelBlock) {
        _operationCancelBlock = [onCancelBlock copy];
    }
    if (onCompletionBlock) {
        _operationCompletionBlock = [onCompletionBlock copy];
    }
    return self;
}

- (void)cancel
{
    if(![self isFinished]){
        return;
    }
    [super cancel];
    [self finish];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return self.state == GQImageDownloaderStateFinished;
}

- (BOOL)isExecuting
{
    return self.state == GQImageDownloaderStateExecuting;
}

- (GQImageDownloaderState)state
{
    @synchronized(self) {
        return _state;
    }
}

- (void)setState:(GQImageDownloaderState)newState
{
    @synchronized(self) {
        [self willChangeValueForKey:@"state"];
        _state = newState;
        [self didChangeValueForKey:@"state"];
    }
}

- (void)main
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self increaseSVHTTPRequestTaskCount];
    });
    
    [self willChangeValueForKey:@"isExecuting"];
    self.state = GQImageDownloaderStateExecuting;
    [self didChangeValueForKey:@"isExecuting"];
    
#if TARGET_OS_IPHONE
    // all requests should complete and run completion block unless we explicitely cancel them.
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if(self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    }];
#endif
    if(self.operationSavePath) {
        [[NSFileManager defaultManager] createFileAtPath:self.operationSavePath contents:nil attributes:nil];
        self.operationFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.operationSavePath];
    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
        BOOL inBackgroundAndInOperationQueue = (currentQueue != nil && currentQueue != [NSOperationQueue mainQueue]);
        
        if(inBackgroundAndInOperationQueue) {
            self.operationRunLoop = CFRunLoopGetCurrent();
            BOOL isWaiting = CFRunLoopIsWaiting(self.operationRunLoop);
            isWaiting?CFRunLoopWakeUp(self.operationRunLoop):CFRunLoopRun();
        }
    }
}

- (void)finish
{
    [self decreaseSVHTTPRequestTaskCount];
    
#if TARGET_OS_IPHONE
    if(self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
#endif
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.state = GQImageDownloaderStateFinished;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)increaseSVHTTPRequestTaskCount
{
    GQHTTPRequestTaskCount++;
    [self toggleNetworkActivityIndicator];
}

- (void)decreaseSVHTTPRequestTaskCount
{
    GQHTTPRequestTaskCount = MAX(0, GQHTTPRequestTaskCount-1);
    [self toggleNetworkActivityIndicator];
}

- (void)toggleNetworkActivityIndicator
{
#if TARGET_OS_IPHONE
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(GQHTTPRequestTaskCount > 0)];
    });
#endif
}

#pragma mark -- HandleResponseData

- (void)handleResponseData:(NSData *)data{
    [self.operationData appendData:data];
    
    if(self.operationProgressBlock) {
        //If its -1 that means the header does not have the content size value
        if(self.expectedContentLength != -1) {
            self.receivedContentLength += data.length;
            self.operationProgressBlock(self.receivedContentLength/self.expectedContentLength);
        } else {
            //we dont know the full size so always return -1 as the progress
            self.operationProgressBlock(-1);
        }
    }
}

-(void)callCompletionBlockWithResponse:(NSData *)response
                        requestSuccess:(BOOL)requestSuccess
                                 error:(NSError *)error
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        if(self.operationRunLoop){
            CFRunLoopStop(self.operationRunLoop);
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.responseData = self.operationData;
        NSError *serverError = error;
        if(!serverError) {
            serverError = [NSError errorWithDomain:NSURLErrorDomain
                                              code:NSURLErrorBadServerResponse
                                          userInfo:nil];
        }
        
        if(self.operationCompletionBlock && self.state != GQImageDownloaderStateFinished) {
            self.operationCompletionBlock(self,requestSuccess,requestSuccess?nil:serverError);
        }
        [self finish];
    });
}

@end

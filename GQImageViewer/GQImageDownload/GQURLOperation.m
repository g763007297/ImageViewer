//
//  GQUrlConnectionOperation.m
//  GQNetWorkDemo
//
//  Created by 高旗 on 16/5/27.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQURLOperation.h"

#import "GQImageViewerConst.h"

@interface GQURLOperation()<NSURLConnectionDelegate,NSURLConnectionDataDelegate,NSURLSessionDelegate,NSURLSessionTaskDelegate>

@end

@implementation GQURLOperation

@synthesize state = _state;

static NSInteger GQHTTPRequestTaskCount = 0;

- (void)dealloc
{
    self.operationRequest = nil;
    self.operationURLResponse = nil;
    self.operationData = nil;
    self.responseData = nil;
    self.operationSession = nil;
    self.operationSessionTask = nil;
    self.operationConnection = nil;
    
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_saveDataDispatchGroup);
    dispatch_release(_saveDataDispatchQueue);
#endif
}

- (GQURLOperation *)initWithURLRequest:(NSURLRequest *)urlRequest
                              progress:(GQHTTPRequestChangeHandler)onProgressBlock
                            completion:(GQHTTPRequestCompletionHandler)onCompletionBlock;

{
    self = [super init];
    self.operationData = [[NSMutableData alloc] init];
    self.operationRequest = urlRequest;
    
    if (onProgressBlock) {
        _operationProgressBlock = [onProgressBlock copy];
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
    return self.state == GQURLStateFinished;
}

- (BOOL)isExecuting
{
    return self.state == GQURLStateExecuting;
}

- (GQURLState)state
{
    @synchronized(self) {
        return _state;
    }
}

- (void)setState:(GQURLState)newState
{
    @synchronized(self) {
        [self willChangeValueForKey:@"state"];
        _state = newState;
        [self didChangeValueForKey:@"state"];
    }
}

- (void)finish
{
    [self.operationSession finishTasksAndInvalidate];
    [self.operationSessionTask cancel];
    self.operationSession = nil;
    [self.operationConnection cancel];
    self.operationConnection = nil;
    [self decreaseSVHTTPRequestTaskCount];
    
#if TARGET_OS_IPHONE
    if(self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
#endif
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.state = GQURLStateFinished;
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

- (void)main
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self increaseSVHTTPRequestTaskCount];
    });
    
    [self willChangeValueForKey:@"isExecuting"];
    self.state = GQURLStateExecuting;
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
    
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    BOOL inBackgroundAndInOperationQueue = (currentQueue != nil && currentQueue != [NSOperationQueue mainQueue]);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0) {
        self.operationSession =[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
        self.operationSessionTask = [_operationSession dataTaskWithRequest:_operationRequest];
        [self.operationSessionTask resume];
    }else{
        self.operationConnection = [[NSURLConnection alloc] initWithRequest:self.operationRequest delegate:self startImmediately:NO];
        
        NSRunLoop *targetRunLoop = (inBackgroundAndInOperationQueue) ? [NSRunLoop currentRunLoop] : [NSRunLoop mainRunLoop];
        [self.operationConnection scheduleInRunLoop:targetRunLoop forMode:NSDefaultRunLoopMode];
        [self.operationConnection start];
        
        if(inBackgroundAndInOperationQueue) {
            self.operationRunLoop = CFRunLoopGetCurrent();
            BOOL isWaiting = CFRunLoopIsWaiting(self.operationRunLoop);
            isWaiting?CFRunLoopWakeUp(self.operationRunLoop):CFRunLoopRun();
        }
    }
}

#pragma mark - NSURLConnectionDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response
{
    NSURLRequest *redirectionRequest = request;
    
    return redirectionRequest;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    self.expectedContentLength = response.expectedContentLength;
    self.receivedContentLength = 0;
    self.operationURLResponse = (NSHTTPURLResponse *)response;
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [self handleResponseData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self callCompletionBlockWithResponse:nil requestSuccess:YES error:nil];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self callCompletionBlockWithResponse:nil requestSuccess:NO error:error];
}

- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (challenge.previousFailureCount > 0)
    {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }else{
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

#pragma mark -- NSURLSessionDelegate NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error) {
        [self callCompletionBlockWithResponse:nil requestSuccess:NO error:error];
    }else{
        [self callCompletionBlockWithResponse:nil requestSuccess:YES error:nil];
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    self.expectedContentLength = response.expectedContentLength;
    
    self.receivedContentLength = 0;
    
    self.operationURLResponse = (NSHTTPURLResponse *)response;
    
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    
    if (completionHandler) {
        completionHandler(disposition);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSURLRequest *redirectionRequest = request;
    
    if (completionHandler) {
        completionHandler(redirectionRequest);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    if (challenge.previousFailureCount > 0)
    {
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * bodyStream))completionHandler
{
    NSInputStream *inputStream = nil;
    if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        inputStream = [task.originalRequest.HTTPBodyStream copy];
    }
    if (completionHandler) {
        completionHandler(inputStream);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [self handleResponseData:data];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * cachedResponse))completionHandler
{
    NSCachedURLResponse *cachedResponse = proposedResponse;
    
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
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
    if(self.operationRunLoop){
        CFRunLoopStop(self.operationRunLoop);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.responseData = self.operationData;
        NSError *serverError = error;
        if(!serverError) {
            serverError = [NSError errorWithDomain:NSURLErrorDomain
                                              code:NSURLErrorBadServerResponse
                                          userInfo:nil];
        }
        if(self.operationCompletionBlock && !self.isCancelled){
            self.operationCompletionBlock(self,requestSuccess,requestSuccess?nil:serverError);
        }
        [self finish];
    });
}

@end

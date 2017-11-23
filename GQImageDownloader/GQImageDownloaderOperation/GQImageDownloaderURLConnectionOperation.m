//
//  GQImageDownloaderURLConnectionOperation.m
//  GQNetWorkDemo
//
//  Created by 高旗 on 16/5/27.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageDownloaderURLConnectionOperation.h"

@interface GQImageDownloaderURLConnectionOperation()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@end

@implementation GQImageDownloaderURLConnectionOperation

- (void)dealloc
{
    self.operationConnection = nil;
}

- (instancetype)initWithURLRequest:(NSURLRequest *)urlRequest
                          progress:(GQImageDownloaderChangeHandler)onProgressBlock
                            cancel:(GQImageDownloaderCancelHandler)onCancelBlock
                        completion:(GQImageDownloaderCompletionHandler)onCompletionBlock
{
    self = [super initWithURLRequest:urlRequest
                            progress:onProgressBlock
                              cancel:onCancelBlock
                          completion:onCompletionBlock];
    return self;
}

- (void)finish
{
    [super finish];
    [self.operationConnection cancel];
    self.operationConnection = nil;
}

- (void)main
{
    [super main];
    NSOperationQueue *currentQueue = [NSOperationQueue currentQueue];
    BOOL inBackgroundAndInOperationQueue = (currentQueue != nil && currentQueue != [NSOperationQueue mainQueue]);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
    self.operationConnection = [[NSURLConnection alloc] initWithRequest:self.operationRequest delegate:self startImmediately:NO];
#pragma clang diagnostic pop
    NSRunLoop *targetRunLoop = (inBackgroundAndInOperationQueue) ? [NSRunLoop currentRunLoop] : [NSRunLoop mainRunLoop];
    [self.operationConnection scheduleInRunLoop:targetRunLoop forMode:NSDefaultRunLoopMode];
    [self.operationConnection start];
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

@end

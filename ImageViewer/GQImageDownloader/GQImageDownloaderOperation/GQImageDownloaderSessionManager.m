//
//  GQImageDownloaderSessionManager.m
//  GQImageDownloaderDemo
//
//  Created by 高旗 on 2017/11/24.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import "GQImageDownloaderSessionManager.h"

#import "GQImageDownloaderSessionOperation.h"

@interface GQImageDownloaderSessionManager()

@property (nonatomic, weak) NSOperationQueue *operationQueue;

@end

@implementation GQImageDownloaderSessionManager

#pragma amrk -- life cycle

- (instancetype) initWithOperationQueue:(NSOperationQueue *)operationQueue {
    self = [super init];
    if (self) {
        self.operationQueue = operationQueue;
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                     delegate:self
                                                delegateQueue:nil];
    }
    return self;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
}

#pragma mark Helper methods

- (GQImageDownloaderSessionOperation *)operationWithTask:(NSURLSessionTask *)task {
    GQImageDownloaderSessionOperation *returnOperation = nil;
    for (GQImageDownloaderSessionOperation *operation in self.operationQueue.operations) {
        if (operation.operationSessionTask.taskIdentifier == task.taskIdentifier) {
            returnOperation = operation;
            break;
        }
    }
    return returnOperation;
}

#pragma mark -- NSURLSessionDelegate  NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler {
    
    GQImageDownloaderSessionOperation *dataOperation = [self operationWithTask:task];
    
    [dataOperation URLSession:session task:task willPerformHTTPRedirection:response newRequest:request completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    GQImageDownloaderSessionOperation *dataOperation = [self operationWithTask:dataTask];
    
    [dataOperation URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream * bodyStream))completionHandler {
    GQImageDownloaderSessionOperation *dataOperation = [self operationWithTask:task];
    
    [dataOperation URLSession:session task:task needNewBodyStream:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    
    GQImageDownloaderSessionOperation *dataOperation = [self operationWithTask:dataTask];
    
    [dataOperation URLSession:session dataTask:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler {
    
    GQImageDownloaderSessionOperation *dataOperation = [self operationWithTask:dataTask];
    
    [dataOperation URLSession:session dataTask:dataTask willCacheResponse:proposedResponse completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    
    GQImageDownloaderSessionOperation *dataOperation = [self operationWithTask:task];
    
    [dataOperation URLSession:session task:task didReceiveChallenge:challenge completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    GQImageDownloaderSessionOperation *dataOperation = [self operationWithTask:task];
    
    [dataOperation URLSession:session task:task didCompleteWithError:error];
}

@end

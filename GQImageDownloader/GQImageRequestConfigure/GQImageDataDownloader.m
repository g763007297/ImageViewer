//
//  GQImageDataDownloader.m
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import "GQImageDataDownloader.h"
#import "GQImageDownloaderConst.h"
#import "GQImageDownloaderURLConnectionOperation.h"
#import "GQImageDownloaderSessionOperation.h"
#import "GQImageDownloaderBaseURLRequest.h"

#import "NSData+GQImageDownloader.h"

#import "GQImageDownloaderSessionOperation.h"

#import "GQImageDownloaderSessionManager.h"

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

@interface GQImageDataDownloader() {
    NSDate *_lastSuspendedTime;
}

@property (nonatomic,strong) NSOperationQueue *connectionQueue;

@property (nonatomic, strong) GQImageDownloaderSessionManager *sessionManager NS_AVAILABLE_IOS(8.0);

@property (nonatomic, strong) NSMutableDictionary *callBackDic;
@property (GQDispatchQueueSetterSementics, nonatomic) dispatch_queue_t barrierQueue;
@property (assign, nonatomic) Class requstClass;

@end

@implementation GQImageDataDownloader

GQOBJECT_SINGLETON_BOILERPLATE(GQImageDataDownloader, sharedDownloadManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _connectionQueue  = [[NSOperationQueue alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(checkRequestQueueStatus) userInfo:nil repeats:YES];
        _barrierQueue = dispatch_queue_create("com.hackemist.GQWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _requstClass = [GQImageDownloaderBaseURLRequest class];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            _sessionManager = [[GQImageDownloaderSessionManager alloc] initWithOperationQueue:_connectionQueue];
#pragma clang diagnostic pop
        }
        
    }
    return self;
}

- (void)dealloc {
    [_connectionQueue cancelAllOperations];
    _connectionQueue = nil;
    _sessionManager = nil;
    _callBackDic = nil;
}

// make sure queue will not suspended for too long
- (void)checkRequestQueueStatus
{
    if(!_lastSuspendedTime || [_connectionQueue operationCount] == 0 ){
        return;
    }
    if ([[NSDate date] timeIntervalSinceDate:_lastSuspendedTime] > 5.0) {
        [self restoreLoading];
    }
}

- (id<GQImageDownloaderOperationDelegate>)startRequestWithUrl:(NSURL *)url
{
    __block UIImage *image = nil;
    GQWeakify(self);
    id<GQImageDownloaderOperationDelegate> operation;
    GQImageDownloaderBaseURLRequest *request = [[_requstClass alloc] initWithURL:url];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        operation = [[GQImageDownloaderSessionOperation alloc]
                     initWithURLRequest:request
                     operationSession:self.sessionManager.session
                     progress:^(float progress) {
                         __block NSArray *callbacksForURL;
                         dispatch_barrier_sync(weak_self.barrierQueue, ^{
                             callbacksForURL = weak_self.callBackDic[url];
                         });
                         for (NSDictionary *callbacks in callbacksForURL) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 GQImageDownloaderProgressBlock callback = callbacks[kProgressCallbackKey];
                                 if (callback) callback(progress);
                             });
                         }
                     }cancel:^{
                         [weak_self.callBackDic removeObjectForKey:url];
                     }completion:^(GQImageDownloaderBaseOperation *urlOperation, BOOL requestSuccess, NSError *error) {
                         NSData *data = urlOperation.operationData;
                         image = [data gqImageWithData];
                         __block NSArray *callbacksForURL;
                         dispatch_barrier_sync(weak_self.barrierQueue, ^{
                             callbacksForURL = weak_self.callBackDic[url];
                         });
                         for (NSDictionary *callbacks in callbacksForURL) {
                             GQImageDownloaderCompleteBlock callback = callbacks[kCompletedCallbackKey];
                             if (callback) callback(image,url,error);
                         }
                         [weak_self.callBackDic removeObjectForKey:url];
                     }];
#pragma clang diagnostic pop
    }else {
        operation = [[GQImageDownloaderURLConnectionOperation alloc]
                     initWithURLRequest:request
                     progress:^(float progress) {
                         __block NSArray *callbacksForURL;
                         dispatch_barrier_sync(weak_self.barrierQueue, ^{
                             callbacksForURL = weak_self.callBackDic[url];
                         });
                         for (NSDictionary *callbacks in callbacksForURL) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 GQImageDownloaderProgressBlock callback = callbacks[kProgressCallbackKey];
                                 if (callback) callback(progress);
                             });
                         }
                     }cancel:^{
                         [weak_self.callBackDic removeObjectForKey:url];
                     }completion:^(GQImageDownloaderBaseOperation *urlOperation, BOOL requestSuccess, NSError *error) {
                         NSData *data = urlOperation.operationData;
                         image = [data gqImageWithData];
                         __block NSArray *callbacksForURL;
                         dispatch_barrier_sync(weak_self.barrierQueue, ^{
                             callbacksForURL = weak_self.callBackDic[url];
                         });
                         for (NSDictionary *callbacks in callbacksForURL) {
                             GQImageDownloaderCompleteBlock callback = callbacks[kCompletedCallbackKey];
                             if (callback) callback(image,url,error);
                         }
                         [weak_self.callBackDic removeObjectForKey:url];
                     }];
    }
    
    [self.connectionQueue addOperation:operation];
    return operation;
}

- (void)addBlockToCallBackDicUrl:(NSURL *)url
                        progress:(GQImageDownloaderProgressBlock )progressBlock
                        complete:(GQImageDownloaderCompleteBlock)completeBlock
                       finishAdd:(GQImageDownloaderNoParamsBlock)callBackBlock {
    if (!url) {
        if (completeBlock) {
            completeBlock(nil,nil,nil);
        }
        return;
    }
    dispatch_barrier_sync(self.barrierQueue, ^{
        BOOL first = NO;
        if (!self.callBackDic[url]) {
            self.callBackDic[url] = [NSMutableArray new];
            first = YES;
        }
        
        NSMutableArray *callbacksForURL = self.callBackDic[url];
        NSMutableDictionary *callbacks = [NSMutableDictionary new];
        if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
        if (completeBlock) callbacks[kCompletedCallbackKey] = [completeBlock copy];
        [callbacksForURL addObject:callbacks];
        self.callBackDic[url] = callbacksForURL;
        
        if (first) {
            callBackBlock();
        }
    });
}

#pragma mark -- publicMethod

- (id<GQImageDownloaderOperationDelegate>)downloadWithURL:(NSURL *)url
                                                 progress:(GQImageDownloaderProgressBlock)progress
                                                 complete:(GQImageDownloaderCompleteBlock)complete
{
    GQWeakify(self);
    __block GQImageDownloaderBaseOperation *operation;
    [self addBlockToCallBackDicUrl:(NSURL *)url progress:progress complete:complete finishAdd:^{
        operation = [weak_self startRequestWithUrl:url];
    }];
    return operation;
}

- (void)cancelAllOpration
{
    [_connectionQueue cancelAllOperations];
    _callBackDic = nil;
}

- (void)suspendLoading
{
    if ([_connectionQueue isSuspended]) {
        return;
    }
    [_connectionQueue setSuspended:YES];
    _lastSuspendedTime = nil;
    _lastSuspendedTime = [NSDate date];
}

- (void)restoreLoading
{
    [_connectionQueue setSuspended:NO];
    _lastSuspendedTime = nil;
}

- (void)setURLRequestClass:(Class)requestClass {
    _requstClass = (requestClass && [requestClass isSubclassOfClass:[GQImageDownloaderBaseURLRequest class]]) ? requestClass: [GQImageDownloaderBaseURLRequest class];
}

#pragma mark -- lazy load

- (NSMutableDictionary *)callBackDic {
    if (!_callBackDic) {
        _callBackDic = [[NSMutableDictionary alloc] init];
    }
    return _callBackDic;
}

@end

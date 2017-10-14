//
//  GQImageDataOperation.m
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageDataDownload.h"
#import "GQImageViewerConst.h"
#import "GQImageCacheManager.h"
#import "GQImageRequestOperation.h"
#import "NSData+GQImageViewrCategory.h"
#import "GQImageViewrBaseURLRequest.h"

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

@interface GQImageDataDownload(){
    NSDate *_lastSuspendedTime;
}

@property (nonatomic,strong) NSOperationQueue *connectionQueue;

@property (nonatomic, strong) NSMutableDictionary *callBackDic;
@property (GQDispatchQueueSetterSementics, nonatomic) dispatch_queue_t barrierQueue;
@property (assign, nonatomic) Class requstClass;

@end

@implementation GQImageDataDownload

GQOBJECT_SINGLETON_BOILERPLATE(GQImageDataDownload, sharedDownloadManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        _connectionQueue  = [[NSOperationQueue alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(checkRequestQueueStatus) userInfo:nil repeats:YES];
        _barrierQueue = dispatch_queue_create("com.hackemist.GQWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _requstClass = [GQImageViewrBaseURLRequest class];
    }
    return self;
}

- (void)dealloc {
    [_connectionQueue cancelAllOperations];
    _connectionQueue = nil;
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

- (id<GQImageViwerOperationDelegate>)startRequestWithUrl:(NSURL *)url
{
    __block UIImage *image = nil;
    GQWeakify(self);
    GQImageViewrBaseURLRequest *request = [[_requstClass alloc] initWithURL:url];
    id<GQImageViwerOperationDelegate> operation = [[GQImageRequestOperation alloc]
                                          initWithURLRequest:request
                                          progress:^(float progress) {
                                              __block NSArray *callbacksForURL;
                                              dispatch_barrier_sync(weak_self.barrierQueue, ^{
                                                  callbacksForURL = weak_self.callBackDic[url];
                                              });
                                              for (NSDictionary *callbacks in callbacksForURL) {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      GQImageViwerProgressBlock callback = callbacks[kProgressCallbackKey];
                                                      if (callback) callback(progress);
                                                  });
                                              }
                                          }cancel:^{
                                              [weak_self.callBackDic removeObjectForKey:url];
                                          }completion:^(GQImageRequestOperation *urlOperation, BOOL requestSuccess, NSError *error) {
                                              NSData *data = urlOperation.operationData;
                                              image = [data gqImageWithData];
                                              __block NSArray *callbacksForURL;
                                              dispatch_barrier_sync(weak_self.barrierQueue, ^{
                                                  callbacksForURL = weak_self.callBackDic[url];
                                              });
                                              for (NSDictionary *callbacks in callbacksForURL) {
                                                  GQImageViwerCompleteBlock callback = callbacks[kCompletedCallbackKey];
                                                  if (callback) callback(url,image,error);
                                              }
                                              [weak_self.callBackDic removeObjectForKey:url];
                                          }];
    [self.connectionQueue addOperation:operation];
    return operation;
}

- (void)addBlockToCallBackDicUrl:(NSURL *)url progress:(GQImageViwerProgressBlock )progressBlock complete:(GQImageViwerCompleteBlock)completeBlock finishAdd:(GQImageViwerNoParamsBlock)callBackBlock {
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

- (id<GQImageViwerOperationDelegate>)downloadWithURL:(NSURL *)url progress:(GQImageViwerProgressBlock)progress complete:(GQImageViwerCompleteBlock)complete
{
    GQWeakify(self);
    __block GQImageRequestOperation *operation;
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
    _requstClass = (requestClass && [requestClass isSubclassOfClass:[GQImageViewrBaseURLRequest class]]) ? requestClass: [GQImageViewrBaseURLRequest class];
}

#pragma mark -- lazy load

- (NSMutableDictionary *)callBackDic {
    if (!_callBackDic) {
        _callBackDic = [[NSMutableDictionary alloc] init];
    }
    return _callBackDic;
}

@end

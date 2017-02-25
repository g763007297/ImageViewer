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
//#import "GQImageHttpRequestManager.h"
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

- (void)startRequest
{
    __block UIImage *image = nil;
    if(![[GQImageCacheManager sharedManager] isImageInMemoryCacheWithUrl:_imageUrl.absoluteString]){
        GQWeakify(self);
        GQImageViewrBaseURLRequest *request = [[_requstClass alloc] initWithURL:_imageUrl];
        GQImageRequestOperation *operation = [[GQImageRequestOperation alloc]
                                              initWithURLRequest:request
                                              progress:^(float progress) {
                                                  __block NSArray *callbacksForURL;
                                                  dispatch_barrier_sync(weak_self.barrierQueue, ^{
                                                      callbacksForURL = weak_self.callBackDic[weak_self.imageUrl];
                                                  });
                                                  for (NSDictionary *callbacks in callbacksForURL) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          GQImageViwerProgressBlock callback = callbacks[kProgressCallbackKey];
                                                          if (callback) callback(progress);
                                                      });
                                                  }
                                              } completion:^(GQImageRequestOperation *urlOperation, BOOL requestSuccess, NSError *error) {
                                                  NSData *data = urlOperation.operationData;
                                                  image = [data gqImageWithData];
                                                  if (image) {
                                                      [[GQImageCacheManager sharedManager] saveImage:image withUrl:_imageUrl.absoluteString];
                                                  }
                                                  __block NSArray *callbacksForURL;
                                                  dispatch_barrier_sync(weak_self.barrierQueue, ^{
                                                      callbacksForURL = weak_self.callBackDic[weak_self.imageUrl];
                                                  });
                                                  for (NSDictionary *callbacks in callbacksForURL) {
                                                      GQImageViwerCompleteBlock callback = callbacks[kCompletedCallbackKey];
                                                      if (callback) callback(weak_self.imageUrl,image,error);
                                                  }
                                                  [weak_self.callBackDic removeObjectForKey:weak_self.imageUrl];
                                              }];
        [self.connectionQueue addOperation:operation];
    }else{
        image = [[GQImageCacheManager sharedManager] getImageFromCacheWithUrl:_imageUrl.absoluteString];
        NSArray *callbacksForURL = self.callBackDic[self.imageUrl];
        for (NSDictionary *callbacks in callbacksForURL) {
            GQImageViwerCompleteBlock callback = callbacks[kCompletedCallbackKey];
            if (callback) callback(self.imageUrl,image,nil);
        }
        [self.callBackDic removeObjectForKey:self.imageUrl];
    }
}

- (void)addBlockToCallBackDicProgress:(GQImageViwerProgressBlock )progressBlock complete:(GQImageViwerCompleteBlock)completeBlock finishAdd:(GQImageViwerNoParamsBlock)callBackBlock {
    if (!self.imageUrl) {
        if (completeBlock) {
            completeBlock(nil,nil,nil);
        }
        return;
    }
    dispatch_barrier_sync(self.barrierQueue, ^{
        BOOL first = NO;
        if (!self.callBackDic[self.imageUrl]) {
            self.callBackDic[self.imageUrl] = [NSMutableArray new];
            first = YES;
        }
        
        NSMutableArray *callbacksForURL = self.callBackDic[self.imageUrl];
        NSMutableDictionary *callbacks = [NSMutableDictionary new];
        if (progressBlock) callbacks[kProgressCallbackKey] = [progressBlock copy];
        if (completeBlock) callbacks[kCompletedCallbackKey] = [completeBlock copy];
        [callbacksForURL addObject:callbacks];
        self.callBackDic[self.imageUrl] = callbacksForURL;
        
        if (first) {
            callBackBlock();
        }
    });
}

#pragma mark -- publicMethod

- (instancetype)initWithURL:(NSURL *)url progress:(GQImageViwerProgressBlock)progress complete:(GQImageViwerCompleteBlock)complete
{
    self = [super init];
    if (self) {
        _imageUrl = url;
        GQWeakify(self);
        [self addBlockToCallBackDicProgress:progress complete:complete finishAdd:^{
            [weak_self startRequest];
        }];
    }
    return self;
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
    _requstClass = requestClass ?: [GQImageViewrBaseURLRequest class];
}

#pragma mark -- lazy load

- (NSMutableDictionary *)callBackDic {
    if (!_callBackDic) {
        _callBackDic = [[NSMutableDictionary alloc] init];
    }
    return _callBackDic;
}

@end

//
//  GQHttpRequestManager.m
//  GQNetWorkDemo
//
//  Created by 高旗 on 16/5/27.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQHttpRequestManager.h"
#import "GQImageViewerConst.h"

@interface GQHttpRequestManager()
{
    NSDate *_lastSuspendedTime;
}

@property (nonatomic,strong) NSOperationQueue *connectionQueue;

@end

@implementation GQHttpRequestManager

GQOBJECT_SINGLETON_BOILERPLATE(GQHttpRequestManager, sharedHttpRequestManager)

- (id)init
{
    self = [super init];
    if (self) {
        _connectionQueue  = [[NSOperationQueue alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(checkRequestQueueStatus) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)addOperation:(NSOperation *)operation{
    [self.connectionQueue addOperation:operation];
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

@end

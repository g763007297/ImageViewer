//
//  GQSessionOperation.h
//  GQNetWorkDemo
//
//  Created by 高旗 on 16/10/23.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageDownloaderBaseOperation.h"

NS_CLASS_AVAILABLE(NSURLSESSION_AVAILABLE, 8_0)
@interface GQImageDownloaderSessionOperation : GQImageDownloaderBaseOperation<NSURLSessionTaskDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask  *operationSessionTask;

@end

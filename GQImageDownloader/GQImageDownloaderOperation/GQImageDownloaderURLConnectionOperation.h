//
//  GQImageDownloaderURLConnectionOperation.h
//  GQNetWorkDemo
//
//  Created by 高旗 on 16/5/27.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageDownloaderBaseOperation.h"

@interface GQImageDownloaderURLConnectionOperation : GQImageDownloaderBaseOperation

@property (nonatomic, strong) NSURLConnection *operationConnection;

@end

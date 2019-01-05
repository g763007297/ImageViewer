//
//  GQImageDownloaderBaseURLRequest.h
//  ImageViewer
//
//  Created by 高旗 on 16/12/26.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GQImageDownloaderBaseURLRequest : NSMutableURLRequest

/**
 进行参数相关的配置
 */
- (void)configureRequestData;

/**
 User-Agent

 @return User-Agent
 */
- (NSString *)userAgentString;

/**
 Cookie

 @return Cookie
 */
- (NSString *)storageCookies;

/**
 请求接收类型

 @return 接收类型
 */
- (NSString *)acceptType;

@end

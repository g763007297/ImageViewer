//
//  GQBaseURLRequest.h
//  ImageViewer
//
//  Created by 高旗 on 16/12/26.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GQImageViewrBaseURLRequest : NSMutableURLRequest

/**
 进行参数相关的配置
 */
- (void)configureRequestData;

- (NSString *)userAgentString;

- (NSString *)storageCookies;

@end

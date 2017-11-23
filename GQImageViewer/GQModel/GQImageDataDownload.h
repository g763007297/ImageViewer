//
//  GQImageDataDownload.h
//  ImageViewer
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GQImageDataDownload : NSObject

+ (instancetype)sharedDownloadManager;

/**
 设置图片处理请求class
 
 param requestClass
 */
- (void)setURLRequestClass:(Class)requestClass;

@end

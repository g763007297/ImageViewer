//
//  GQImageDataOperation.h
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^completeBlock)(NSURL *url, UIImage* image, NSError *error);
typedef void(^progressBlock)(CGFloat progress);

@interface GQImageDataDownload : NSObject

@property (nonatomic, strong) NSURL *imageUrl;

- (void)cancel;

- (id)initWithURL:(NSURL *)url progress:(progressBlock)progress complete:(completeBlock)complete;

@end

//
//  UIImage+GQImageDownloader.m
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import "UIImage+GQImageDownloader.h"
#import "NSData+GQImageDownloader.h"

@implementation UIImage (GQImageDownloader)

#ifdef GQ_WEBP

+ (UIImage *)gq_imageWithWebPImageName:(NSString *)imageName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"webp"];
    return [self gq_imageWithWebPFile:filePath];
}

+ (UIImage*)gq_imageWithWebPFile:(NSString*)filePath {
    if (!filePath||![filePath length] ) {
        return nil;
    }
    NSData *imgData = [NSData dataWithContentsOfFile:filePath];
    return [NSData gq_imageWithWebPData:imgData];
}

#endif

@end

//
//  NSData+GQCategory.h
//  ImageViewer
//
//  Created by 高旗 on 16/9/9.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSData (GQCategory)

- (UIImage *)imageWithData;

- (NSString *)typeForImageData;

- (BOOL)isGIF;

@end

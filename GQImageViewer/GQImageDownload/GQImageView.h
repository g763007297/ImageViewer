//
//  GQImageView.h
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GQImageCompletionBlock)(UIImage *image, NSError *error, NSURL *imageUrl);

@interface GQImageView : UIImageView

@property (nonatomic,strong) NSURL *imageUrl;

- (void)loadImage:(NSURL*)url complete:(GQImageCompletionBlock)complete;
- (void)loadImage:(NSURL*)url placeHolder:(UIImage *)placeHolderImage complete:(GQImageCompletionBlock)complete;
- (void)cancelCurrentImageRequest;     //caller must call this method in its dealloc method

@end

//
//  NSAttributedString+GQImageViewerCategory.h
//  ImageViewer
//
//  Created by 高旗 on 2018/1/6.
//  Copyright © 2018年 tusm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (GQImageViewerCategory)

- (CGSize)attributedStringSizeWithSize:(CGSize)originSize withDefaultFont:(UIFont *)defaultFont;

@end

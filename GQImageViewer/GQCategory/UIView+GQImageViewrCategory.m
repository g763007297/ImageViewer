//
//  UIView+GQImageViewrCategory.m
//  ImageViewer
//
//  Created by 高旗 on 16/12/1.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "UIView+GQImageViewrCategory.h"

@implementation UIView (GQImageViewrCategory)

#pragma mark - origin 坐标点
- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame   = self.frame;
    frame.origin   = origin;
    self.frame     = frame;
}

#pragma mark - size 大小
- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame   = self.frame;
    frame.size     = size;
    self.frame     = frame;
}

#pragma mark - width 宽度
- (CGFloat)width
{
    return self.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGSize size    = self.size;
    size.width     = width;
    self.size      = size;
}

#pragma mark - height 高度
- (CGFloat)height
{
    return self.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGSize size    = self.size;
    size.height    = height;
    self.size      = size;
}

#pragma mark - x 横坐标
- (CGFloat)x
{
    return self.origin.x;
}

- (void)setX:(CGFloat)x
{
    CGPoint origin = self.origin;
    origin.x       = x;
    self.origin    = origin;
}

#pragma mark - y 纵坐标
- (CGFloat)y
{
    return self.origin.y;
}

- (void)setY:(CGFloat)y
{
    CGPoint origin = self.origin;
    origin.y       = y;
    self.origin    = origin;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}


@end

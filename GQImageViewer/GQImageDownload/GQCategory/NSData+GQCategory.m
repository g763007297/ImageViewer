//
//  NSData+GQCategory.m
//  ImageViewer
//
//  Created by 高旗 on 16/9/9.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "NSData+GQCategory.h"
#import <ImageIO/ImageIO.h>

@implementation NSData (GQCategory)

- (UIImage *)gqImageWithData
{
    UIImage *image;
    NSString *imageContentType = [self gqTypeForImageData];
    if ([imageContentType isEqualToString:@"image/gif"])
    {
        image = [self animatedGIFWithData];
    }
    else {
        image = [[UIImage alloc] initWithData:self];
        UIImageOrientation orientation = [self imageOrientationFromImageData];
        if (orientation != UIImageOrientationUp) {
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:image.scale
                                  orientation:orientation];
        }
    }
    return image;
}

- (UIImage *)animatedGIFWithData
{
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)self, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:self];
    }else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            duration += [self frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

- (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source
{
    
    float frameDuration = 0.1f;
    
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if (delayTimeUnclampedProp) {
        
        frameDuration = [delayTimeUnclampedProp floatValue];
    }else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        
        if (delayTimeProp) {
            
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

- (UIImageOrientation)imageOrientationFromImageData
{
    
    UIImageOrientation result = UIImageOrientationUp;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(NSData *)self, NULL);
    
    if (imageSource) {
        
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
        
        if (properties) {
            CFTypeRef val;
            
            int exifOrientation;
            
            val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
            
            if (val) {
                CFNumberGetValue(val, kCFNumberIntType, &exifOrientation);
                
                result = [self exifOrientationToiOSOrientation:exifOrientation];
            }
            CFRelease((CFTypeRef) properties);
        }
        CFRelease(imageSource);
    }
    return result;
}

- (UIImageOrientation)exifOrientationToiOSOrientation:(int)exifOrientation
{
    UIImageOrientation orientation = UIImageOrientationUp;
    switch (exifOrientation) {
        case 1:
            orientation = UIImageOrientationUp;
            break;
            
        case 2:
            orientation = UIImageOrientationUpMirrored;
            break;
            
        case 3:
            orientation = UIImageOrientationDown;
            break;
            
        case 4:
            orientation = UIImageOrientationDownMirrored;
            break;
            
        case 5:
            orientation = UIImageOrientationLeftMirrored;
            break;
            
        case 6:
            orientation = UIImageOrientationRight;
            break;
            
        case 7:
            orientation = UIImageOrientationRightMirrored;
            break;
            
        case 8:
            orientation = UIImageOrientationLeft;
            break;
            
        default:
            break;
    }
    return orientation;
}

- (NSString *)gqTypeForImageData
{
    uint8_t c;
    [self getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([self length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[self subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
}

@end

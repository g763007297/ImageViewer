//
//  NSData+GQImageDownloader.m
//  GQImageDownload
//
//  Created by 高旗 on 2017/11/23.
//  Copyright © 2017年 gaoqi. All rights reserved.
//

#import "NSData+GQImageDownloader.h"
#import <ImageIO/ImageIO.h>

#ifdef GQ_WEBP
#import "UIImage+GQImageDownloader.h"
#endif

#ifdef GQ_WEBP

#import <WebP/decode.h>
#import <WebP/mux_types.h>
#import <WebP/demux.h>

static void FreeImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

#endif

@implementation NSData (GQImageDownloader)

- (UIImage *)gqImageWithData
{
    UIImage *image;
    NSString *imageContentType = [self gqTypeForImageData];
    if ([imageContentType isEqualToString:@"image/gif"])
    {
        image = [self animatedGIFWithData];
    }
#ifdef GQ_WEBP
    else if ([imageContentType isEqualToString:@"image/webp"]) {
        image = [NSData gq_imageWithWebPData:self];
    }
#endif
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

#ifdef GQ_WEBP

+ (UIImage *)gq_imageWithWebPData:(NSData *)imgData {
    if (!imgData) {
        return nil;
    }
    
    WebPData webpData;
    WebPDataInit(&webpData);
    webpData.bytes = imgData.bytes;
    webpData.size = imgData.length;
    WebPDemuxer *demuxer = WebPDemux(&webpData);
    if (!demuxer) {
        return nil;
    }
    
    uint32_t flags = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS);
    if (!(flags & ANIMATION_FLAG)) {
        // for static single webp image
        UIImage *staticImage = [self gq_rawWepImageWithData:webpData];
        WebPDemuxDelete(demuxer);
        return staticImage;
    }
    
    WebPIterator iter;
    if (!WebPDemuxGetFrame(demuxer, 1, &iter)) {
        WebPDemuxReleaseIterator(&iter);
        WebPDemuxDelete(demuxer);
        return nil;
    }
    
    NSMutableArray *images = [NSMutableArray array];
    NSTimeInterval duration = 0;
    
    do {
        UIImage *image;
        if (iter.blend_method == WEBP_MUX_BLEND) {
            image = [self gq_blendWebpImageWithOriginImage:[images lastObject] iterator:iter];
        } else {
            image = [self gq_rawWepImageWithData:iter.fragment];
        }
        
        if (!image) {
            continue;
        }
        
        [images addObject:image];
        duration += iter.duration / 1000.0f;
        
    } while (WebPDemuxNextFrame(&iter));
    
    WebPDemuxReleaseIterator(&iter);
    WebPDemuxDelete(demuxer);
    
    UIImage *finalImage = nil;
    
    finalImage = [UIImage animatedImageWithImages:images duration:duration];
    
    return finalImage;
}

+ (nullable UIImage *)gq_blendWebpImageWithOriginImage:(nullable UIImage *)originImage iterator:(WebPIterator)iter {
    if (!originImage) {
        return nil;
    }
    
    CGSize size = originImage.size;
    CGFloat tmpX = iter.x_offset;
    CGFloat tmpY = size.height - iter.height - iter.y_offset;
    CGRect imageRect = CGRectMake(tmpX, tmpY, iter.width, iter.height);
    
    UIImage *image = [self gq_rawWepImageWithData:iter.fragment];
    if (!image) {
        return nil;
    }
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    uint32_t bitmapInfo = iter.has_alpha ? kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast : 0;
    CGContextRef blendCanvas = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpaceRef, bitmapInfo);
    CGContextDrawImage(blendCanvas, CGRectMake(0, 0, size.width, size.height), originImage.CGImage);
    CGContextDrawImage(blendCanvas, imageRect, image.CGImage);
    CGImageRef newImageRef = CGBitmapContextCreateImage(blendCanvas);
    
    image = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    CGContextRelease(blendCanvas);
    CGColorSpaceRelease(colorSpaceRef);
    
    return image;
}

+ (nullable UIImage *)gq_rawWepImageWithData:(WebPData)webpData {
    WebPDecoderConfig config;
    if (!WebPInitDecoderConfig(&config)) {
        return nil;
    }
    
    if (WebPGetFeatures(webpData.bytes, webpData.size, &config.input) != VP8_STATUS_OK) {
        return nil;
    }
    
    config.output.colorspace = config.input.has_alpha ? MODE_rgbA : MODE_RGB;
    config.options.use_threads = 1;
    
    // Decode the WebP image data into a RGBA value array.
    if (WebPDecode(webpData.bytes, webpData.size, &config) != VP8_STATUS_OK) {
        return nil;
    }
    
    int width = config.input.width;
    int height = config.input.height;
    if (config.options.use_scaling) {
        width = config.options.scaled_width;
        height = config.options.scaled_height;
    }
    
    // Construct a UIImage from the decoded RGBA value array.
    CGDataProviderRef provider =
    CGDataProviderCreateWithData(NULL, config.output.u.RGBA.rgba, config.output.u.RGBA.size, FreeImageData);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = config.input.has_alpha ? kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast : 0;
    size_t components = config.input.has_alpha ? 4 : 3;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, 8, components * 8, components * width, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

#endif

@end

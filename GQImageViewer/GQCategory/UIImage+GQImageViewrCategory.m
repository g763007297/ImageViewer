//
//  UIImage+GQImageViewrCategory.m
//  ImageViewer
//
//  Created by 高旗 on 17/1/19.
//  Copyright © 2017年 tusm. All rights reserved.
//

#import "UIImage+GQImageViewrCategory.h"

#ifdef GQ_WEBP

#import <WebP/decode.h>
#import <WebP/mux_types.h>
#import <WebP/demux.h>

static void FreeImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

#endif

@implementation UIImage (GQImageViewrCategory)

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
    return [self gq_imageWithWebPData:imgData];
}

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

- (CGRect)gq_imageSizeWidthCompareWithSize:(CGSize)size {
    CGSize originSize = size;
    CGSize imageSize = self.size;
    
    CGFloat WScale = imageSize.width / originSize.width;
    
    CGFloat scale = WScale;
    
    CGFloat height = imageSize.height / scale;
    CGFloat width = imageSize.width / scale;
    
    CGRect confirmRect = CGRectMake((size.width - width) / 2,
                                    (size.height > height)?(size.height - height) / 2:0,
                                    width,
                                    height);
    return confirmRect;
}

- (CGRect)gq_imageSizeHeightCompareWithSize:(CGSize)size {
    CGSize originSize = size;
    CGSize imageSize = self.size;
    
    CGFloat HScale = imageSize.height / originSize.height;
    
    CGFloat scale = HScale;
    
    CGFloat height = imageSize.height / scale;
    CGFloat width = imageSize.width / scale;
    
    CGRect confirmRect = CGRectMake( ((size.width > width)?(size.width - width) / 2:0),
                                    (size.height - height)/2,
                                    width,
                                    height);
    return confirmRect;
}

- (CGRect)gq_imageSizeFullyDisplayCompareWithSize:(CGSize)size {
    CGSize originSize = size;
    CGSize imageSize = self.size;
    
    CGFloat HScale = imageSize.height / originSize.height;
    CGFloat WScale = imageSize.width / originSize.width;
    
    CGFloat scale = (HScale > WScale) ? HScale : WScale;
    
    CGFloat height = imageSize.height / scale;
    CGFloat width = imageSize.width / scale;
    
    CGRect confirmRect = CGRectMake((size.width - width) / 2,
                                    (size.height - height)/2,
                                    width,
                                    height);
    return confirmRect;
}

@end

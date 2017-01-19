//
//  GQBaseURLRequest.m
//  ImageViewer
//
//  Created by 高旗 on 16/12/26.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQImageViewrBaseURLRequest.h"
#import <UIKit/UIKit.h>

static NSString *defaultUserAgent = nil;

@implementation GQImageViewrBaseURLRequest

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super initWithURL:URL];
    if (self) {
        [self configureRequestData];
    }
    return self;
}

#pragma mark -- private method
- (void)defaultConfigure {
    self.timeoutInterval = 30.0f;
    [self setValue:[self userAgentString] forHTTPHeaderField:@"User-Agent"];
    [self setValue:[self storageCookies] forHTTPHeaderField:@"Cookie"];
    [self setValue:[self acceptType] forHTTPHeaderField:@"Accept"];
    [self configureRequestData];
}

#pragma mark -- public method
- (void)configureRequestData {
    
}

- (NSString *)acceptType {
#ifdef SD_WEBP
    return @"image/webp,image/*;q=0.8"
#else
    return @"image/*;q=0.8";
#endif
}

- (NSString *)userAgentString
{
    @synchronized (self) {
        if (!defaultUserAgent) {
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            
            NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
            if (!appName) {
                appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
            }
            
            NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
            appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding];
            
            if (!appName) {
                return nil;
            }
            
            NSString *appVersion = nil;
            NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
            if (marketingVersionNumber && developmentVersionNumber) {
                if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
                    appVersion = marketingVersionNumber;
                } else {
                    appVersion = [NSString stringWithFormat:@"%@ rv:%@",marketingVersionNumber,developmentVersionNumber];
                }
            } else {
                appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
            }
            
            NSString *deviceName;
            NSString *OSName;
            NSString *OSVersion;
            NSString *locale = [[NSLocale currentLocale] localeIdentifier];
            
    #if TARGET_OS_IPHONE
            UIDevice *device = [UIDevice currentDevice];
            deviceName = [device model];
            OSName = [device systemName];
            OSVersion = [device systemVersion];
            
    #else
            deviceName = @"Macintosh";
            OSName = @"Mac OS X";
            
            OSErr err;
            SInt32 versionMajor, versionMinor, versionBugFix;
            err = Gestalt(gestaltSystemVersionMajor, &versionMajor);
            if (err != noErr) return nil;
            err = Gestalt(gestaltSystemVersionMinor, &versionMinor);
            if (err != noErr) return nil;
            err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
            if (err != noErr) return nil;
            OSVersion = [NSString stringWithFormat:@"%u.%u.%u", versionMajor, versionMinor, versionBugFix];
    #endif
            
            defaultUserAgent = [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", appName, appVersion, deviceName, OSName, OSVersion, locale];
        }
    }
    return defaultUserAgent;
}

- (NSString *)storageCookies
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.URL];
    if ([cookies count] > 0) {
        NSHTTPCookie *cookie;
        NSString *cookieHeader = nil;
        for (cookie in cookies) {
            if (!cookieHeader) {
                cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
            } else {
                cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
            }
        }
        return cookieHeader;
    }
    return nil;
}

@end

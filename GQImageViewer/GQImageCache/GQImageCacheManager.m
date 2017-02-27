//
//  GQImageCacheManager.m
//  GQImageVideoViewer
//
//  Created by 高旗 on 16/9/8.
//  Copyright © 2016年 gaoqi. All rights reserved.
//

#import "GQImageCacheManager.h"
#import "GQGobalPaths.H"

@interface GQImageCacheManager()
{
    NSMutableDictionary *_memoryCache;
    NSFileManager *_fileManager;
}
@property (nonatomic, strong) dispatch_queue_t ioDispatchQueue;

@property (nonatomic, strong) dispatch_group_t ioDispatchGroup;

@end

@implementation GQImageCacheManager

GQOBJECT_SINGLETON_BOILERPLATE(GQImageCacheManager, sharedManager)
#pragma mark - Object lifecycle

- (void)dealloc
{
    _memoryCache = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self restore];
        self.ioDispatchGroup = dispatch_group_create();
        self.ioDispatchQueue = dispatch_queue_create("com.ISS.GQImageCacheManager", DISPATCH_QUEUE_SERIAL);
        _fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)restore
{
    [self registerMemoryWarningNotification];
    _memoryCache = nil;
    _memoryCache = [[NSMutableDictionary alloc] init];
    NSString *path = [self getImageFolder];
    if (![_fileManager fileExistsAtPath:path]) {
        [self createDirectorysAtPath:path];
    }
}

#pragma mark - private methods

- (void)registerMemoryWarningNotification
{
    // Subscribe to app events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMemoryCache)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
#ifdef __IPHONE_4_0
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported)
    {
        // When in background, clean memory in order to have less chance to be killed
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemoryCache)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
#endif
}

- (NSString*)encodeURL:(NSString *)string
{
    NSString *newString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString) {
        return newString;
    }
    return @"";
}

- (BOOL)createDirectorysAtPath:(NSString *)path
{
    @synchronized(self){
        if (![_fileManager fileExistsAtPath:path]) {
            NSError *error = nil;
            if (![_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
                return NO;
            }
        }
    }
    return YES;
}

- (NSString *)getImageFolder
{
    return GQPathForCacheResource(@"images");
}

- (NSString *)getPathByFileName:(NSString *)fileName
{
    return [NSString stringWithFormat:@"%@/%@",[self getImageFolder],fileName];
}

- (NSString*)getKeyFromUrl:(NSString*)url{
    return [self encodeURL:url];
}

- (NSString *)createImageFilePathWithUrl:(NSString *)url
{
    NSString *key = [self getKeyFromUrl:url];
    return [self getPathByFileName:key];
}

- (void)saveToMemory:(UIImage*)image forKey:(NSString*)key
{
    @synchronized (_memoryCache) {
        if (image) {
            _memoryCache[key] = image;
        }
    }
}

- (UIImage*)getImageFromMemoryCache:(NSString*)key
{
    return _memoryCache[key];
}

- (BOOL)isImageInMemoryCacheWithUrl:(NSString*)url
{
    return [self isImageInMemoryCache:[self getKeyFromUrl:url]];
}

- (BOOL)isImageInMemoryCache:(NSString*)key
{
    return (nil != [self getImageFromMemoryCache:key]);
}

#pragma mark - public methods
- (void)saveImage:(UIImage*)image withUrl:(NSString*)url
{
    [self saveImage:image withKey:[self getKeyFromUrl:url]];
}

- (void)saveImage:(UIImage*)image withKey:(NSString*)key
{
    dispatch_group_async(self.ioDispatchGroup, self.ioDispatchQueue, ^{
        @try {
            NSData* imageData = UIImagePNGRepresentation(image);
            NSString *imageFilePath = [self getPathByFileName:key];
            [imageData writeToFile:imageFilePath atomically:YES];
        }@catch (NSException *exception) {
            
        }
    });
    [self saveToMemory:image forKey:key];
}

- (UIImage*)getImageFromCacheWithUrl:(NSString*)url
{
    return [self getImageFromCacheWithKey:[self getKeyFromUrl:url]];
}

- (UIImage*)getImageFromCacheWithKey:(NSString*)key
{
    if ([self isImageInMemoryCache:key]) {
        return [self getImageFromMemoryCache:key];
    }else{
        NSString *imageFilePath = [self getPathByFileName:key];
        UIImage* image = [UIImage imageWithContentsOfFile:imageFilePath];
        if (image) {
            [self saveToMemory:image forKey:key];
        }
        return image;
    }
}

- (void)clearDiskCache
{
    NSString *imageFolderPath = [self getImageFolder];
    [_fileManager removeItemAtPath:imageFolderPath error:nil];
    [self createDirectorysAtPath:imageFolderPath];
}

- (void)clearMemoryCache
{
    _memoryCache = nil;
    _memoryCache = [[NSMutableDictionary alloc] init];
}

- (void)removeImageFromCacheWithUrl:(NSString *)url
{
    [self removeImageFromCacheWithKey:[self getKeyFromUrl:url]];
}

- (void)removeImageFromCacheWithKey:(NSString *)key
{
    if ([self isImageInMemoryCache:key]) {
        [_memoryCache removeObjectForKey:key];
    }
    NSString *imageFilePath = [self getPathByFileName:key];
    if ([_fileManager fileExistsAtPath:imageFilePath]) {
        [_fileManager removeItemAtPath:imageFilePath error:nil];
    }
}

- (NSUInteger)getSize {
    __block NSUInteger size = 0;
    dispatch_sync(self.ioDispatchQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:[self getImageFolder]];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [self.getImageFolder stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

- (NSUInteger)getDiskCount {
    __block NSUInteger count = 0;
    dispatch_sync(self.ioDispatchQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:[self getImageFolder]];
        count = [[fileEnumerator allObjects] count];
    });
    return count;
}

- (void)clearDisk {
    [self clearDiskOnCompletion:nil];
}

- (void)clearDiskOnCompletion:(GGWebImageNoParamsBlock)completion
{
    dispatch_async(self.ioDispatchQueue, ^{
        [_fileManager removeItemAtPath:[self getImageFolder] error:nil];
        [_fileManager createDirectoryAtPath:[self getImageFolder]
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

@end

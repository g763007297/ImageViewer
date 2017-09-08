//
//  GQImageViewerConst.h
//  ImageViewer
//
//  Created by 高旗 on 16/6/23.
//  Copyright © 2016年 tusm. All rights reserved.
//

#ifndef GQImageViewerConst_h
#define GQImageViewerConst_h                                         

#define GQOBJECT_SINGLETON_BOILERPLATE(_object_name_, _shared_obj_name_)    \
static _object_name_ *z##_shared_obj_name_ = nil;                           \
+ (_object_name_ *)_shared_obj_name_ {                                      \
    @synchronized(self) {                                                   \
        if (z##_shared_obj_name_ == nil) {                                  \
            static dispatch_once_t done;                                    \
            dispatch_once(&done, ^{                                         \
            z##_shared_obj_name_ = [[super allocWithZone:nil] init]; });    \
        }                                                                   \
    }                                                                       \
    return z##_shared_obj_name_;                                            \
}                                                                           \
+ (id)allocWithZone:(NSZone *)zone {                                        \
    @synchronized(self) {                                                   \
        if (z##_shared_obj_name_ == nil) {                                  \
            z##_shared_obj_name_ = [super allocWithZone:NULL];              \
            return z##_shared_obj_name_;                                    \
        }                                                                   \
    }                                                                       \
    return nil;                                                             \
}                                                                           \
- (id)copyWithZone:(NSZone*)zone                                            \
{                                                                           \
    return z##_shared_obj_name_;                                            \
}

#define GQChainObjectDefine(_key_name_,_Chain_, _type_ , _block_type_)  \
@synthesize _key_name_ = _##_key_name_;                                 \
- (_block_type_)_key_name_                                              \
{                                                                       \
    __weak typeof(self) weakSelf = self;                                \
    if (!_##_key_name_) {                                               \
        _##_key_name_ = ^(_type_ value){                                \
            __strong typeof(weakSelf) strongSelf = weakSelf;            \
            [strongSelf set##_Chain_:value];                            \
            return strongSelf;                                          \
        };                                                              \
    }                                                                   \
    return _##_key_name_;                                               \
}

#if OS_OBJECT_USE_OBJC
    #undef GQDispatchQueueRelease
    #undef GQDispatchQueueSetterSementics
    #define GQDispatchQueueRelease(q)
    #define GQDispatchQueueSetterSementics strong
#else
    #undef GQDispatchQueueRelease
    #undef GQDispatchQueueSetterSementics
    #define GQDispatchQueueRelease(q) (dispatch_release(q))
    #define GQDispatchQueueSetterSementics assign
#endif

#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
}

//强弱引用
#ifndef GQWeakify
#define GQWeakify(object) __weak __typeof__(object) weak##_##object = object
#endif

#ifndef GQStrongify
#define GQStrongify(object) __typeof__(object) object = weak##_##object
#endif

typedef void(^GGWebImageNoParamsBlock)();

#endif /* GQImageViewerConst_h */

//
//  GQImageViewerConst.h
//  ImageViewer
//
//  Created by 高旗 on 16/6/23.
//  Copyright © 2016年 tusm. All rights reserved.
//

#ifndef GQImageViewerConst_h
#define GQImageViewerConst_h                                         \

#define GQChainObjectDefine(_key_name_,_Chain_, _type_ , _block_type_)\
- (_block_type_)_key_name_\
{\
    __weak typeof(self) weakSelf = self;\
    if (!_##_key_name_) {\
        _##_key_name_ = ^(_type_ value){\
            __strong typeof(weakSelf) strongSelf = weakSelf;\
            [strongSelf set##_Chain_:value];\
            return strongSelf;\
        };\
    }\
    return _##_key_name_;\
}\

//强弱引用
#ifndef GQWeakify
#define GQWeakify(object) __weak __typeof__(object) weak##_##object = object
#endif

#ifndef GQStrongify
#define GQStrongify(object) __typeof__(object) object = weak##_##object
#endif

#endif /* GQImageViewerConst_h */

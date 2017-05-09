//
//  GQImageViewerModel.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/30.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "GQImageViewrBaseObject.h"

@interface GQImageViewerModel : GQImageViewrBaseObject

//图片信息
@property (nonatomic, copy) id imageSource;

/**
 自定义图片浏览界面class名称 必须继承GQImageView
 */
@property (nonatomic, copy) NSString *GQImageViewClassName;

//文字信息
@property (nonatomic, copy) NSString *textSource;

@end

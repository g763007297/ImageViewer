//
//  GQImageViewerMacro.h
//  ImageViewer
//
//  Created by tusm on 2018/11/16.
//  Copyright © 2018年 tusm. All rights reserved.
//

#ifndef GQImageViewerMacro_h
#define GQImageViewerMacro_h

@class GQImageViewrConfigure;
@class GQImageViewer;

typedef void (^GQAchieveIndexBlock)(NSInteger selectIndex);//获取当前图片的index的block
typedef void (^GQLongTapIndexBlock)(UIImage *image ,NSInteger selectIndex);
typedef void (^GQSubViewConfigureBlock)(UIView *configureView);
typedef void (^GQConfigureBlock)(GQImageViewrConfigure *configure);
typedef void (^GQVoidBlock)(void);

//链式调用block
typedef GQImageViewer * (^GQVoidChain)(GQVoidBlock voidBlock);
typedef GQImageViewer * (^GQDataSouceArrayChain)(NSArray *imageArray ,NSArray *textArray);
typedef GQImageViewer * (^GQSelectIndexChain)(NSInteger selectIndex);
typedef GQImageViewer * (^GQConfigureChain) (GQConfigureBlock configure);
typedef GQImageViewer * (^GQSubViewConfigureChain) (GQSubViewConfigureBlock configureBlock);;
typedef GQImageViewer * (^GQAchieveIndexChain)(GQAchieveIndexBlock achieveIndexBlock);
typedef GQImageViewer * (^GQLongTapIndexChain)(GQLongTapIndexBlock longTapIndexBlock);
typedef GQImageViewer * (^GQSingleTapChain)(GQAchieveIndexBlock singleTapBlock);
typedef GQImageViewer * (^GQDeleteCurrentIndexChain)(GQVoidBlock voidBlock);
typedef void (^GQShowViewChain)(UIView *showView, BOOL animation);


#endif /* GQImageViewerMacro_h */

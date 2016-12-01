//
//  GQTextScrollView.h
//  ImageViewer
//
//  Created by 高旗 on 16/11/30.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GQImageViewrConfigure;
@class GQImageViewerModel;

@interface GQTextScrollView : UIScrollView<UIScrollViewDelegate>

- (CGFloat)configureSource:(NSArray <GQImageViewerModel*>*)source
             withConfigure:(GQImageViewrConfigure *)configure
          withCurrentIndex:(NSInteger)currentIndex
            usePageControl:(BOOL)usePageControl;

@property (nonatomic, readonly, strong) NSString *text;
@property (nonatomic, readonly, strong) GQImageViewrConfigure *configure;

@end

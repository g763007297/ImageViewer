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

@interface GQTextScrollView : UIScrollView

- (CGFloat)configureSource:(id)source
             withConfigure:(GQImageViewrConfigure *)configure
          withCurrentIndex:(NSInteger)currentIndex
            withTotalCount:(NSInteger)totalCount
        withSuperViewWidth:(CGFloat)width;

@property (nonatomic, readonly, strong) id text;
@property (nonatomic, readonly, strong) GQImageViewrConfigure *configure;

@end

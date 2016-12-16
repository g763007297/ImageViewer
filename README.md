[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/angelcs1990/GQImageViewer/master/LICENSE)&nbsp;
[![](https://img.shields.io/badge/platform-iOS-brightgreen.svg)](http://cocoapods.org/?q=GQImageViewer)&nbsp;
[![support](https://img.shields.io/badge/support-iOS6.0%2B-blue.svg)](https://www.apple.com/nl/ios/)&nbsp;
# ImageViewer
一款多图文浏览器，支持图文混合浏览和单图片浏览，增加底部文字，仿今日头条效果;

图片原尺寸显示，不会变形，双击放大缩小，支持文本配置，支持多张本地及网络图片混合查看;

单图片浏览时单击消失，图文混合浏览时单击控制文字的显示和隐藏;

支持链式调用，支持指定查看哪张图片。不需要跳转到新的控制器，就可以覆盖当前控制器显示。

## Overview

![Demo Overview](https://github.com/g763007297/ImageViewer/blob/master/Screenshot/demo.gif)

##CocoaPods

1.在 Podfile 中添加 pod 'GQImageViewer'。
2.执行 pod install 或 pod update。
3.导入 GQImageViewer.h。

## Basic usage

1.将GQImageViewer文件夹加入到工程中。

2.在需要使用的图片查看器的控制器中#import "GQImageViewer.h"。

3.在需要触发查看器的地方添加以下代码（
如果仅需要图片浏览就只需要传图片即可，无需传文字数组）:

```objc

    //基本调用
        [[GQImageViewer sharedInstance] setImageArray:imageArray textArray:nil];//这是数据源
    [GQImageViewer sharedInstance].usePageControl = YES;//设置是否使用pageControl
    [GQImageViewer sharedInstance].needLoopScroll = NO;//设置是否需要循环滚动
    [GQImageViewer sharedInstance].needPanGesture = YES;//是否需要滑动消失手势
    [GQImageViewer sharedInstance].selectIndex = 5;//设置选中的索引
    [GQImageViewer sharedInstance].achieveSelectIndex = ^(NSInteger selectIndex){
        NSLog(@"%ld",selectIndex);
    };//获取当前选中的图片索引
    [GQImageViewer sharedInstance].laucnDirection = GQLaunchDirectionRight;//设置推出方向
    [[GQImageViewer sharedInstance] showInView:self.navigationController.view];//显示GQImageViewer到指定view上

	 //链式调用
    [GQImageViewer sharedInstance]
    .dataSouceArrayChain(imageArray,textArray)
    .usePageControlChain(YES)
    .needLoopScrollChain(NO)
    .needPanGestureChain(YES)
    .selectIndexChain(5)
    .achieveSelectIndexChain(^(NSInteger selectIndex){
        NSLog(@"%ld",selectIndex);
    })
    .longTapIndexChain(^(UIImage *image , NSInteger selectIndex){
        NSLog(@"%p,%ld",image,selectIndex);
    })
    .launchDirectionChain(GQLaunchDirectionRight)
    .showInViewChain(self.navigationController.view,YES);
  
```

4.配置信息，通过GQImageViewrConfigure类进行配置，现支持整体背景颜色、文字背景颜色、文字颜色、字体大小、文字最高显示多高、文本相对于父视图的缩进：

```objc

[GQImageViewrConfigure initWithImageViewBgColor:<#(UIColor *)#>
                                    textViewBgColor:<#(UIColor *)#>
                                          textColor:<#(UIColor *)#>
                                           textFont:<#(UIFont *)#>
                                      maxTextHeight:<#(CGFloat)#>
                                     textEdgeInsets:<#(UIEdgeInsets)#>];

```

  特别说明，如果是下网络图片的话，在iOS9以上的系统需要添加plist字段，否则无法拉取图片:
  
```objc
  
  <key>NSAppTransportSecurity</key>
  
	<dict>
	
		<key>NSAllowsArbitraryLoads</key>
		
		<true/>
		
	</dict>
	
``` 
	
## Level history
	
(1) 0.0.1

	github添加代码
	
(2) 0.0.2

	支持链式调用,支持显示在指定UIView上，无需指定UIViewController,支持设置推出方向

(3) 0.0.3

	新增获取当前选中的图片索引

(4) 0.0.4

	修复卡顿现象，更加精确快速获取当前图片的索引

(5) 0.0.5

	修复屏幕旋转时frame布局不准的bug

(6) 0.0.6

    去除依赖库，换成自己的图片下载库，添加长按手势和回调。

(7) 0.0.7

	增加底部文字，仿今日头条效果，支持上下滑动移除控件，增加控件属性配置。

(8) 0.0.8

    修复头文件冲突的bug

(9) 0.0.9

	 添加头部和底部自定义View

(10) wait a moment

##Support

欢迎指出bug或者需要改善的地方，欢迎提出issues，或者联系qq：763007297， 我会及时的做出回应，觉得好用的话不妨给个star吧，你的每个star是我持续维护的强大动力。

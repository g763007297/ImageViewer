[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/angelcs1990/SRouter/master/LICENSE)&nbsp;
[![](https://img.shields.io/badge/platform-iOS-brightgreen.svg)](http://cocoapods.org/?q=SRouter)&nbsp;

# ImageViewer

一款图片查看器，与SD结合使用，图片原尺寸显示，不会变形定，双击放大缩小，单击消失，支持多张图片，多个网络图片url混合查看，支持指定查看哪张图片。不需要跳转到新的viewcontroller，就可以覆盖当前控制器显示。

## Overview

![Demo Overview](https://github.com/g763007297/ImageViewer/blob/master/Screenshot/demo.gif)

## Basic usage

1.将GQImageViewer文件夹加入到工程中。如果你的工程中有SDWebImage就不需要再添加，如果没有则需要将SDWebImage加入。

2.在需要使用的图片查看器的控制器中#import "GQImageViewer.h"。

3.在需要触发查看器的地方添加以下代码:
``` objc

  GQImageViewer *imageViewer = [[GQImageViewer alloc] init];//初始化
  
  imageViewer.imageArray = @[] //可以是NSURL，UIImage，UIImageView，NSString，如果是string类型的话必须是未格式化的url
  
  imageViewer.pageControl = YES;//显示pageControl  如果需要显示label则传no；
  
  imageViewer.index = 5;//指定查看哪张图片,不能数组越界
  
  [imageViewer showView:self];
  
```

  特别说明，如果是下网络图片的话，在iOS9以上的系统需要添加plist字段，否则无法拉取图片:
  
  <key>NSAppTransportSecurity</key>
  
	<dict>
	
		<key>NSAllowsArbitraryLoads</key>
		
		<true/>
		
	</dict>
	
	欢迎指出错误的方法或者需要改善的地方。联系qq：763007297

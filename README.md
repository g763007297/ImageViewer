[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/angelcs1990/GQImageViewer/master/LICENSE)&nbsp;
[![](https://img.shields.io/badge/platform-iOS-brightgreen.svg)](http://cocoapods.org/?q=GQImageViewer)&nbsp;
[![support](https://img.shields.io/badge/support-iOS6.0%2B-blue.svg)](https://www.apple.com/nl/ios/)&nbsp;
# ImageViewer
一款多图文浏览器，支持图文混合浏览和单图片浏览，增加底部文字，仿今日头条效果;

图片原尺寸显示，不会变形，双击放大缩小，支持文本配置，支持多张本地及网络图片混合查看，支持WebP图片浏览;

单图片浏览时单击消失，图文混合浏览时单击控制文字的显示和隐藏;

支持链式调用，支持指定查看哪张图片。不需要跳转到新的控制器，就可以覆盖当前控制器显示。

## Overview

![Demo Overview](https://github.com/g763007297/ImageViewer/blob/master/Screenshot/demo.gif)

## CocoaPods

1.在 Podfile 中添加 pod 'GQImageViewer'。
2.执行 pod install 或 pod update。
3.导入 GQImageViewer.h。

## 1.0 WebP图片支持
 
使用: pod 'GQImageViewer/WebP'

本地Webp图片支持,使用以下两个方法进行获取：

```objc
#improt "UIImage+GQImageViewrCategory.h"

+ (UIImage *)gq_imageWithWebPFile:(NSString*)filePath;
+ (UIImage *)gq_imageWithWebPImageName:(NSString *)imageName;

```

如果不使用pod管理则需要在你的工程target->Build Settings->Prepeocessor Macros里添加一行:

```objc
GQ_WEBP=1

```

## 1.1 缓存数据

详情见:GQImageCacheManager头文件

```objc
/**
 *  清除内存中的缓存
 */
- (void)clearMemoryCache;

/**
 *  清除硬盘中的缓存
 */
- (void)clearDiskCache;

/**
 获取文件缓存总大小

 @return 文件大小
 */
- (NSUInteger)getSize;

/**
 获取文件总数

 @return 文件数
 */
- (NSUInteger)getDiskCount;

/**
 删除disk缓存
 */
- (void)clearDisk;
- (void)clearDiskOnCompletion:(GGWebImageNoParamsBlock)completion;

```

## 1.2 设置配置信息

### 1.2.1 自定义显示页面

自定义显示页面必须继承GQImageView，设置class名称必须在设置DataSource之前，否则都是为默认的GQImageView。

API：

使用GQImageViewer的configure的Block或者链式调用configureChain中配置imageViewClassName。

### 1.2.2  设置图片的伸缩模式GQImageViewerScaleType

该功能在configure里面进行属性配置，具体属性为：configure.scaleType，属性介绍如下:

(1)、GQImageViewerScaleTypeFullyDisplay

这个模式顾名思义就是让图片完全显示，不管图片大小，统一根据高度宽度等比例缩至可以完全显示，这个模式的好处有：

1.当长高图或者长宽图较少时不管屏幕如何旋转都能完全显示，不会影响滑动隐藏手势的作用。

副作用就是：

1.当长高图和长宽图多的时候会影响浏览效果，就算放大也会影响查看效果。

(2)、GQImageViewerScaleTypeEqualWidth

这个模式就是等宽高度自适应，图片的宽度和屏幕宽度一致，高度等比例伸缩， 该模式对于长高图浏览很有帮助，可以上下滑动查看长高图的各个位置，但是会影响滑动消失手势。

(3)、GQImageViewerScaleTypeEqualHeight

这个模式就是等高宽度自适应，图片的高度和屏幕高度一致，宽度等比例伸缩，该模式对于长宽图浏览很有帮助，可以左右滑动查看长宽图的各个位置。

```objc
typedef enum : NSUInteger {
    GQImageViewerScaleTypeFullyDisplay,//让图片完全显示 (高度宽度等比例缩放到图片能完全显示)
    GQImageViewerScaleTypeEqualWidth, //等宽高度自适应（宽度为屏幕宽度  高度自适应）
    GQImageViewerScaleTypeEqualHeight, //等高宽度自适应（高度为屏幕高度，宽度自适应）
} GQImageViewerScaleType;


```

### 1.2.3 视图推出和关闭方向GQLaunchDirection

该功能在configure里面进行属性配置，具体属性为：configure.laucnDirection，属性介绍如下:

(1)、GQLaunchDirectionBottom

该模式是将GQImageViewer视图从下往上推入，从上往下推出。

(2)、GQLaunchDirectionTop

该模式与GQLaunchDirectionBottom相反，是将GQImageViewer视图从上往下推入，从下往上推出。

(3)、GQLaunchDirectionLeft

该模式是将GQImageViewer视图从左往右推入，从右往左推出。

(4)、GQLaunchDirectionRight

该模式与GQLaunchDirectionLeft相反，是将GQImageViewer视图从右往左推入，从左往右推出。

(5)、GQLaunchDirectionFromRect

该模式是将GQImageViewer视图指定视图的转换Rect放大或缩小至指定superview的大小，消失则是从指定大小缩小或者放大为指定视图的转换Rect。

<span style="color: red"> laucnDirection设置为GQLaunchDirectionFromRect必须配合launchFromView使用才有效果，否则会crash。 </span>

```objc
typedef enum {
    GQLaunchDirectionBottom = 1,//从下往上推入
    GQLaunchDirectionTop,       //从上往下推入
    GQLaunchDirectionLeft,      //从左往右推入
    GQLaunchDirectionRight,     //从右往左推入
    GQLaunchDirectionFromRect   //从视图位置放大或缩小
}GQLaunchDirection;

```

### 1.2.4 自定义图片请求类NSMutableURLRequest

自定义图片请求class名称,必须继承GQImageViewrBaseURLRequest,需在设置DataSource之前设置,否则没有效果，否则都是为默认的GQImageViewrBaseURLRequest。

默认的GQImageViewrBaseURLRequest内有设置acceptType，userAgent，Cookie。
其他请求参数可覆盖方法configureRequestData进行设置

API:

直接通过引用头文件设置：

```objc
#import "GQImageDataDownload.h"

[[GQImageDataDownload sharedDownloadManager] setURLRequestClass:<#(__unsafe_unretained Class)#>]

```

也可以通过configure进行设置： 

```objc
.configureChain(^(GQImageViewrConfigure *configure) {
        [configure setRequestClassName:<#(NSString *)#>]
    })

```

<span style="color:red">Tips: configure的优先级大于直接引用头文件设置 </span>

### 1.2.5 设置网络图片的缓存机制

该功能在configure里面进行属性配置，具体属性为：configure.cacheType，属性介绍如下:

(1)、GQImageViewerCacheTypeNone

该模式就是无任何缓存，网络图片每次都是去请求。

(2)、GQImageViewerCacheTypeOnlyMemory

该模式会将图片缓存在内存中，当内存警告时会自动清理已节省内存空间，生存周期仅限一次APP的生命周期。

(3)、GQImageViewerCacheTypeDisk

该模式会将图片缓存至硬盘中以文件形式保存起来， 更新策略是：
    1)、在不清理硬盘缓存的情况下可以永久使用，读取一次硬盘文件后就会缓存在NSCache中，直到自动清理或者APP生命周期结束。
    2)、在APP生命周期中清理硬盘缓存且该图片已经缓存在NSCache中，此时会将NSCache中的缓存清除并去执行下载步骤。

## 1.3 Basic usage

1.将GQImageViewer和GQImageDownloader文件夹加入到工程中。

2.在需要使用的图片查看器的控制器中#import "GQImageViewer.h"。

3.在需要触发查看器的地方添加以下代码（
如果仅需要图片浏览就只需要传图片即可，无需传文字数组）:

```objc

        //基本调用
    [[GQImageViewer sharedInstance] setImageArray:imageArray textArray:nil];//这是数据源
    [GQImageViewer sharedInstance].selectIndex = 5;//设置选中的索引
    [GQImageViewer sharedInstance].achieveSelectIndex = ^(NSInteger selectIndex){//获取当前选中的图片索引
        NSLog(@"%ld",selectIndex);
    };
    [GQImageViewer sharedInstance].configure = ^(GQImageViewrConfigure *configure) {//设置配置信息
        [configure configureWithImageViewBgColor:[UIColor blackColor]
                                 textViewBgColor:nil
                                       textColor:[UIColor whiteColor]
                                        textFont:[UIFont systemFontOfSize:12]
                                   maxTextHeight:100
                                  textEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)
                                       scaleType:GQImageViewerScaleTypeEqualWidth];
    };
    [GQImageViewer sharedInstance].topViewConfigureChain(^(UIView *configureView) {//配置顶部view
        configureView.height = 50;
        configureView.backgroundColor = [UIColor redColor];
    });
    [GQImageViewer sharedInstance].bottomViewConfigureChain(^(UIView *configureView) {//配置底部view
        configureView.height = 50;
        configureView.backgroundColor = [UIColor yellowColor];
    });
    [[GQImageViewer sharedInstance] showInView:self.navigationController.view animation:YES];//显示GQImageViewer到指定view上

	 //链式调用
    GQImageViewrConfigure *configure =
    [GQImageViewrConfigure initWithImageViewBgColor:[UIColor blackColor]
                                    textViewBgColor:nil
                                          textColor:[UIColor whiteColor]
                                           textFont:[UIFont systemFontOfSize:12]
                                      maxTextHeight:100
                                     textEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)
                                          scaleType:GQImageViewerScaleTypeEqualWidth];
    //链式调用
    [GQImageViewer sharedInstance]
    .dataSouceArrayChain(imageArray,textArray)//如果仅需要图片浏览就只需要传图片即可，无需传文字数组
    .selectIndexChain(5)//设置选中的索引
	 .configureChain(^(GQImageViewrConfigure *configure) {
        [configure configureWithImageViewBgColor:[UIColor blackColor]
                                 textViewBgColor:nil
                                       textColor:[UIColor whiteColor]
                                        textFont:[UIFont systemFontOfSize:12]
                                   maxTextHeight:100
                                  textEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)
                                       scaleType:GQImageViewerScaleTypeEqualWidth];
    })
    .topViewConfigureChain(^(UIView *configureView) {
        configureView.height = 50;
        configureView.backgroundColor = [UIColor redColor];
    })
    .bottomViewConfigureChain(^(UIView *configureView) {
        configureView.height = 50;
        configureView.backgroundColor = [UIColor yellowColor];
    })
    .achieveSelectIndexChain(^(NSInteger selectIndex){//获取当前选中的图片索引
        NSLog(@"%ld",selectIndex);
    })
    .longTapIndexChain(^(UIImage *image , NSInteger selectIndex){//长按手势回调
        NSLog(@"%p,%ld",image,selectIndex);
    })
    .dissMissChain(^(){
        NSLog(@"dissMiss");
    })
    .showInViewChain(self.view.window,YES);//显示GQImageViewer到指定view上
  
```

4.配置信息，通过GQImageViewrConfigure类进行配置，现支持整体背景颜色、文字背景颜色、文字颜色、字体大小、文字最高显示多高、文本相对于父视图的缩进、是否需要循环滚动、显示PageControl或label、是否需要滑动消失手势、默认图片、自定义图片浏览界面class名称、推出方向：

```objc

.configureChain(^(GQImageViewrConfigure *configure) {
        [configure configureWithImageViewBgColor:[UIColor blackColor]
                                 textViewBgColor:nil
                                       textColor:[UIColor whiteColor]
                                        textFont:[UIFont systemFontOfSize:12]
                                   maxTextHeight:100
                                  textEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)
                                       scaleType:GQImageViewerScaleTypeEqualWidth];
})

//如果没有使用到文字显示就使用这个方法初始化
.configureChain(^(GQImageViewrConfigure *configure) {                           
	[configure configureWithImageViewBgColor:<#(UIColor *)#>
                                          scaleType:<#(GQImageViewerScaleType)#>];                                  
})

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

	GitHub添加代码。
	
(2) 0.0.2

	1.支持链式调用；
	2.支持显示在指定UIView上，无需指定UIViewController；
	3.支持设置推出方向。

(3) 0.0.3

	新增获取当前选中的图片索引。

(4) 0.0.4

	修复卡顿现象，更加精确快速获取当前图片的索引。

(5) 0.0.5

	修复屏幕旋转时frame布局不准的bug。

(6) 0.0.6
	
	1.去除依赖库，换成自己的图片下载库；
	2.添加长按手势和回调。

(7) 0.0.7

	1.增加底部文字，仿今日头条效果；
	2.支持上下滑动移除控件；
	3.增加控件属性配置。

(8) 0.0.8

	修复头文件冲突的bug。

(9) 0.0.9

	添加头部和底部自定义View。

(10) 0.1.0
 
	添加图片加载LoadingView。
 
(11) 0.1.1

	1.修复无网络状态下缺省图不显示的bug；
	2.topView滑动手势兼容。
 
(12) 1.0.0

	添加WebP支持。

(13) 1.0.1

	修复放大留白问题，修复新版本单例下载时复用问题。
 
(14) 1.0.2

	1.添加获取缓存大小，清除缓存接口；
	2.本地webp图片支持；
	3.滑动消失手势响应区域修改为图片区域；
	4.代码优化。

(15) 1.0.3

	1.增加视图消失回调；
	2.增加自定义图片显示页面。

(16) 1.0.4

	增加三种图片适配显示样式。

(17) 1.0.5
	
	1.将GQImageViewer配置全部归入GQImageViewrConfigure类中，避免过多的api调用麻烦；
	2.增加顶部和底部view的configure方法，使配置方法更加集中；
	3.配置属性不需要进行初始化了，只需要调用一个方法就可以了。

(18) 1.0.6
	
	1.完善自定义图片请求类。
	
(19) 1.0.7
	
	1.完善单击手势逻辑，增加配置属性needTapAutoHiddenTopBottomView配置是否需要自动隐藏顶部和底部视图。
	2.完善demo，增加自动与手动管理生命周期的🌰。
	
(20) 1.0.8
	
	1.消除xcode9推荐设置的警告。
	
(21) 1.0.9
	
	1.增加视图推出方向：GQLaunchDirectionFromRect ，从指定视图的Rect变大或者缩小。
	
(22) 1.1.0
	
	1.完善图片下载缓存策略，支持设置缓存类型；
	2.抽离图片下载部分，为后面做扩展奠定基础。
	
(23) 1.1.1

	wait a moment
	
## Support

欢迎指出bug或者需要改善的地方，欢迎提出issues、加Q群：578841619 ， 我会及时的做出回应，觉得好用的话不妨给个star吧，你的每个star是我持续维护的强大动力。

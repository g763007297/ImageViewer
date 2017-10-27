//
//  DemoViewController.m
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import "DemoViewController.h"
#import "GQImageViewer.h"
#import "UIImage+GQImageViewrCategory.h"
#import "GQImageDataDownload.h"

@interface DemoViewController (){
    UIView *demoView;
    NSMutableArray *imageArray;//图片数组
    NSMutableArray *textArray;//文字数组
}

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    textArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //添加本地图片
    [self addLocalImage];
    
    //添加webp图片
    [self addWebpImage];
    
    //添加网络图片
    [self addNetworkImage];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.visibleViewController.title = @"GQImageViewer";
    
    UIButton *autoManagerbutton = [self creatButtonWithTitle:@"点击此处查看图片(自动管理生命周期)" withSEL:@selector(showAutoManagerImageViewer:)];
    [autoManagerbutton setFrame:CGRectMake(5, CGRectGetMaxY(self.view.frame)/2+80, CGRectGetWidth(self.view.frame)-10, 40)];

    [self.view addSubview:autoManagerbutton];
    
    UIButton *manualManagerbutton = [self creatButtonWithTitle:@"点击此处查看图片(手动管理生命周期)" withSEL:@selector(showManualManagerImageViewer:)];
    [manualManagerbutton setFrame:CGRectMake(5, CGRectGetMaxY(self.view.frame)/2+140, CGRectGetWidth(self.view.frame)-10, 40)];
    
    [self.view addSubview:manualManagerbutton];
    
    demoView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame)/2-100, 64, 200, 300)];
    demoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:demoView];
}

//手动管理生命周期
- (void)showManualManagerImageViewer:(id)sender {
    [[GQImageDataDownload sharedDownloadManager] setURLRequestClass:NSClassFromString(@"DemoURLRequest")];
    GQWeakify(self);
    //链式调用
    [GQImageViewer sharedInstance]
    .configureChain(^(GQImageViewrConfigure *configure) {
        [configure configureWithImageViewBgColor:[UIColor blackColor]
                                 textViewBgColor:nil
                                       textColor:[UIColor whiteColor]
                                        textFont:[UIFont systemFontOfSize:12]
                                   maxTextHeight:100
                                  textEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)
                                       scaleType:GQImageViewerScaleTypeEqualWidth];
        [configure setRequestClassName:@"DemoURLRequest"];
        [configure setNeedPanGesture:NO];//设置是否需要滑动消失手势
        [configure setNeedTapAutoHiddenTopBottomView:YES];//设置是否需要自动隐藏顶部和底部视图
    })
    .dataSouceArrayChain(imageArray,textArray)//如果仅需要图片浏览就只需要传图片即可，无需传文字数组
    .selectIndexChain(5)//设置选中的索引
    .topViewConfigureChain(^(UIView *configureView) {
        configureView.height = 80;
        configureView.backgroundColor = [UIColor cyanColor];
        
        [weak_self topViewAddLabelText:@"手动管理生命周期" withTopView:configureView];
        
        UIButton *button = [weak_self creatButtonWithTitle:@"点击消失" withSEL:@selector(dissMissImageViewer:)];
        button.frame = CGRectMake(10, (configureView.height - 30) / 2, 100, 30);
        [configureView addSubview:button];
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
}

//自动管理生命周期
- (void)showAutoManagerImageViewer:(id)sender{
//    //基本调用
//    [[GQImageViewer sharedInstance] setImageArray:imageArray textArray:nil];//这是数据源
//    [GQImageViewer sharedInstance].selectIndex = 5;//设置选中的索引
//    [GQImageViewer sharedInstance].achieveSelectIndex = ^(NSInteger selectIndex){//获取当前选中的图片索引
//        NSLog(@"%ld",selectIndex);
//    };
//    [GQImageViewer sharedInstance].configure = ^(GQImageViewrConfigure *configure) {//设置配置信息
//        [configure configureWithImageViewBgColor:[UIColor blackColor]
//                                 textViewBgColor:nil
//                                       textColor:[UIColor whiteColor]
//                                        textFont:[UIFont systemFontOfSize:12]
//                                   maxTextHeight:100
//                                  textEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)
//                                       scaleType:GQImageViewerScaleTypeEqualWidth];
//    };
//    [GQImageViewer sharedInstance].topViewConfigureChain(^(UIView *configureView) {//配置顶部view
//        configureView.height = 50;
//        configureView.backgroundColor = [UIColor redColor];
//    });
//    [GQImageViewer sharedInstance].bottomViewConfigureChain(^(UIView *configureView) {//配置底部view
//        configureView.height = 50;
//        configureView.backgroundColor = [UIColor yellowColor];
//    });
//    [[GQImageViewer sharedInstance] showInView:self.navigationController.view animation:YES];//显示GQImageViewer到指定view上
    
    [[GQImageDataDownload sharedDownloadManager] setURLRequestClass:NSClassFromString(@"DemoURLRequest")];
    GQWeakify(self);
    //链式调用
    [GQImageViewer sharedInstance]
    .configureChain(^(GQImageViewrConfigure *configure) {
        [configure configureWithImageViewBgColor:[UIColor blackColor]
                                 textViewBgColor:nil
                                       textColor:[UIColor whiteColor]
                                        textFont:[UIFont systemFontOfSize:12]
                                   maxTextHeight:100
                                  textEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)
                                       scaleType:GQImageViewerScaleTypeEqualWidth];
        [configure setRequestClassName:@"DemoURLRequest"];
        [configure setNeedTapAutoHiddenTopBottomView:NO];//设置是否需要自动隐藏顶部和底部视图
    })
    .dataSouceArrayChain(imageArray,textArray)//如果仅需要图片浏览就只需要传图片即可，无需传文字数组
    .selectIndexChain(5)//设置选中的索引
    .topViewConfigureChain(^(UIView *configureView) {
        configureView.height = 80;
        configureView.backgroundColor = [UIColor redColor];
        [weak_self topViewAddLabelText:@"自动管理生命周期" withTopView:configureView];
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self afterAction];
    });
}

- (void)afterAction {
    [GQImageViewer sharedInstance]
    .topViewConfigureChain(^(UIView *configureView) {
        [configureView setBackgroundColor:[UIColor blueColor]];
        configureView.height = 100;
    });
}

- (void)dissMissImageViewer:(id)sender {
    [[GQImageViewer sharedInstance] dissMissWithAnimation:YES];
}

#pragma mark -- 添加本地图片
- (void)addLocalImage {
    for (int i = 1; i <10; i ++) {
        NSString *fromPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d.jpg",i] ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:fromPath];
        [imageArray addObject:[UIImage imageWithData:data]];
    }
    
    [textArray addObjectsFromArray:@[
                                     @"1.百度百科是百度公司推出的一部内容开放、自由的网络百科全书平台。其测试版于2006年4月20日上线，正式版在2008年4月21日发布，截至2016年4月，百度百科已经收录了超过1300多万的词条，参与词条编辑的网友超过580万人，几乎涵盖了所有已知的知识领域。",
                                     @"2.百度百科旨在创造一个涵盖各领域知识的中文信息收集平台。百度百科强调用户的参与和奉献精神，充分调动互联网用户的力量，汇聚上亿用户的头脑智慧，积极进行交流和分享。同时，百度百科实现与百度搜索、百度知道的结合，从不同的层次上满足用户对信息的需求。",
                                     @"3.发展简史\n百度百科是百度在2006年4月20日推出第三个基于搜索平台建立的社区类产品，这是继百度贴吧、百度知道之后，百度再度深化其知识搜索体系 。\n2007年1月10日，百科首页第一次改版。新增百科任务、百科之星、上周贡献榜等栏目。\n2007年4月2日，百科蝌蚪团正式成立，4月10日，百科蝌蚪团第一批成员出现，4月26日蝌蚪团首页上线。\n2007年4月19日，词条页面改版，改良词条页面的行高和行宽，在词条页面的底部增加了汉英词典解释，改进历史版本页面；5月百科编辑词条积分调整；6月开放分类检索升级，历史版本增加翻页功能，百科优质版本标准出台；9月高级编辑器上线，百科任务改版。11月百科推出相关词条，可以在百度知道里搜索到百科词条。\n2008年1月16日百度百科的第100万个词条诞生。\n2008年4月21日，百度百科正式版上线，首页增加优质版本榜，优质词条栏目  ；8月28日，百科帮助页更新，增加词条编辑原则；9月18日，词条浏览页升级。\n2009年9月15日，百度百科积分系统正式从百度知道中分离，拥有单独的一套积分体系。2009年12月29日，百科分类管理员主页上线。\n2010年1月18日 百度百科登上百度首页，此次调整也意味着百科业务在百度版图中的地位上升。\n2010年4月9日至11日 百度百科首次邀请33位用户齐聚北京共庆百度百科四周年。\n2011年1月，“知识先锋”百度百科校园计划上线，这一计划是百度百科与全国重点高校合作开展的社会实践互动项目。\n2012年5月18日百度百科数字博物馆正式上线，此举打破了以往网络上单纯以图片、文字为主的博物馆展品呈现模式，通过音频讲解、实境模拟、立体展现等多种形式，让用户通过互联网即可身临其境般地观赏展品，更平等便捷地了解历史文化。\n2012年9月百科学术委员会权威上线，推动百度百科“专业精英+热情网民”模式为广大用户提供更为全面、系统、专业、权威的知识分享服务。\n2012年11月首个城市百科成都站上线  ；城市百科为城市打造独特的城市网络名片，通过线上线下相结合的推广手段，有效的带动城市相关内容的建设，让更多的人了解这座城市。\n2013年9月25日新版词条页上线，这是自2008年以来词条页进行的第3次改版，也是词条浏览页变化最大的一次。11月4日百科商城全新升级，各团队专区全部合并，且统一使用财富值兑换礼品。11月18日百科任务系统上线，在该任务平台，活动的发起、参与编辑、词条评审等全由科友负责，任务自主性更高， 这是百科用户团队及词条编辑评审的一次重大改革和进步。\n2014年5月14日新版明星百科词条页升级上线，打破了以往枯燥的百科阅读方式，打造出一站式的明星信息聚合平台。\n2014年9月12日，“词媒体”平台的百度百科全新改版上线，通过引入包括博物馆、书法家协会、卫计委等大量PGC资源，城市百科、明星百科等特型内容聚合页，百度百科突破了传统百科全书的模式局限，借助权威合作、词条质量优化、视觉升级、强化社会化协作等措施。\n2014年12月5日，最高人民法院与百度联手，将全国各法院的详细准确信息发布在百度百科上，并以“中国法院地图”的形式集合呈现。承接最高人民法院在信息化上的新举措，作为全球最大的中文百科全书的百度百科，将成为全国法院大全的权威平台。\n2014年12月底，推出百科年度总结篇《史记·2014》，以总榜单和分类特色榜单的形式盘点2014年的年度热词。\n2015年2月9日，百度百科全球最大的海洋馆网上直播上线。  4月1日，正式对外发布百度百科“行业名人词条”。“行业名人词条的建立，将为各行业名人与普通民众之间搭起桥梁，在互联网上去伪存真，建立最权威、真实、全方位展现当代行业名人风貌的信息库，成为个人品牌打造的新始发站。4月7日，百度百科陕西数字方志馆上线。\n2015年5月，百科个人中心改版，透过百度百科的“数字窗口”，让人们能够更便捷地认知世界。\n2015年7月15日，百度百科“艺术百科”正式上线，将艺术家、艺术作品、高品质的艺术展览等权威信息集合呈现到每个网民的面前，依托百度搜索强大的资源和百科大量的艺术家词条信息，简洁、快速、精准得到感兴趣的艺术类信息。7月21日，百度百科“科普中国·科学百科”专题上线，结合百度百科强大的平台影响力以及中国科协14个学会及国内顶尖专家资源，在互联网上开辟出了一块丰富权威的科普阵地。  9月，百度百科上线“二战百科”专题，为中国人民抗日战争及世界反法西斯战争胜利70周年纪念日，推出再现历史的专题报道。\n2015年12月27日，百度百科与房教中国在“第二届房教中国地产人年会暨第八届中国房地产策划师年会”上宣布正式合作，双方签署《关于地产百科战略合作协议》，携手打造打造专门针对地产垂直领域的“地产百科”。\n2015年12月29日，百科推出《史记·2015》，在“史记2015”中，百度百科勇敢打破旧有模式，以三大主题:“殇.生之逝”、“耀.国之盛”、“鸣.民之声”，深度展现2015大事件。\n2016年4月28日，百度百科上线10周年发布会在京举行。会上百度百科全面展示了互联网知识平台的十年成就：累计创建词条1300多万，参与词条编辑的网友超过580万，每32秒诞生一个新词条。同时，百度百科正式发布了全新的产品“秒懂百科”。2016年8月22日下午，百度百科推出公益项目“萤火虫计划”，主要利用百度百科的内容结合VR、AR等技术，消除地理地域带来的限制，为贫困地区的学生提供知识获取途径，由王珞丹出任公益大使。",
                                     @"4.词条页主要由百科名片和正文内容和一些辅助的信息组成；百科名片包括概述和基本信息栏，其中概述为整个词条的简介，对全文进行概括性的介绍，基本信息栏主要是以表单的形式列出关键的信息点；\n词条正文内容按照一定的结构对词条展开介绍，其中词条可以设置一级目录和二级目录，用来对词条划分结构使用；在正文中，除了文字以外，还可以添加图片、视频、地图等富媒体内容，同时为了保证内容的准确性，理想状态是要求每段内容都有参考资料以辅证；\n在词条正文底部，为参考资料以及开放分类信息，正文右侧的辅助信息包括词条统计、词条贡献榜、百科消息等，词条统计包含页面浏览和编辑次数、最近更新时间和创建者等信息；词条贡献榜突出显示对词条申请为优质版本或特色词条的用户，并用勋章图标标记。",
                                     @"5.在词条页词条名右侧有一个编辑按钮，其中对词条划分了三类：锁定（一般为争议或医疗类词条，禁止编辑）、485保护（词条内容较为丰富，仅等级不低于4级且通过率不低于85%的账号可编辑）、普通类（任何百度账号都可编辑）；点击编辑之后，会进入编辑器页面。\n在编辑页面，可以对内容进行增删改等操作，其中编辑页顶部有各类功能，如字体、标题设置，添加参考资料、图片、表格、地图等操作，可以添加一些模块，如代码模块、公式模块、参演电视剧等特殊模块，也可以对一些内容添加内链，以链接到该添加内链所指向的词条上进行展开阅读。\n在对内容修改完毕之后，可以在编辑也右上角点击提交或者预览；点击预览，会显示词条如果通过之后的内容页；点击提交后需要写修改原因，之后需再次点击提交，最后进入系统审核阶段，并自动关闭了编辑页面。",
                                     @"6.百度百科开启权威编辑项目，与各行业垂直领域权威机构合作，这一系列的举措进一步提高词条的专业质量，实现从UGC（用户生产内容）到PGC（专家生产内容）的转变。而且2014年以来，突破了传统的百科功能，百度百科不仅集聚了逻辑严谨、内容丰富的文字内容，对于图片的表现形式也颇为多样化。同时，百度百科还可作为多种网络平台的“中心点”，并有望串联起包括社交网站、视频网站、新闻资讯、相关产品等网络信息，实现信息最大价值化 。\n在互联网时代，百度百科可以满足大部分网民迅速获取知识的需求，而且向所有人开放了一个免费获取知识的途径，实现了互联网时代的“开启民智”。百度百科是一本网络百科全书，互联网百科类产品从技术角度并无门槛，而其强大的内容生产能力、可以为用户提供权威、可信的知识是百度百科的核心竞争力。（赛迪网）",
                                     @"7.百度百科利用“词媒体”方式呈现新闻，一个重点新闻事件出现之后，用户会淹没在各种新闻列表中，而百度百科尝试用“词媒体”的方式来整理清楚来龙去脉，这属于百度百科的一个创新，可以让更多的网民可以更快，更精准的获取信息知识。\n百度百科已经在尝试探索品牌数字博物馆、城市百科等合作项目，通过各种技术手段，把各类机构的内容借助百科的平台传递给更多的用户，一方面可以对合作机构品牌影响力的提升，同时也给用户提供给更多有价值的信息。这类应用不仅可以用在展馆，还可以用在植物园、动物园等多种场景，这样的合作同样可以用在多种商业场景，新技术展示、新产品发布、新概念传播等，通过这些技术和创新技术，不仅仅让百度百科成为一本人人可以获得知识的中文百科全书，更重要的是它可以让更多的信息以更加生动的形式呈现在互联网网民的面前。",
                                     @"8.百度百科作为知识平台，节省了人们记忆大量内容的成本，可以做到随用随取且及时准确，不会给大脑造成负担，且不会受记忆偏差的影响。在人类从认知黑箱走向科学文明的过程中，掌握更多学科知识的人，点亮了这个世界；百度百科的存在，以互联网工具让每个人都成为有望推动文明进化节点到来的那个人。\n百度百科成功做到了传播广度与深度的结合，让“词媒体”与“权威知识平台”形成完美统一。",
                                      @"9.百度百科，以人人可编辑的模式，将碎片化的知识重新组合起来，在不增加人脑负担的同时，建立起人们与各学科之间互通的触点，从而以更简单的方式创造跨界的可能性。\n人人可编辑，意味着人人都在贡献自己的知识，同时也意味着人人都能够轻松从中获取所需。在“百科全书式”人物基本已不可能再出现的情况下，百度百科人人可编辑带来了另一种推动文明发展的方式。",]];
}

#pragma mark -- 添加webp图片
- (void)addWebpImage {
    
    UIImage *image = [UIImage gq_imageWithWebPImageName:@"Rosetta"];
    [imageArray addObject:image];
    [textArray addObject:@"10.本地webp文件测试"];
    
    [imageArray addObjectsFromArray:@[
    @"https://isparta.github.io/compare-webp/image/gif_webp/webp/1.webp",
    @"https://isparta.github.io/compare-webp/image/gif_webp/webp/2.webp"]];
    [textArray addObjectsFromArray:@[@"11.webp图片测试1",
                                     @"12.webp图片测试"]];
}

#pragma mark -- 添加网络图片
- (void)addNetworkImage {
    [imageArray addObjectsFromArray:@[
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g4/M00/0D/01/Cg-4y1ULoXCII6fEAAeQFx3fsKgAAXCmAPjugYAB5Av166.jpg",
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/05/0F/ChMkJ1erCriIJ_opAAY8rSwt72wAAUU6gMmHKwABjzF444.jpg",
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/00/ChMkJ1bKxCSIRtwrAA2uHQvukJIAALHCALaz_UADa41063.jpg",
                                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1493124763521&di=3b45d25ac37eafb8fa3d46b84e5d16e8&imgtype=0&src=http%3A%2F%2Fn1.itc.cn%2Fimg8%2Fwb%2Fsmccloud%2Ffetch%2F2015%2F07%2F24%2F53798299988865092.GIF",
                                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1493124863639&di=919c01df73d30f3d817556962dffb49b&imgtype=0&src=http%3A%2F%2Fwww.sinaimg.cn%2Fdy%2Fslidenews%2F52_img%2F2014_18%2F42283_345383_769322.gif",
                                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1493124895276&di=4238543ad86a7e17cb35c83443799e7f&imgtype=0&src=http%3A%2F%2Fpic.meirishentie.com%2Fpicture%2F10042%2F100422009%2Fmedium%2F100422009.gif",
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/07/0D/ChMkJlgaksOIEZcSAAYHVJbTdlwAAXcSwNDVmYABgds319.jpg",
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/03/ChMkJlbKxtqIF93BABJ066MJkLcAALHrQL_qNkAEnUD253.jpg",
                                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1493124933405&di=93b31ffb5157376866964e7fa0694d03&imgtype=0&src=http%3A%2F%2Fyun.hainei.org%2Fforum%2F201601%2F16%2F130426n1111b0z8z333b33.gif",
                                      @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1493124971062&di=1d8a65007e2756022a0b2b27183f2e22&imgtype=0&src=http%3A%2F%2Fs1.dwstatic.com%2Fgroup1%2FM00%2F48%2FFA%2F3f842c1ea411dede0212245e71ee3e71.gif"]];
    
    [textArray addObjectsFromArray:@[
                                     @"13.百度百科是百度公司推出的一部内容开放、自由的网络百科全书平台。其测试版于2006年4月20日上线，正式版在2008年4月21日发布，截至2016年4月，百度百科已经收录了超过1300多万的词条，参与词条编辑的网友超过580万人，几乎涵盖了所有已知的知识领域。",
                                     @"14.百度百科旨在创造一个涵盖各领域知识的中文信息收集平台。百度百科强调用户的参与和奉献精神，充分调动互联网用户的力量，汇聚上亿用户的头脑智慧，积极进行交流和分享。同时，百度百科实现与百度搜索、百度知道的结合，从不同的层次上满足用户对信息的需求。",
                                     @"15.发展简史\n百度百科是百度在2006年4月20日推出第三个基于搜索平台建立的社区类产品，这是继百度贴吧、百度知道之后，百度再度深化其知识搜索体系 。\n2007年1月10日，百科首页第一次改版。新增百科任务、百科之星、上周贡献榜等栏目。\n2007年4月2日，百科蝌蚪团正式成立，4月10日，百科蝌蚪团第一批成员出现，4月26日蝌蚪团首页上线。\n2007年4月19日，词条页面改版，改良词条页面的行高和行宽，在词条页面的底部增加了汉英词典解释，改进历史版本页面；5月百科编辑词条积分调整；6月开放分类检索升级，历史版本增加翻页功能，百科优质版本标准出台；9月高级编辑器上线，百科任务改版。11月百科推出相关词条，可以在百度知道里搜索到百科词条。\n2008年1月16日百度百科的第100万个词条诞生。\n2008年4月21日，百度百科正式版上线，首页增加优质版本榜，优质词条栏目  ；8月28日，百科帮助页更新，增加词条编辑原则；9月18日，词条浏览页升级。\n2009年9月15日，百度百科积分系统正式从百度知道中分离，拥有单独的一套积分体系。2009年12月29日，百科分类管理员主页上线。\n2010年1月18日 百度百科登上百度首页，此次调整也意味着百科业务在百度版图中的地位上升。\n2010年4月9日至11日 百度百科首次邀请33位用户齐聚北京共庆百度百科四周年。\n2011年1月，“知识先锋”百度百科校园计划上线，这一计划是百度百科与全国重点高校合作开展的社会实践互动项目。\n2012年5月18日百度百科数字博物馆正式上线，此举打破了以往网络上单纯以图片、文字为主的博物馆展品呈现模式，通过音频讲解、实境模拟、立体展现等多种形式，让用户通过互联网即可身临其境般地观赏展品，更平等便捷地了解历史文化。\n2012年9月百科学术委员会权威上线，推动百度百科“专业精英+热情网民”模式为广大用户提供更为全面、系统、专业、权威的知识分享服务。\n2012年11月首个城市百科成都站上线  ；城市百科为城市打造独特的城市网络名片，通过线上线下相结合的推广手段，有效的带动城市相关内容的建设，让更多的人了解这座城市。\n2013年9月25日新版词条页上线，这是自2008年以来词条页进行的第3次改版，也是词条浏览页变化最大的一次。11月4日百科商城全新升级，各团队专区全部合并，且统一使用财富值兑换礼品。11月18日百科任务系统上线，在该任务平台，活动的发起、参与编辑、词条评审等全由科友负责，任务自主性更高， 这是百科用户团队及词条编辑评审的一次重大改革和进步。\n2014年5月14日新版明星百科词条页升级上线，打破了以往枯燥的百科阅读方式，打造出一站式的明星信息聚合平台。\n2014年9月12日，“词媒体”平台的百度百科全新改版上线，通过引入包括博物馆、书法家协会、卫计委等大量PGC资源，城市百科、明星百科等特型内容聚合页，百度百科突破了传统百科全书的模式局限，借助权威合作、词条质量优化、视觉升级、强化社会化协作等措施。\n2014年12月5日，最高人民法院与百度联手，将全国各法院的详细准确信息发布在百度百科上，并以“中国法院地图”的形式集合呈现。承接最高人民法院在信息化上的新举措，作为全球最大的中文百科全书的百度百科，将成为全国法院大全的权威平台。\n2014年12月底，推出百科年度总结篇《史记·2014》，以总榜单和分类特色榜单的形式盘点2014年的年度热词。\n2015年2月9日，百度百科全球最大的海洋馆网上直播上线。  4月1日，正式对外发布百度百科“行业名人词条”。“行业名人词条的建立，将为各行业名人与普通民众之间搭起桥梁，在互联网上去伪存真，建立最权威、真实、全方位展现当代行业名人风貌的信息库，成为个人品牌打造的新始发站。4月7日，百度百科陕西数字方志馆上线。\n2015年5月，百科个人中心改版，透过百度百科的“数字窗口”，让人们能够更便捷地认知世界。\n2015年7月15日，百度百科“艺术百科”正式上线，将艺术家、艺术作品、高品质的艺术展览等权威信息集合呈现到每个网民的面前，依托百度搜索强大的资源和百科大量的艺术家词条信息，简洁、快速、精准得到感兴趣的艺术类信息。7月21日，百度百科“科普中国·科学百科”专题上线，结合百度百科强大的平台影响力以及中国科协14个学会及国内顶尖专家资源，在互联网上开辟出了一块丰富权威的科普阵地。  9月，百度百科上线“二战百科”专题，为中国人民抗日战争及世界反法西斯战争胜利70周年纪念日，推出再现历史的专题报道。\n2015年12月27日，百度百科与房教中国在“第二届房教中国地产人年会暨第八届中国房地产策划师年会”上宣布正式合作，双方签署《关于地产百科战略合作协议》，携手打造打造专门针对地产垂直领域的“地产百科”。\n2015年12月29日，百科推出《史记·2015》，在“史记2015”中，百度百科勇敢打破旧有模式，以三大主题:“殇.生之逝”、“耀.国之盛”、“鸣.民之声”，深度展现2015大事件。\n2016年4月28日，百度百科上线10周年发布会在京举行。会上百度百科全面展示了互联网知识平台的十年成就：累计创建词条1300多万，参与词条编辑的网友超过580万，每32秒诞生一个新词条。同时，百度百科正式发布了全新的产品“秒懂百科”。2016年8月22日下午，百度百科推出公益项目“萤火虫计划”，主要利用百度百科的内容结合VR、AR等技术，消除地理地域带来的限制，为贫困地区的学生提供知识获取途径，由王珞丹出任公益大使。",
                                     @"16.词条页主要由百科名片和正文内容和一些辅助的信息组成；百科名片包括概述和基本信息栏，其中概述为整个词条的简介，对全文进行概括性的介绍，基本信息栏主要是以表单的形式列出关键的信息点；\n词条正文内容按照一定的结构对词条展开介绍，其中词条可以设置一级目录和二级目录，用来对词条划分结构使用；在正文中，除了文字以外，还可以添加图片、视频、地图等富媒体内容，同时为了保证内容的准确性，理想状态是要求每段内容都有参考资料以辅证；\n在词条正文底部，为参考资料以及开放分类信息，正文右侧的辅助信息包括词条统计、词条贡献榜、百科消息等，词条统计包含页面浏览和编辑次数、最近更新时间和创建者等信息；词条贡献榜突出显示对词条申请为优质版本或特色词条的用户，并用勋章图标标记。",
                                     @"17.在词条页词条名右侧有一个编辑按钮，其中对词条划分了三类：锁定（一般为争议或医疗类词条，禁止编辑）、485保护（词条内容较为丰富，仅等级不低于4级且通过率不低于85%的账号可编辑）、普通类（任何百度账号都可编辑）；点击编辑之后，会进入编辑器页面。\n在编辑页面，可以对内容进行增删改等操作，其中编辑页顶部有各类功能，如字体、标题设置，添加参考资料、图片、表格、地图等操作，可以添加一些模块，如代码模块、公式模块、参演电视剧等特殊模块，也可以对一些内容添加内链，以链接到该添加内链所指向的词条上进行展开阅读。\n在对内容修改完毕之后，可以在编辑也右上角点击提交或者预览；点击预览，会显示词条如果通过之后的内容页；点击提交后需要写修改原因，之后需再次点击提交，最后进入系统审核阶段，并自动关闭了编辑页面。",
                                     @"18.百度百科开启权威编辑项目，与各行业垂直领域权威机构合作，这一系列的举措进一步提高词条的专业质量，实现从UGC（用户生产内容）到PGC（专家生产内容）的转变。而且2014年以来，突破了传统的百科功能，百度百科不仅集聚了逻辑严谨、内容丰富的文字内容，对于图片的表现形式也颇为多样化。同时，百度百科还可作为多种网络平台的“中心点”，并有望串联起包括社交网站、视频网站、新闻资讯、相关产品等网络信息，实现信息最大价值化 。\n在互联网时代，百度百科可以满足大部分网民迅速获取知识的需求，而且向所有人开放了一个免费获取知识的途径，实现了互联网时代的“开启民智”。百度百科是一本网络百科全书，互联网百科类产品从技术角度并无门槛，而其强大的内容生产能力、可以为用户提供权威、可信的知识是百度百科的核心竞争力。（赛迪网）",
                                     @"19.百度百科利用“词媒体”方式呈现新闻，一个重点新闻事件出现之后，用户会淹没在各种新闻列表中，而百度百科尝试用“词媒体”的方式来整理清楚来龙去脉，这属于百度百科的一个创新，可以让更多的网民可以更快，更精准的获取信息知识。\n百度百科已经在尝试探索品牌数字博物馆、城市百科等合作项目，通过各种技术手段，把各类机构的内容借助百科的平台传递给更多的用户，一方面可以对合作机构品牌影响力的提升，同时也给用户提供给更多有价值的信息。这类应用不仅可以用在展馆，还可以用在植物园、动物园等多种场景，这样的合作同样可以用在多种商业场景，新技术展示、新产品发布、新概念传播等，通过这些技术和创新技术，不仅仅让百度百科成为一本人人可以获得知识的中文百科全书，更重要的是它可以让更多的信息以更加生动的形式呈现在互联网网民的面前。",
                                     @"20.百度百科作为知识平台，节省了人们记忆大量内容的成本，可以做到随用随取且及时准确，不会给大脑造成负担，且不会受记忆偏差的影响。在人类从认知黑箱走向科学文明的过程中，掌握更多学科知识的人，点亮了这个世界；百度百科的存在，以互联网工具让每个人都成为有望推动文明进化节点到来的那个人。\n百度百科成功做到了传播广度与深度的结合，让“词媒体”与“权威知识平台”形成完美统一。",
                                     @"21.百度百科，以人人可编辑的模式，将碎片化的知识重新组合起来，在不增加人脑负担的同时，建立起人们与各学科之间互通的触点，从而以更简单的方式创造跨界的可能性。\n人人可编辑，意味着人人都在贡献自己的知识，同时也意味着人人都能够轻松从中获取所需。在“百科全书式”人物基本已不可能再出现的情况下，百度百科人人可编辑带来了另一种推动文明发展的方式。",
                                     @"22.百度百科"]];
}

- (void)topViewAddLabelText:(NSString *)textString withTopView:(UIView *)topView {
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.frame = CGRectMake(CGRectGetWidth(topView.frame)/2 - 75, CGRectGetHeight(topView.frame)/2 - 10, 150, 20);
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = textString;
    [textLabel setAdjustsFontSizeToFitWidth:YES];
    [topView addSubview:textLabel];
}

- (UIButton *)creatButtonWithTitle:(NSString *)title withSEL:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    button.layer.borderColor = [UIColor orangeColor].CGColor;
    button.layer.borderWidth = 1;
    
    button.layer.cornerRadius = 5;
    [button setClipsToBounds:YES];
    
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

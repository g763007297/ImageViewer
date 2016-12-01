//
//  DemoViewController.m
//  ImageViewer
//
//  Created by tusm on 15/12/31.
//  Copyright © 2015年 tusm. All rights reserved.
//

#import "DemoViewController.h"
#import "GQImageViewer.h"

@interface DemoViewController (){
    UIView *demoView;
}

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.visibleViewController.title = @"GQImageViewer";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(CGRectGetMaxX(self.view.frame)/2-100, CGRectGetMaxY(self.view.frame)/2+140, 200, 40)];
    [button setTitle:@"点击此处查看图片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    button.layer.borderColor = [UIColor orangeColor].CGColor;
    button.layer.borderWidth = 1;
    
    button.layer.cornerRadius = 5;
    [button setClipsToBounds:YES];
    
    [button addTarget:self action:@selector(showImageViewer:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    demoView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame)/2-100, 64, 200, 300)];
    demoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:demoView];
}

- (void)showImageViewer:(id)sender{
    NSMutableArray *imageArray = [[NSMutableArray alloc] initWithCapacity:0];
//    for (int i = 1; i <11; i ++) {
//        NSString *fromPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d.jpg",i] ofType:nil];
//        NSData *data = [NSData dataWithContentsOfFile:fromPath];
//        [imageArray addObject:[UIImage imageWithData:data]];
//    }
    [imageArray addObjectsFromArray:@[@"http://desk.fd.zol-img.com.cn/t_s960x600c5/g4/M00/0D/01/Cg-4y1ULoXCII6fEAAeQFx3fsKgAAXCmAPjugYAB5Av166.jpg",
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/05/0F/ChMkJ1erCriIJ_opAAY8rSwt72wAAUU6gMmHKwABjzF444.jpg",
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/00/ChMkJ1bKxCSIRtwrAA2uHQvukJIAALHCALaz_UADa41063.jpg",
                                      @"http://pic1.win4000.com/mobile/d/581c3bd22e898.jpg",
                                      @"http://img5.duitang.com/uploads/item/201610/31/20161031192742_rjhCx.thumb.700_0.jpeg",
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/06/ChMkJ1bKyhmIQFUTABNsnM0g-twAALIWgPk0D0AE2y0479.jpg",
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/07/0D/ChMkJlgaksOIEZcSAAYHVJbTdlwAAXcSwNDVmYABgds319.jpg",
                                      @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/03/ChMkJlbKxtqIF93BABJ066MJkLcAALHrQL_qNkAEnUD253.jpg",
                                      @"http://image101.360doc.com/DownloadImg/2016/11/0404/83709873_1.jpg",
                                      @"http://image101.360doc.com/DownloadImg/2016/11/0404/83709873_8.jpg"]];
    
    NSArray *textArray = @[@"百度百科是百度公司推出的一部内容开放、自由的网络百科全书平台。其测试版于2006年4月20日上线，正式版在2008年4月21日发布，截至2016年4月，百度百科已经收录了超过1300多万的词条，参与词条编辑的网友超过580万人，几乎涵盖了所有已知的知识领域。",
                                  @"百度百科旨在创造一个涵盖各领域知识的中文信息收集平台。百度百科强调用户的参与和奉献精神，充分调动互联网用户的力量，汇聚上亿用户的头脑智慧，积极进行交流和分享。同时，百度百科实现与百度搜索、百度知道的结合，从不同的层次上满足用户对信息的需求。",
                           @"发展简史\n百度百科是百度在2006年4月20日推出第三个基于搜索平台建立的社区类产品，这是继百度贴吧、百度知道之后，百度再度深化其知识搜索体系 。\n2007年1月10日，百科首页第一次改版。新增百科任务、百科之星、上周贡献榜等栏目。\n2007年4月2日，百科蝌蚪团正式成立，4月10日，百科蝌蚪团第一批成员出现，4月26日蝌蚪团首页上线。\n2007年4月19日，词条页面改版，改良词条页面的行高和行宽，在词条页面的底部增加了汉英词典解释，改进历史版本页面；5月百科编辑词条积分调整；6月开放分类检索升级，历史版本增加翻页功能，百科优质版本标准出台；9月高级编辑器上线，百科任务改版。11月百科推出相关词条，可以在百度知道里搜索到百科词条。\n2008年1月16日百度百科的第100万个词条诞生。\n2008年4月21日，百度百科正式版上线，首页增加优质版本榜，优质词条栏目  ；8月28日，百科帮助页更新，增加词条编辑原则；9月18日，词条浏览页升级。\n2009年9月15日，百度百科积分系统正式从百度知道中分离，拥有单独的一套积分体系。2009年12月29日，百科分类管理员主页上线。\n2010年1月18日 百度百科登上百度首页，此次调整也意味着百科业务在百度版图中的地位上升。\n2010年4月9日至11日 百度百科首次邀请33位用户齐聚北京共庆百度百科四周年。\n2011年1月，“知识先锋”百度百科校园计划上线，这一计划是百度百科与全国重点高校合作开展的社会实践互动项目。\n2012年5月18日百度百科数字博物馆正式上线，此举打破了以往网络上单纯以图片、文字为主的博物馆展品呈现模式，通过音频讲解、实境模拟、立体展现等多种形式，让用户通过互联网即可身临其境般地观赏展品，更平等便捷地了解历史文化。\n2012年9月百科学术委员会权威上线，推动百度百科“专业精英+热情网民”模式为广大用户提供更为全面、系统、专业、权威的知识分享服务。\n2012年11月首个城市百科成都站上线  ；城市百科为城市打造独特的城市网络名片，通过线上线下相结合的推广手段，有效的带动城市相关内容的建设，让更多的人了解这座城市。\n2013年9月25日新版词条页上线，这是自2008年以来词条页进行的第3次改版，也是词条浏览页变化最大的一次。11月4日百科商城全新升级，各团队专区全部合并，且统一使用财富值兑换礼品。11月18日百科任务系统上线，在该任务平台，活动的发起、参与编辑、词条评审等全由科友负责，任务自主性更高， 这是百科用户团队及词条编辑评审的一次重大改革和进步。\n2014年5月14日新版明星百科词条页升级上线，打破了以往枯燥的百科阅读方式，打造出一站式的明星信息聚合平台。\n2014年9月12日，“词媒体”平台的百度百科全新改版上线，通过引入包括博物馆、书法家协会、卫计委等大量PGC资源，城市百科、明星百科等特型内容聚合页，百度百科突破了传统百科全书的模式局限，借助权威合作、词条质量优化、视觉升级、强化社会化协作等措施。\n2014年12月5日，最高人民法院与百度联手，将全国各法院的详细准确信息发布在百度百科上，并以“中国法院地图”的形式集合呈现。承接最高人民法院在信息化上的新举措，作为全球最大的中文百科全书的百度百科，将成为全国法院大全的权威平台。\n2014年12月底，推出百科年度总结篇《史记·2014》，以总榜单和分类特色榜单的形式盘点2014年的年度热词。\n2015年2月9日，百度百科全球最大的海洋馆网上直播上线。  4月1日，正式对外发布百度百科“行业名人词条”。“行业名人词条的建立，将为各行业名人与普通民众之间搭起桥梁，在互联网上去伪存真，建立最权威、真实、全方位展现当代行业名人风貌的信息库，成为个人品牌打造的新始发站。4月7日，百度百科陕西数字方志馆上线。\n2015年5月，百科个人中心改版，透过百度百科的“数字窗口”，让人们能够更便捷地认知世界。\n2015年7月15日，百度百科“艺术百科”正式上线，将艺术家、艺术作品、高品质的艺术展览等权威信息集合呈现到每个网民的面前，依托百度搜索强大的资源和百科大量的艺术家词条信息，简洁、快速、精准得到感兴趣的艺术类信息。7月21日，百度百科“科普中国·科学百科”专题上线，结合百度百科强大的平台影响力以及中国科协14个学会及国内顶尖专家资源，在互联网上开辟出了一块丰富权威的科普阵地。  9月，百度百科上线“二战百科”专题，为中国人民抗日战争及世界反法西斯战争胜利70周年纪念日，推出再现历史的专题报道。\n2015年12月27日，百度百科与房教中国在“第二届房教中国地产人年会暨第八届中国房地产策划师年会”上宣布正式合作，双方签署《关于地产百科战略合作协议》，携手打造打造专门针对地产垂直领域的“地产百科”。\n2015年12月29日，百科推出《史记·2015》，在“史记2015”中，百度百科勇敢打破旧有模式，以三大主题:“殇.生之逝”、“耀.国之盛”、“鸣.民之声”，深度展现2015大事件。\n2016年4月28日，百度百科上线10周年发布会在京举行。会上百度百科全面展示了互联网知识平台的十年成就：累计创建词条1300多万，参与词条编辑的网友超过580万，每32秒诞生一个新词条。同时，百度百科正式发布了全新的产品“秒懂百科”。2016年8月22日下午，百度百科推出公益项目“萤火虫计划”，主要利用百度百科的内容结合VR、AR等技术，消除地理地域带来的限制，为贫困地区的学生提供知识获取途径，由王珞丹出任公益大使。",
                           @"词条页主要由百科名片和正文内容和一些辅助的信息组成；百科名片包括概述和基本信息栏，其中概述为整个词条的简介，对全文进行概括性的介绍，基本信息栏主要是以表单的形式列出关键的信息点；词条正文内容按照一定的结构对词条展开介绍，其中词条可以设置一级目录和二级目录，用来对词条划分结构使用；在正文中，除了文字以外，还可以添加图片、视频、地图等富媒体内容，同时为了保证内容的准确性，理想状态是要求每段内容都有参考资料以辅证；在词条正文底部，为参考资料以及开放分类信息，正文右侧的辅助信息包括词条统计、词条贡献榜、百科消息等，词条统计包含页面浏览和编辑次数、最近更新时间和创建者等信息；词条贡献榜突出显示对词条申请为优质版本或特色词条的用户，并用勋章图标标记。",
                                  @"http://img5.duitang.com/uploads/item/201610/31/20161031192742_rjhCx.thumb.700_0.jpeg",
                                  @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/06/ChMkJ1bKyhmIQFUTABNsnM0g-twAALIWgPk0D0AE2y0479.jpg",
                                  @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/07/0D/ChMkJlgaksOIEZcSAAYHVJbTdlwAAXcSwNDVmYABgds319.jpg",
                                  @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/03/ChMkJlbKxtqIF93BABJ066MJkLcAALHrQL_qNkAEnUD253.jpg",
                                  @"http://image101.360doc.com/DownloadImg/2016/11/0404/83709873_1.jpg",
                                  @"http://image101.360doc.com/DownloadImg/2016/11/0404/83709873_8.jpg"];
    
    //基本调用
//    [[GQImageViewer sharedInstance] setImageArray:imageArray textArray:nil];
//    [GQImageViewer sharedInstance].usePageControl = YES;
//    [GQImageViewer sharedInstance].selectIndex = 5;
//    [GQImageViewer sharedInstance].achieveSelectIndex = ^(NSInteger selectIndex){
//        NSLog(@"%ld",selectIndex);
//    };
//    [GQImageViewer sharedInstance].laucnDirection = GQLaunchDirectionRight;
//    [[GQImageViewer sharedInstance] showInView:self.navigationController.view animation:YES];
    
//    链式调用
    [GQImageViewer sharedInstance]
    .dataSouceArrayChain(imageArray,textArray)
    .usePageControlChain(NO)
    .needLoopScrollChain(NO)
    .selectIndexChain(5)
    .achieveSelectIndexChain(^(NSInteger selectIndex){
        NSLog(@"%ld",selectIndex);
    })
    .longTapIndexChain(^(UIImage *image , NSInteger selectIndex){
        NSLog(@"%p,%ld",image,selectIndex);
    })
    .launchDirectionChain(GQLaunchDirectionRight)
    .showInViewChain(self.navigationController.view,YES);
    
//    [self performSelector:@selector(changeView) withObject:nil afterDelay:3.0];
}

/**
 *  模拟修改图片数组
 */
- (void)changeView{
    [GQImageViewer sharedInstance]
    .dataSouceArrayChain(@[@"http://g.hiphotos.baidu.com/image/pic/item/a8ec8a13632762d0a97e5899a5ec08fa513dc650.jpg"],nil)
    .usePageControlChain(NO)
    .selectIndexChain(8);
    
//    [GQImageViewer sharedInstance].usePageControl = NO;
//    [GQImageViewer sharedInstance].imageArray = @[@"http://g.hiphotos.baidu.com/image/pic/item/a8ec8a13632762d0a97e5899a5ec08fa513dc650.jpg"];
//    [GQImageViewer sharedInstance].selectIndex = 8;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

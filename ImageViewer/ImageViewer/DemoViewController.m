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
                                      @"http://pic1.win4000.com/mobile/d/581c3bd22e898.jpg"]];
    
    NSArray *textArray = @[@"http://desk.fd.zol-img.com.cn/t_s960x600c5/g4/M00/0D/01/Cg-4y1ULoXCII6fEAAeQFx3fsKgAAXCmAPjugYAB5Av166.jpg",
                                  @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/05/0F/ChMkJ1erCriIJ_opAAY8rSwt72wAAUU6gMmHKwABjzF444.jpg",
                                  @"http://desk.fd.zol-img.com.cn/t_s960x600c5/g5/M00/02/00/ChMkJ1bKxCSIRtwrAA2uHQvukJIAALHCALaz_UADa41063.jpg",
                                  @"http://pic1.win4000.com/mobile/d/581c3bd22e898.jpg",
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
    .dataSouceArrayChain(imageArray,nil)
    .usePageControlChain(NO)
    .needLoopScrollChain(YES)
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

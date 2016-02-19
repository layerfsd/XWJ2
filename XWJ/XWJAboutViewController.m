//
//  XWJAboutViewController.m
//  XWJ
//
//  Created by 聚城科技 on 15/12/28.
//  Copyright © 2015年 Paul. All rights reserved.
//

#import "XWJAboutViewController.h"
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH [UIScreen mainScreen].bounds.size.width
@interface XWJAboutViewController ()

@end

@implementation XWJAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于信我家";
    // Do any additional setup after loading the view.
    [self createWebView];
}
-(void)createWebView{
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    //    设置背景色
    webView.backgroundColor = [UIColor clearColor];
    //    使网页透明
    webView.opaque = NO;
    //    加载网页
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ecmall.hisenseplus.com:88/index.php?app=article&act=content_only&article_id=6"]]];
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end

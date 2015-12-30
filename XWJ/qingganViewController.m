//
//  qingganViewController.m
//  XWJ
//
//  Created by 聚城科技 on 15/12/21.
//  Copyright © 2015年 Paul. All rights reserved.
//

#import "qingganViewController.h"
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH [UIScreen mainScreen].bounds.size.width


@interface qingganViewController ()

@end

@implementation qingganViewController
{
    UIButton *_button;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self downLoadData];
    [self createUI];
    
}

-(void)createUI{
    NSArray *array  = @[@"已婚",@"未婚"];
    for (int i = 0; i < 2; i++) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame  = CGRectMake(30, 140 + 50*i, WIDTH - 60, 30);
        [_button setTitle:array[i] forState:UIControlStateNormal];
        _button.layer.cornerRadius = 5;
        _button.backgroundColor = [UIColor colorWithRed:0.18 green:0.67 blue:0.65 alpha:1];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.tag = i+10;
        [_button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_button];
    }
}

-(void)onButtonClick:(UIButton*)button{
    
    //    UIButton *button = (UIButton*)[self.view viewWithTag:10];
    // UIButton *butotn = button.titleLabel.title
    self.returnStrBlock(button.titleLabel.text);
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void)downLoadData{

    NSString *qingganUrl = @"http://www.hisenseplus.com:8100/appPhone/rest/user/findHobbies";
 //   http://www.hisenseplus.com:8100/appPhone/rest/user/findEmotions
    AFHTTPRequestOperationManager *manager  = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //请求参数
    NSMutableDictionary *parameters =[[NSMutableDictionary alloc] init];
    
    [manager POST:qingganUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //解析服务器返回的数据responseObject
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"dict==%@",responseObject);
          NSLog(@"dict==%@",dict);
        

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"请求失败");
    }];
    
    //    MainViewController * main = [[MainViewController alloc]init];
    //    [self.navigationController pushViewCon
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
//
//  XWJSPinfoViewController.m
//  XWJ
//
//  Created by Sun on 16/1/8.
//  Copyright © 2016年 Paul. All rights reserved.
//

#import "XWJSPinfoViewController.h"

#define HEIGHT_VIEW2 200

@interface XWJSPinfoViewController ()

@end

@implementation XWJSPinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title  = @"详情";
    UIScrollView *scoll  =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 5, SCREEN_SIZE.width, SCREEN_SIZE.height)];
    
    [self.view addSubview:scoll];
    UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, HEIGHT_VIEW2)];

    if (self.arr&&self.arr.count>0) {
  
        NSArray *imgs = self.arr;
        
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, HEIGHT_VIEW2*imgs.count);
        for (int i =0; i<imgs.count; i++) {

            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(40,HEIGHT_VIEW2*i, SCREEN_SIZE.width-4-80, HEIGHT_VIEW2)];
            img.contentMode  = UIViewContentModeRedraw;
            [img sd_setImageWithURL:[NSURL URLWithString:[imgs objectAtIndex:i]]placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//                img.frame = CGRectMake(img.frame.origin.x, img.frame.origin.y, image.size.width, image.size.height);
            }];
            [view addSubview:img];
        }
        [scoll addSubview:view];
        scoll.contentSize =  CGSizeMake(0,view.frame.size.height);

    }
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
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

//
//  XWJSPinfoViewController.m
//  XWJ
//
//  Created by Sun on 16/1/8.
//  Copyright © 2016年 Paul. All rights reserved.
//

#import "XWJSPinfoViewController.h"

#define HEIGHT_VIEW2 220

@interface XWJSPinfoViewController ()

@end

@implementation XWJSPinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title  = @"详情";
    UIScrollView *scoll  =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 5, SCREEN_SIZE.width, SCREEN_SIZE.height + 44 )];
    
    [self.view addSubview:scoll];
    UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, HEIGHT_VIEW2)];

    CGFloat __block height =0.0 ;
    if (self.arr&&self.arr.count>0) {
        
        NSArray *imgs = self.arr;
        NSMutableArray * images = [NSMutableArray array];
        UIImageView * lastImageV = [[UIImageView alloc]init];
        lastImageV.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 0);
        //       view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, HEIGHT_VIEW2*imgs.count);
        for (int i = 0; i<imgs.count; i++) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0,(HEIGHT_VIEW2)*i, SCREEN_SIZE.width, HEIGHT_VIEW2)];
            
            if (i > 0) {
                lastImageV = images[i - 1];
            }
            img.contentMode  = UIViewContentModeRedraw;
            
            NSString *str = [imgs objectAtIndex:i];
            
            [img sd_setImageWithURL:[NSURL URLWithString:str]placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(image){
                    img.frame = CGRectMake(img.frame.origin.x, lastImageV.frame.origin.y+lastImageV.frame.size.height, img.frame.size.width, img.frame.size.width*image.size.height/image.size.width);
                    img.image = image;
                    height = height + img.frame.size.height;
                    scoll.contentSize =  CGSizeMake(0,height);
                }
            }];
            [images addObject:img];
            [scoll addSubview:img];
        }
        
    }
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

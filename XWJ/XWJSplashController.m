//
//  XWJSplashController.m
//  XWJ
//
//  Created by Sun on 16/1/26.
//  Copyright © 2016年 Paul. All rights reserved.
//

#import "XWJSplashController.h"

@interface XWJSplashController()<UIScrollViewDelegate>
@property UIScrollView* scrollView;
@property NSInteger count;
@end
@implementation XWJSplashController
@synthesize scrollView;

-(void)viewDidLoad{
    [super viewDidLoad];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width
                                                               , SCREEN_SIZE.height)];
    self.count = 3;
    for (int i=0; i<self.count; i++) {
        
        UIImageView*imv = [[UIImageView alloc] initWithFrame:CGRectMake(i*SCREEN_SIZE.width, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)];
//        UIImage *image = [UIImage imageNamed:@"splash3"];
        imv.image = [UIImage imageNamed:[NSString stringWithFormat:@"splash%d",i+1]];
        if (i==self.count-1) {
            
            UITapGestureRecognizer* singleRecognizer;
            singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gologin)];
            //点击的次数
            singleRecognizer.numberOfTapsRequired = 1;
            imv.userInteractionEnabled = YES;
            [imv addGestureRecognizer:singleRecognizer];
        }
        [scrollView addSubview:imv];
    }
    
//    scrollView.delegate = self;
    scrollView.scrollsToTop = NO;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.contentSize =CGSizeMake(self.count*SCREEN_SIZE.width, 0);
    [self.view addSubview:scrollView];
}

-(void)gologin{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLaunched"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"XWJLoginStoryboard" bundle:nil];
    self.view.window.rootViewController = [loginStoryboard instantiateInitialViewController];
}

#pragma mark - UIScrollView Delegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat scrollW = self.scrollView.frame.size.width;
    NSInteger currentPage = self.scrollView.contentOffset.x / scrollW;
    

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat scrollW = self.scrollView.frame.size.width;
    NSInteger currentPage = self.scrollView.contentOffset.x / scrollW;
    [self.scrollView setContentOffset:CGPointMake(self.count * scrollW, 0) animated:NO];
    
//    if (currentPage == self.count + 1) {
//        
//        self.pageControl.currentPage = 0;
//        
//        [self.scrollView setContentOffset:CGPointMake(scrollW, 0) animated:NO];
//        
//    } else if (currentPage == 0) {
//        
//        self.pageControl.currentPage = self.count;
//        
//        [self.scrollView setContentOffset:CGPointMake(self.count * scrollW, 0) animated:NO];
//        
//    } else {
//        
//        self.pageControl.currentPage = currentPage - 1;
//    }
}
@end
//
//  XWJjianduViewController.m
//  XWJ
//
//  Created by Sun on 15/12/2.
//  Copyright © 2015年 Paul. All rights reserved.
//

#import "XWJjianduViewController.h"
#import "WuyeTableViewCell.h"
#import "XWJdef.h"
#import "XWJCity.h"
#import "XWJAccount.h"
#import "XWJjianduDetailViewController.h"
@interface XWJjianduViewController ()

@property (weak, nonatomic) IBOutlet UIView *adView;
@property(nonatomic)UIScrollView *scrollview;
@property NSMutableArray *yuangong;
@property NSMutableArray *work;
@end
@implementation XWJjianduViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.work = [NSMutableArray array];
    self.yuangong = [NSMutableArray array];
}
//点击进入物业监督的广告详情
- (void)bannerView:(LCBannerView *)bannerView didClickedImageIndex:(NSInteger)index {
    
    XWJjianduDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"jiandudetail2"];
    detail.dic = [self.work objectAtIndex:index];
    [self.navigationController showViewController:detail sender:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"物业监督";
    self.view.backgroundColor = [UIColor whiteColor];
    self.tabBarController.tabBar.hidden = YES;
    [self getWuye];
    
}
//添加广告视图
-(void)addViews{
    NSMutableArray *URLs = [NSMutableArray array] ;
    
    for (NSDictionary *dic in self.work) {
        [URLs addObject:[dic objectForKey:@"photo"]];
    }
    //设置广告页的数量和长宽
    NSInteger count = self.work.count;
    CGFloat height = self.view.bounds.size.width/2;
    CGFloat width = height/3*4;
    
    self.adScrollView.contentSize = CGSizeMake((width + 10) * count - 20, height);
    self.adScrollView.contentSize = CGSizeMake((width + 10) * count - 20, 0);
    for (int i=0; i<count; i++) {
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(i*(width+10), 0, width - 5, height)];
        
        UIImageView *im =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width - 10, height - 10)];
        [im setContentMode:UIViewContentModeScaleAspectFill];
        im.clipsToBounds = YES;
        im.tag = i;
        im.userInteractionEnabled = YES;
        [im sd_setImageWithURL:[NSURL URLWithString:URLs[i]]placeholderImage:nil];
        
        UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        //点击的次数
        singleRecognizer.numberOfTapsRequired = 1;
        [im addGestureRecognizer:singleRecognizer];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(width - 10 - 60,0, 60, 16)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12];
        NSString *type = [[self.work objectAtIndex:i] valueForKey:@"Types"];
        label.text = type;
        label.textAlignment = NSTextAlignmentCenter;
        if ([type isEqualToString:@"工作进展"]) {
            label.backgroundColor = XWJColor(67, 164, 83);
        }else if ([type isEqualToString:@"工作记录"]){
            label.backgroundColor = XWJColor(234, 116, 13);
        }else{
            label.backgroundColor = XWJColor(255,44, 56);
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, backView.frame.size.height-52, width - 10, 52 - 10)];
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.7;
        //展示内容
        UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, width - 10 - 10, 12)];
        label1.textColor = [UIColor whiteColor];
        label1.text = [[self.work objectAtIndex:i] valueForKey:@"Content"];
        label1.font = [UIFont systemFontOfSize:12.0];
        label1.lineBreakMode = NSLineBreakByTruncatingTail;
        label1.numberOfLines = 1;
        //展示时间
        UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(5, 28, 100, 12)];
        label2.textColor = [UIColor whiteColor];
        label2.text = [[self.work objectAtIndex:i] valueForKey:@"ReleaseTime"];
        label2.font = [UIFont systemFontOfSize:12];
        //展示点击的次数
        UILabel * label3 = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width - 105, 28, 100, 12)];
        label3.textColor = [UIColor whiteColor];
        label3.textAlignment = NSTextAlignmentRight;
        label3.text = [NSString stringWithFormat:@"点击:%@",[[self.work objectAtIndex:i] objectForKey:@"clicks"]];
        label3.font = [UIFont systemFontOfSize:10];
        
        [view addSubview:label1];
        [view addSubview:label2];
        [view addSubview:label3];
        [backView addSubview:im];
        [backView addSubview:label];
        [backView addSubview:view];
        [self.adScrollView addSubview:backView];
    }
}

-(void)click:(UITapGestureRecognizer *)ges{
    
    [self bannerView:nil didClickedImageIndex:ges.view.tag];
}
//获取物业监督的详细信息
-(void)getWuye{
    NSString *url = GETWUYE_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[XWJAccount instance].aid  forKey:@"a_id"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        /*
         Name = "\U674e\U56db";
         Phone = 13888888888;
         Position = "\U5ba2\U670d\U4e3b\U7ba1";
         photo = "http://www.hisenseplus.com/HisenseUpload/supervise/u=2084087811,2896369697&fm=21&gp=02015127101117.jpg";
         
         ClickPraiseCount = 0;
         Content = "\U6211\U4eec\U7684\U65b0\U5199\U5b57\U697c";
         LeaveWordCount = 0;
         ReleaseTime = "12-13 20:19";
         ShareQQCount = 0;
         Types = "\U5c0f\U533a\U6574\U6539";
         id = 7;
         photo = "http://www.hisenseplus.com/HisenseUpload/work/20151213201949760.jpg";
         
         */
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            CLog(@"dic----- %@",dic);
            NSNumber *res =[dic objectForKey:@"result"];
            if ([res intValue] == 1) {
                
                self.work = [NSMutableArray array];
                self.yuangong = [NSMutableArray array];
                [self.yuangong addObjectsFromArray:[dic objectForKey:@"supervise"] ] ;
                [self.work addObjectsFromArray:[dic objectForKey:@"work"]];
                
                if (self.yuangong.count>0) {
                    [self.tableView reloadData];
                }else{
                    self.tableView.hidden = YES;
                }
                
                [self addViews];
                
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden =NO;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.yuangong.count>0)
        return 1;
    else
        return 0;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 30.0;
//}
//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"物业员工";
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.yuangong.count;
}
//设置物业员工的详细信息
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WuyeTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"wuyecell"];
    if (!cell) {
        cell = [[WuyeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"wuyecell"];
    }
    [cell.headImg sd_setImageWithURL:[NSURL URLWithString:[[self.yuangong objectAtIndex:indexPath.row] objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"demo"]];
    cell.headImg.layer.cornerRadius = cell.headImg.frame.size.width/2;
    cell.headImg.layer.masksToBounds = YES;
    cell.nameLabel.text = [[self.yuangong objectAtIndex:indexPath.row] objectForKey:@"Name"];
    cell.positionLabel.text = [[self.yuangong objectAtIndex:indexPath.row] objectForKey:@"Position"];
    cell.photoLabel.text = [[self.yuangong objectAtIndex:indexPath.row] objectForKey:@"Phone"];
    
    cell.dialBtn.tag = indexPath.row;
    [cell.dialBtn addTarget:self action:@selector(dial:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)dial:(UIButton *)sender{
    NSString *phone=  [[self.yuangong objectAtIndex:sender.tag] objectForKey:@"Phone"];
    
    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4) {
    }
}

@end

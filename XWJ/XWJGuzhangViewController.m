//
//  XWJGuzhangViewController.m
//  XWJ
//
//  Created by Sun on 15/12/12.
//  Copyright © 2015年 Paul. All rights reserved.
//

#import "XWJGuzhangViewController.h"
#import "XWJGZmiaoshuViewController.h"
#import "RatingBar/RatingBar.h"
#import "XWJGZTableViewCell.h"
#import "XWJAccount.h"
#import "XWJGZaddViewController.h"
#import "XWJGZJudgeViewController.h"
#define TAG 100
@interface XWJGuzhangViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *guzhangArr;
@end

@implementation XWJGuzhangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createButton];
    // Do any additional setup after loading the view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"gztablecell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (self.type == 1) {
        self.navigationItem.title = @"故障报修";
    }else{
        self.navigationItem.title = @"物业投诉";
    }
    self.guzhangArr = [NSMutableArray array];
//使用mj的刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        [self getGuzhang];
        
    }];

    [self setNavRightItem];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getGuzhang];

    self.tabBarController.tabBar.hidden =YES;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden =NO;
    
}
//设置报修投诉的头标题
-(void)setNavRightItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    
    if (self.type == 1) {
        [btn setTitle:@"报修" forState:UIControlStateNormal];
    }else
        [btn setTitle:@"投诉" forState:UIControlStateNormal];

        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [btn addTarget:self action:@selector(baoxiu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *done= [[UIBarButtonItem  alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = done;
}

-(void)baoxiu{
    
        XWJGuzhangViewController *view =[self.storyboard instantiateViewControllerWithIdentifier:@"guzhangbaoxiu"];
    view.type = self.type;
    [self.navigationController showViewController:view sender:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 30.0;
//}
//- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"物业员工";
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.guzhangArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    XWJGZTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[XWJGZTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    /*
     code = "4-20151220001";
     createtime = "12-20 10:17";
     hfzt = "<null>";
     id = 33;
     leixing = "\U7ef4\U4fee";
     miaoshu = "\U4ed8\U51fa";
     xing = "-1";
     zt = "\U672a\U53d7\U7406";
     */
    cell.timelabel.text = @"提交时间";
    cell.time.text = [NSString stringWithFormat:@"%@",[[self.guzhangArr objectAtIndex:indexPath.row] objectForKey:@"createtime"]];
    cell.contentLabel.text = [NSString stringWithFormat:@"%@",[[self.guzhangArr objectAtIndex:indexPath.row] objectForKey:@"miaoshu"]];
    cell.finishLabel.text = [NSString stringWithFormat:@"%@",[[self.guzhangArr objectAtIndex:indexPath.row] objectForKey:@"zt"]];
    cell.pingjiaBtn.tag = TAG + indexPath.row;
    

    NSString *xing = [NSString stringWithFormat:@"%@",[[self.guzhangArr objectAtIndex:indexPath.row] objectForKey:@"xing"]];
    
    if ([cell.finishLabel.text isEqualToString:@"已关闭"]) {
        if ([xing intValue]!= -1) {
            
            //   if (!cell.pingjiaBtn.hidden) {
            RatingBar * _bar = [[RatingBar alloc] initWithFrame:CGRectMake(SCREEN_SIZE.width-150, 0, 180, 30)];
            _bar.enable = NO;
            _bar.starNumber = [xing intValue];
            [cell.rateView addSubview:_bar];
            cell.pingjiaBtn.hidden = YES;
            //        }
        }else{
            cell.pingjiaBtn.hidden = NO;
            cell.pingjiaBtn.tag = indexPath.row+100;
            [cell.pingjiaBtn addTarget:self action:@selector(pingjia:) forControlEvents:UIControlEventTouchUpInside];
        }
            }else{
                cell.pingjiaBtn.hidden = YES;
    }
    
 
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
 
    return cell;
}

-(void)pingjia:(UIButton *)btn{
    CLog(@"btn %ld",(long)btn.tag);
    
    XWJGZJudgeViewController *jubge = [self.storyboard instantiateViewControllerWithIdentifier:@"gzpingjia"];
    jubge.gzid = [[self.guzhangArr objectAtIndex:btn.tag-100] objectForKey:@"id"];
    jubge.miaoshu = [[self.guzhangArr objectAtIndex:btn.tag-100] objectForKey:@"miaoshu"];
    [self.navigationController pushViewController:jubge animated:YES ];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
        XWJGZmiaoshuViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"guzhangmiaoxu"];
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setValue:@"" forKey:@""];
    detail.type = self.type;
    detail.detaildic  =  [NSMutableDictionary dictionaryWithDictionary:[self.guzhangArr objectAtIndex:indexPath.row]];
        [self.navigationController showViewController: detail sender:self];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
 userid	登录用户id	String
 type	类型（维修、投诉）	String
 */
//下载故障列表
-(void)getGuzhang{
    NSString *url = GETFGUZHANG_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    XWJAccount *account = [XWJAccount instance];
    [dict setValue:account.uid forKey:@"userid"];

    if (self.type==1) {
 
        [dict setValue:@"维修" forKey:@"type"];
    }else
        [dict setValue:@"投诉" forKey:@"type"];

    [dict setValue:[XWJAccount instance].aid forKey:@"a_id"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            
            //            NSMutableArray * array = [NSMutableArray array];
            //            XWJCity *city  = [[XWJCity alloc] init];
            
            NSArray *arr  = [dic objectForKey:@"data"];
            [self.guzhangArr removeAllObjects];
            [self.guzhangArr addObjectsFromArray:arr];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}
//常见投诉报修的提交按钮
-(void)createButton{

    UIButton *button  = [[UIButton alloc]initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width - 40, 40)];
    if (self.type == 1) {
        [button setTitle:@"我要报修" forState:UIControlStateNormal];
    }else
        [button setTitle:@"我要投诉" forState:UIControlStateNormal];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    button.backgroundColor = [UIColor colorWithRed:0.00 green:0.67 blue:0.65 alpha:1.00];
    [button addTarget:self action:@selector(onTousuButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
-(void)onTousuButtonClick{

    [self baoxiu];
}

@end

//
//  XWJZFViewController.m
//  XWJ
//
//  Created by Sun on 15/12/6.
//  Copyright © 2015年 Paul. All rights reserved.
//

#import "XWJZFViewController.h"
#import "XWJZFTableViewCell.h"
#import "XWJdef.h"
#import "XWJZFDetailViewController.h"
#import "XWJMFViewController.h"
#import "XWJCZViewController.h"
#import "XWJNewHouseDetailViewController.h"
#import "XWJCZFDetailViewController.h"
#import "XWJAccount.h"
typedef NS_ENUM(NSUInteger, selecttype) {
    selecttypequyu,
    selecttypezongjia,
    selecttypehuxing,
    selecttypemianji,
};

@interface XWJZFViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    UIView *backview;
    UIScrollView *helperView;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightcontraint;
@property NSMutableArray *houseArr;

@property NSMutableArray *quyu;
@property NSMutableArray *price;
@property NSMutableArray *huxing;
@property NSMutableArray *mianji;

@property NSInteger quyuIndex;
@property NSInteger priceIndex;
@property NSInteger huxingIndex;
@property NSInteger mianjiIndex;

@property selecttype stype;

@property NSMutableArray *zufangquyu;
@property NSMutableArray *zufangprice;
@property NSMutableArray *zufanghuxing;
@property NSMutableArray *zufangfkfs;
@property NSString * searchStr;
@end

@implementation XWJZFViewController{

        NSInteger _currentPage;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    /**
     *  注册所有的
     */
    _currentPage = 0;
    UIControl *controlView = [[UIControl alloc] initWithFrame:self.view.frame];
    [controlView addTarget:self action:@selector(resiginTextFields) forControlEvents:UIControlEventTouchUpInside];
    [self.view.window addSubview:controlView];
    controlView.backgroundColor = [UIColor clearColor];
    

        if (self.type != HOUSENEW) {
    
        NSArray *array ;
        
        if (self.type == HOUSE2) {
            
            array =  [NSArray arrayWithObjects:@"区域",@"总价",@"户型",@"面积", nil];
        }else{
            array =  [NSArray arrayWithObjects:@"区域",@"租金",@"户型",@"方式", nil];
        }
        CGFloat width = [UIScreen mainScreen].bounds.size.width/4;
//            创建区域面积等筛选按钮
        for (int i = 0 ; i<4; i++) {
            
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:[array objectAtIndex:i] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
            [btn setTitleColor:XWJGREENCOLOR forState:UIControlStateNormal];
            btn.frame = CGRectMake(i*width, 0, width, 40);
            btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [btn setImage:[UIImage imageNamed:@"xinfangarrow"] forState:UIControlStateNormal];
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0, btn.bounds.size.width-10, 0, 0)];
            btn.tag = i+1;
            [btn addTarget:self action:@selector(showSortView:) forControlEvents:UIControlEventTouchUpInside];
            [self.selectView addSubview:btn];
        }
    }else{
        
        NSLayoutConstraint *conStr= [NSLayoutConstraint constraintWithItem:_selectView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_selectView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0
                                                                  constant:0];
        
        [_selectView removeConstraint:_heightcontraint];
        [_selectView addConstraint:conStr];
     
     
    }
    
    self.searchbar.delegate = self;
    //是否显示取消按钮
    [self.searchbar setShowsCancelButton:YES animated:YES];
    
    for(id cc in [_searchbar.subviews[0] subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"取消"  forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    
    self.selectView.frame = CGRectZero;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        [self loadData];
        
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        //进入加载状态后会自动调用这个block
        [self loadNextPageDate];
    }];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    NSString *title ;
    switch (self.type) {
        case HOUSENEW:{
            title = @"新房";
//            [self getXinFang:nil];
        }
            break;
        case HOUSE2:{
            title = @"二手房";
//            [self get2handfang:nil];
            [self get2hangFilter];
            [self setRigthNavItem:0];
        }
            break;
        case HOUSEZU:{
            title = @"租房";
//            [self getZFang:nil];
            [self getZufangFilter];
            [self setRigthNavItem:1];
        }
            break;
        default:
            break;
    }
    
    self.houseArr = [NSMutableArray array];
    
    self.navigationItem.title = title;
}

//下载数据
-(void)loadData{
    _currentPage = 0;
    switch (self.type) {
        case HOUSENEW:{
            
            if (self.searchStr&&self.searchStr.length>0) {
                [self getXinFang:self.searchStr];
            }else{
                [self getXinFang:nil];
                [self.tableView.mj_header endRefreshing];
            }
        }
            break;
        case HOUSE2:{
            
            if (self.searchStr&&self.searchStr.length>0) {
                [self get2handfang:self.searchStr];
            }else{
                [self get2handfang:nil];
            [self.tableView.mj_header endRefreshing];
            }
        }
            break;
        case HOUSEZU:{
            if (self.searchStr&&self.searchStr.length>0) {
                [self getZFang:self.searchStr];
            }else{
                [self getZFang:nil];
            [self.tableView.mj_header endRefreshing];
            }
        }
            break;
        default:
            break;
    }
}
-(void)loadNextPageDate{
    _currentPage ++;
    NSString *str = [NSString stringWithFormat:@"%ld",_currentPage];
    switch (self.type) {
        case HOUSENEW:{
            
            if (self.searchStr&&self.searchStr.length>0) {
                [self getXinFang:self.searchStr WithType:nil];
            }else{
                [self getXinFang:nil WithType:str];
                [self.tableView.mj_footer endRefreshing];
            }
        }
            break;
        case HOUSE2:{
            
            if (self.searchStr&&self.searchStr.length>0) {
                [self get2handfang:self.searchStr];
                
            }else
                [self get2handfang:nil WithType:str];
            [self.tableView.mj_footer endRefreshing];
            
        }
            break;
        case HOUSEZU:{
            if (self.searchStr&&self.searchStr.length>0) {
                [self getZFang:self.searchStr];
            }else
                [self getZFang:nil WithType:str];
            [self.tableView.mj_footer endRefreshing];
        }
            break;
        default:
            break;
    }

    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self loadData];
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchbar resignFirstResponder];
    self.searchbar.text = @"";
    self.searchStr = @"";
    CLog(@"");
}// called when cancel button pressed


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.searchbar resignFirstResponder];
    return YES;
}

-(void)resiginTextFields
{
    CLog(@"resigne  tf");
    [self.searchbar resignFirstResponder];
}

-(void)showSortView:(UIButton *)btn{
    //添加半透明背景图
    NSUInteger type = btn.tag;
    self.stype = btn.tag-1;
    backview=[[UIView alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.window.frame.size.height)];
    backview.backgroundColor=[UIColor colorWithWhite:0 alpha:0.6];
    backview.tag=4444;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonClicked)];
    backview.userInteractionEnabled = YES;
    [backview addGestureRecognizer:tap];
    [self.view.window addSubview:backview];
    
    //添加helper视图
    float kHelperOrign_X=30;
    float kHelperOrign_Y=(self.view.frame.size.height-300)/2+64;
    helperView=[[UIScrollView alloc]initWithFrame:CGRectMake(kHelperOrign_X, kHelperOrign_Y,self.view.frame.size.width-2*kHelperOrign_X, 300)];
    helperView.backgroundColor=[UIColor whiteColor];
    helperView.layer.cornerRadius=5;
    helperView.tag=1002;
    helperView.clipsToBounds=YES;

    [backview addSubview:helperView];
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 200, 40)];
    titleLabel.textColor=[UIColor colorWithRed:95.0/255.0 green:170.0/255.0 blue:249.0/255.0 alpha:1];
    titleLabel.font=[UIFont boldSystemFontOfSize:17];
    [helperView addSubview:titleLabel];
    UILabel *line=[[UILabel alloc]initWithFrame:CGRectMake(0, 40, helperView.frame.size.width, 2)];
    line.backgroundColor=[UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1];
    [helperView addSubview:line];
    
    NSMutableArray *array = [NSMutableArray array];
    NSInteger  count = 0  ;
    switch (type) {
        case 1:{
            count = self.quyu.count;
            [array addObjectsFromArray:self.quyu];
         }
            break;
         case 2:{
             count = self.price.count;
             [array addObjectsFromArray:self.price];
        }
          break;
          case 3:{
              count = self.huxing.count;
              [array addObjectsFromArray:self.huxing];
        }
          break;
          case 4:{
              count = self.mianji.count;
              [array addObjectsFromArray:self.mianji];
        }
          break;
        default:
            break;
    }
    for (int i=0; i<count; i++) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(0, 40+40*i, helperView.frame.size.width, 40);
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 200, 40)];
        label.text= [[array objectAtIndex:i] valueForKey:@"dicValue"];
        label.tag = 100;
        [button addSubview:label];
      
        UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(button.frame.size.width-20-10, 10, 20, 20)];
//       imageView.image=[UIImage imageNamed:@"tcpUnselect"];
//        if (sortSelected==i) {
//            imageView.image=[UIImage imageNamed:@"tcpSelect"];
//        }
        imageView.tag=7001;
        [button addSubview:imageView];
      
        UILabel *line=[[UILabel alloc]initWithFrame:CGRectMake(0, 40-1, helperView.frame.size.width, 1)];
        line.backgroundColor=[UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1];
        [button addTarget:self action:@selector(sortTypeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag=60001+i;
        [button addSubview:line];
      
        [helperView addSubview:button];
    }
    
    UIButton *closeButton=[UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame=CGRectMake(self.view.window.frame.size.width-kHelperOrign_X-32/2, kHelperOrign_Y-32/2, 32, 32);
    [backview addSubview:closeButton];
    float space=(helperView.bounds.size.width-40-120);
    for (NSUInteger i=0; i<count; i++) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(20+(space+60)*i, helperView.bounds.size.height-10-30, 60, 30);
        button.tag=50001+i;
        [button addTarget:self action:@selector(confirmbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [helperView addSubview:button];
    }
    helperView.contentSize = CGSizeMake(0, 40*(count+1));

}

-(void)getfangInfo{
    if (self.type == HOUSE2) {
        [self get2handfang:@""];
    }else if (self.type == HOUSEZU){
        [self getZFang:@""];
    }
}

-(void)sortTypeButtonClicked:(UIButton *)button{
    
    [self closeButtonClicked];

    NSInteger index = button.tag - 60001;
    CLog(@"selcet id %ld",index);
    
    UIButton *btn = [self.selectView viewWithTag:self.stype+1];
    UILabel *label = [button viewWithTag:100];
    [btn setTitle:label.text forState:UIControlStateNormal];

    CLog(@"button.titleLabel.text %@",button.titleLabel.text);
    switch (self.stype) {
        case selecttypehuxing:
        {
            self.huxingIndex = index;
//            [self get2handfang:@""];
            [self getfangInfo];
        }
            break;
        case selecttypemianji:{
            self.mianjiIndex = index;
//            [self get2handfang:@""];
            [self getfangInfo];

        }
            break;
        case selecttypequyu:{
            self.quyuIndex = index;
//        [self get2handfang:@""];
            [self getfangInfo];

        }
            break;
        case selecttypezongjia:{
            self.priceIndex = index;
//            [self get2handfang:@""];
            [self getfangInfo];
        }
            break;
        default:
            break;
    }

}

-(void)confirmbuttonClick:(UIButton *)button{
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
 
        if (button.tag==50001) {

        }else{
 
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
}

-(void)closeButtonClicked{
    //    UIView *backview=[self.view.window viewWithTag:3333];
    [backview removeFromSuperview];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self doSearch:searchBar];
}

-(void)doSearch:(UISearchBar *)ser{
    
    
    self.searchStr = ser.text;
    switch (self.type) {
        case HOUSENEW:{
            [self getXinFang:ser.text WithType:nil];
        }
            break;
        case HOUSE2:{
            [self get2handfang:ser.text];
            
        }
            break;
        case HOUSEZU:{
            [self getZFang:ser.text];
        }
            break;
        default:
            break;
    }
}

//获取二手房是信息列表
-(void)get2hangFilter{
    NSString *url = GET2HANDDFILTER_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            
            //            NSMutableArray * array = [NSMutableArray array];
            //            XWJCity *city  = [[XWJCity alloc] init];
            
            NSDictionary *quanbu  = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"dicKey",@"全部",@"dicValue", nil];
            
            
            self.quyu  = [NSMutableArray arrayWithArray:[dic objectForKey:@"district"]];
            self.price  = [NSMutableArray arrayWithArray:[dic objectForKey:@"price"]];
            self.mianji  = [NSMutableArray arrayWithArray:[dic objectForKey:@"square"]];
            self.huxing  = [NSMutableArray arrayWithArray:[dic objectForKey:@"style"]];
            [self.quyu insertObject:quanbu atIndex:0];
            [self.price insertObject:quanbu atIndex:0];
            [self.mianji insertObject:quanbu atIndex:0];
            [self.huxing insertObject:quanbu atIndex:0];
            CLog(@"dic %@",dic);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}
//获取租房信息列表
-(void)getZufangFilter{
    NSString *url = GETCHUZUFILTER_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            
            NSDictionary *quanbu  = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"dicKey",@"全部",@"dicValue", nil];
            self.quyu  = [NSMutableArray arrayWithArray:[dic objectForKey:@"area"]];
            self.price  = [NSMutableArray arrayWithArray:[dic objectForKey:@"zujin"]];
            self.mianji  = [NSMutableArray arrayWithArray:[dic objectForKey:@"fkfs"]];
            self.huxing  = [NSMutableArray arrayWithArray:[dic objectForKey:@"hx"]];
            [self.quyu insertObject:quanbu atIndex:0];
            [self.price insertObject:quanbu atIndex:0];
            [self.mianji insertObject:quanbu atIndex:0];
            [self.huxing insertObject:quanbu atIndex:0];
            
            CLog(@"dic %@",dic);
        }
        
    
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}

//获取二手房列表信息
-(void)get2handfang:(NSString *)tex{
    NSString *url = GET2HAND_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (tex) {
        [dict setValue:tex forKey:@"buildingInfo"];
    }
    
    if (self.quyuIndex==0) {
        
    }else
        [dict setValue:[[self.quyu objectAtIndex:self.quyuIndex] objectForKey:@"dicValue"] forKey:@"district"];
    [dict setValue:[[self.price objectAtIndex:self.priceIndex] objectForKey:@"dicKey"]  forKey:@"price"];
    [dict setValue:[[self.mianji objectAtIndex:self.mianjiIndex] objectForKey:@"dicKey"] forKey:@"square"];
    [dict setValue:[[self.huxing objectAtIndex:self.huxingIndex] objectForKey:@"dicKey"] forKey:@"style"];
    [dict setValue:@"0" forKey:@"pageindex"];
    [dict setValue:@"10"  forKey:@"countperpage"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            
            //            NSMutableArray * array = [NSMutableArray array];
            //            XWJCity *city  = [[XWJCity alloc] init];
            
            NSArray *arr  = [dic objectForKey:@"data"];
            [self.houseArr removeAllObjects];
            [self.houseArr addObjectsFromArray:arr];
            [self.tableView reloadData];
            CLog(@"dic %@",dic);
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
    }];
}
//上拉加载二手房列表信息
-(void)get2handfang:(NSString *)tex WithType:(NSString *)str{
    NSString *url = GET2HAND_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (tex) {
        [dict setValue:tex forKey:@"buildingInfo"];
    }
    
    if (self.quyuIndex==0) {
        
    }else
        [dict setValue:[[self.quyu objectAtIndex:self.quyuIndex] objectForKey:@"dicValue"] forKey:@"district"];
    [dict setValue:[[self.price objectAtIndex:self.priceIndex] objectForKey:@"dicKey"]  forKey:@"price"];
    [dict setValue:[[self.mianji objectAtIndex:self.mianjiIndex] objectForKey:@"dicKey"] forKey:@"square"];
    [dict setValue:[[self.huxing objectAtIndex:self.huxingIndex] objectForKey:@"dicKey"] forKey:@"style"];
    [dict setValue:str forKey:@"pageindex"];
    [dict setValue:@"10"  forKey:@"countperpage"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {

        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            
            //            NSMutableArray * array = [NSMutableArray array];
            //            XWJCity *city  = [[XWJCity alloc] init];
            
            NSArray *arr  = [dic objectForKey:@"data"];
            [self.houseArr addObjectsFromArray:arr];
            [self.tableView reloadData];
            CLog(@"dic %@",dic);
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}
//获取租房信息列表
-(void)getZFang:(NSString *)area{
    NSString *url = GETCHUZU_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (area) {
        [dict setValue:area  forKey:@"buildingInfo"];
    }
    
    [dict setValue:[[self.quyu objectAtIndex:self.quyuIndex] objectForKey:@"dicKey"] forKey:@"area"];
    [dict setValue:[[self.price objectAtIndex:self.priceIndex] objectForKey:@"dicKey"]  forKey:@"zujin"];
    [dict setValue:[[self.mianji objectAtIndex:self.mianjiIndex] objectForKey:@"dicKey"] forKey:@"fkfs"];
    [dict setValue:[[self.huxing objectAtIndex:self.huxingIndex] objectForKey:@"dicKey"] forKey:@"hx"];
    [dict setValue:@"0" forKey:@"pageindex"];
    [dict setValue:@"10"  forKey:@"countperpage"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            
            //            NSMutableArray * array = [NSMutableArray array];
            //            XWJCity *city  = [[XWJCity alloc] init];
            
            NSArray *arr  = [dic objectForKey:@"data"];
            [self.houseArr removeAllObjects];
            [self.houseArr addObjectsFromArray:arr];
            [self.tableView reloadData];
            CLog(@"dic %@",dic);
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}
//加载租房信息列表
-(void)getZFang:(NSString *)area WithType:(NSString *)str{
    NSString *url = GETCHUZU_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (area) {
        [dict setValue:area  forKey:@"buildingInfo"];
    }
    
    [dict setValue:[[self.quyu objectAtIndex:self.quyuIndex] objectForKey:@"dicKey"] forKey:@"area"];  
    [dict setValue:[[self.price objectAtIndex:self.priceIndex] objectForKey:@"dicKey"]  forKey:@"zujin"];
    [dict setValue:[[self.mianji objectAtIndex:self.mianjiIndex] objectForKey:@"dicKey"] forKey:@"fkfs"];
    [dict setValue:[[self.huxing objectAtIndex:self.huxingIndex] objectForKey:@"dicKey"] forKey:@"hx"];
    [dict setValue:str forKey:@"pageindex"];
    [dict setValue:@"10"  forKey:@"countperpage"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            
            //            NSMutableArray * array = [NSMutableArray array];
            //            XWJCity *city  = [[XWJCity alloc] init];
            
            NSArray *arr  = [dic objectForKey:@"data"];
            [self.houseArr addObjectsFromArray:arr];
            [self.tableView reloadData];
            CLog(@"dic %@",dic);
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}
//获取新房的信息列表
-(void)getXinFang:(NSString *)area {
    NSString *url = GETXINFANG_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (area) {
        [dict setValue:area  forKey:@"area"];
    }
 
    [dict setValue:[XWJAccount instance].aid forKey:@"a_id"];

//    [dict setValue:@"1" forKey:@"a_id"];
    [dict setValue:@"0" forKey:@"pageindex"];
    [dict setValue:@"10"  forKey:@"countperpage"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            
            //            NSMutableArray * array = [NSMutableArray array];
            //            XWJCity *city  = [[XWJCity alloc] init];
            
            NSArray *arr  = [dic objectForKey:@"data"];
            [self.houseArr removeAllObjects];
            [self.houseArr addObjectsFromArray:arr];
            CLog(@"dic打印 %@",dic);
           
            [self.tableView reloadData];
            
            CLog(@"dic %@",dic);
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}
//加载新房下一页信息列表
-(void)getXinFang:(NSString *)area WithType:(NSString *)str{
    NSString *url = GETXINFANG_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (area) {
        [dict setValue:area  forKey:@"area"];
    }
    
    [dict setValue:[XWJAccount instance].aid forKey:@"a_id"];
    
    //    [dict setValue:@"1" forKey:@"a_id"];
    [dict setValue:str forKey:@"pageindex"];
    [dict setValue:@"10"  forKey:@"countperpage"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {

        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dic = (NSDictionary *)responseObject;
            
            //            NSMutableArray * array = [NSMutableArray array];
            //            XWJCity *city  = [[XWJCity alloc] init];
            
            NSArray *arr  = [dic objectForKey:@"data"];
            [self.houseArr addObjectsFromArray:arr];
            
            [self.tableView reloadData];
            
            CLog(@"dic %@",dic);
        }
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}

//设置正确的头标题
-(void)setRigthNavItem:(int)d{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 100, 40);
    NSArray *array = [NSArray arrayWithObjects:@"我要卖房",@"我要出租", nil];
    [btn setTitle:[array objectAtIndex:d] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [btn addTarget:self action:@selector(woyao) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *done= [[UIBarButtonItem  alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = done;
}

//个人租房卖房的发布按钮
-(void)woyao{
    switch (self.type) {
        case HOUSE2:{
            XWJMFViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"sell2house"];
            [self.navigationController showViewController:view sender:nil];
        }
            break;
        case HOUSEZU:{
            XWJCZViewController  *view = [self.storyboard instantiateViewControllerWithIdentifier:@"mychuzu"];
            [self.navigationController showViewController:view sender:nil];

        }
            break;
        default:
            break;
    }
}

-(void)click:(UIButton *)btn{
  //  CLog(@"click");
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
    return 140;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.houseArr.count;
//    return 10;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XWJZFTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"zftablecell"];
    if (!cell) {
        cell = [[XWJZFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"zftablecell"];
    }
    // Configure the cell...
//    cell.headImageView.image = [UIImage imageNamed:@"xinfangbackImg"];
//    cell.label1.text = @"海信湖岛世家";
//    cell.label2.text = @"3室2厅2卫 110平米";
//    cell.label3.text = @"青岛市四方区";
//    cell.label4.text = @"150万元";
    
    switch (self.type) {
        case HOUSENEW:{
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"xzst"]] placeholderImage:[UIImage imageNamed:@"demo"]];
            
            NSString * qu = [NSString stringWithFormat:@"%@%@",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"cityName"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"cityName"],[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"quyu"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"quyu"]];
            NSString*money = [NSString stringWithFormat:@"%@元/平米",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"jiage"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"jiage"]];
            
            cell.label1.text = [NSString stringWithFormat:@"%@",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"lpmc"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"lpmc"]];
            cell.label2.text = qu;
            cell.label3.text = [NSString stringWithFormat:@"%@",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"zt"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"zt"]];
            cell.label4.text = money;
        }
            break;
        case HOUSE2:{
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"demo"]];
            
            NSString * qu = [NSString stringWithFormat:@"%@%@",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"city"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"city"],[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"area"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"area"]];
            
            NSString * shi = [NSString stringWithFormat:@"%@室%@厅%@卫 %@平米",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"house_Indoor"],[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"house_living"],[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"house_Toilet"],[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"buildingArea"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"buildingArea"]];

            NSString *money = [NSString stringWithFormat:@"%@万元",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"rent"]==[NSNull null]?@"0":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"rent"]];
            
            cell.label1.text = [NSString stringWithFormat:@"%@",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"buildingInfo"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"buildingInfo"]];
            cell.label2.text = shi;
            cell.label3.text = qu;
            cell.label4.text = money;
        }
            break;
        case HOUSEZU:{
            
            /*
             area = "\U56db\U65b9\U533a";
             buildingArea = "98.12";
             buildingInfo = "\U6e56\U5c9b\U4e16\U5bb6";
             "house_Indoor" = 2;
             "house_Toilet" = 1;
             "house_living" = 1;
             id = 2;
             photo = "http://www.hisenseplus.com/HisenseUpload/loupan/20151213155016248.jpg";
             rent = 2300;
             */
            [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"photo"]] placeholderImage:[UIImage imageNamed:@"demo"]];
            
            NSString * shi = [NSString stringWithFormat:@"%@室%@厅%@卫 %@m²",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"house_Indoor"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"house_Indoor"],[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"house_living"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"house_living"],[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"house_Toilet"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"house_Toilet"],[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"buildingArea"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"buildingArea"]];
            NSString *money = [NSString stringWithFormat:@"%@元/月",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"rent"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"rent"]];

            
            cell.label1.text = [NSString stringWithFormat:@"%@",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"buildingInfo"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"buildingInfo"]];
            cell.label2.text = shi;
             NSString * qu = [NSString stringWithFormat:@"%@",[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"area"]==[NSNull null]?@"":[[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"area"]];
            cell.label3.text = qu;
//            cell.label3.text = [[self.houseArr objectAtIndex:indexPath.row] objectForKey:@"buildingArea"];
            cell.label4.text = money;
        }
            break;
    }

    

    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.type == HOUSE2) {
        XWJZFDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"2fdatail"];
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setValue:@"" forKey:@""];
        detail.dic = [self.houseArr objectAtIndex:indexPath.row];
        detail.type = self.type;
        [self.navigationController showViewController: detail sender:self];
    }else if (self.type==HOUSEZU){
        XWJCZFDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"czfdatail"];
        //        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        //        [dic setValue:@"" forKey:@""];
        detail.dic = [self.houseArr objectAtIndex:indexPath.row];
        detail.type = self.type;
        [self.navigationController showViewController: detail sender:self];
    }
    else{
        
        XWJNewHouseDetailViewController *detail = [self.storyboard instantiateViewControllerWithIdentifier:@"newhousedetail2"];
        detail.dic = [self.houseArr objectAtIndex:indexPath.row];
        [self.navigationController showViewController:detail sender:self];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

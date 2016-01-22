//
//  XWJMyHouseController.m
//  XWJ
//
//  Created by Sun on 15/11/29.
//  Copyright © 2015年 Paul. All rights reserved.
//

#import "XWJMyHouseController.h"
#import "XWJdef.h"
#import "XWJAccount.h"
#import "XWJBindHouseOneViewController.h"
#import "XWJXuanZeViewController.h"
#import "XWJBindHouseTableViewController.h"
#import "XWJCity.h"
#import "XWJAboutViewController.h"
#import "XWJMyHouseCell.h"

@interface XWJMyHouseController()<XWJBindHouseDelegate,UITableViewDataSource,UITableViewDelegate>{
}

@property UITableView *tableView;
@property NSMutableArray *titles;
@property NSMutableArray *subTitles;
@property NSMutableArray *danyuan;
@property NSMutableArray *louhao;
@property NSMutableArray *JURID;
@property NSMutableArray *isDefault;
@property NSString *guanjiaM;

@end
@implementation XWJMyHouseController

static NSString *kcellIdentifier = @"cell";

-(void)viewDidLoad{
    [super viewDidLoad];
    [self downLoadData];
    self.navigationItem.title = @"我的房产";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    _titles =[[NSMutableArray alloc]init];
    _subTitles =[[NSMutableArray alloc]init];
    _danyuan =[[NSMutableArray alloc]init];
    _louhao =[[NSMutableArray alloc]init];
    _JURID =[[NSMutableArray alloc]init];
    _isDefault =[[NSMutableArray alloc]init];
    _guanjiaM = [[NSString alloc]init];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, 50)];
    view.backgroundColor = XWJColor(235, 235, 234);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"bindfy"];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setTitle:@"继续绑定房源" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 200, image.size.height);
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [btn addTarget:self action:@selector(bind) forControlEvents:UIControlEventTouchUpInside];
    btn.center = view.center;
    [view addSubview:btn];
    _tableView.tableHeaderView = view;
    
    [_tableView registerNib:[UINib nibWithNibName:@"XWJMyhouseTableCell" bundle:nil] forCellReuseIdentifier:kcellIdentifier];
    [self.view addSubview:_tableView];
}


-(void)bind{
    
    XWJBindHouseTableViewController *bind = [[XWJBindHouseTableViewController alloc] init];
    bind.title = @"城市选择";

    bind.delegate = self;
    bind->mode = HouseCity;
    [self.navigationController showViewController:bind sender:nil];

}
#pragma bindhouse delegate
-(void)didSelectAtIndex:(NSInteger)index Type:(HouseMode)type{
    XWJCity *city = [XWJCity instance];
    switch (type) {
        case HouseCity:{
            
            [city selectCity:index];
            XWJBindHouseTableViewController *bind = [[XWJBindHouseTableViewController alloc] init];
            bind.title = @"小区选择";
            //            bind.dataSource = [NSArray arrayWithObjects:@"湖岛世家",@"花瓣里",@"依云小镇",@"湖岛世家",@"花瓣里",@"依云小镇",@"湖岛世家",@"花瓣里",@"依云小镇",@"湖岛世家",@"花瓣里",@"依云小镇", nil];
            //            bind.dataSource = arr2;
            bind.delegate = self;
            bind->mode = HouseCommunity;
            
            [self.navigationController showViewController:bind sender:nil];
            
            //            [city getDistrct:^(NSArray *arr) {
            //                NSLog(@"district  %@",arr);
            //                NSMutableArray *arr2 = [NSMutableArray array];
            //
            //                for (NSDictionary *dic in arr) {
            //                    [arr2 addObject:[dic valueForKey:@"a_name"]];
            //                }
            //
            //            }];
            
            
        }
            break;
        case HouseCommunity:{
            
            [city selectDistrict:index];
            
            XWJBindHouseTableViewController *bind = [[XWJBindHouseTableViewController alloc] init];
            bind.title = @"楼座选择";
            //            bind.dataSource = [NSArray arrayWithObjects:@"一号楼",@"二号楼",@"三号楼", @"四号楼",@"五号楼",@"六号楼", @"七号楼",@"八号楼",@"九号楼", @"十号楼",@"十一号楼",@"十二号楼", nil];
            bind.delegate = self;
            bind->mode = HouseFlour;
            [self.navigationController showViewController:bind sender:nil];
        }
            break;
        case HouseFlour:{
            
            [city selectBuilding:index];
            
            XWJBindHouseTableViewController *bind = [[XWJBindHouseTableViewController alloc] init];
            bind.title = @"房间选择";
            //            bind.dataSource = [NSArray arrayWithObjects:@"01单元001",@"01单元002",@"01单元003", @"01单元004",@"01单元005",@"01单元006",@"01单元007",@"01单元008",@"01单元009",@"01单元010",@"01单元011",@"01单元012",nil];
            bind.delegate = self;
            bind->mode = HouseRoomNumber;
            [self.navigationController showViewController:bind sender:nil];
        }
            break;
        case HouseRoomNumber:{
            
            [city selectRoom:index];
            
            //            self.tabBarController.tabBar.hidden = NO;
            
            //            XWJTabViewController *tab = [[XWJTabViewController alloc] init];
            //            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            //            window.rootViewController = tab;
            
            //                        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //                        [UIApplication sharedApplication].keyWindow.rootViewController = [story instantiateInitialViewController];
            //                XWJBingHouseViewController *bind = [[XWJBingHouseViewController alloc] initWithNibName:@"XWJBingHouseViewController" bundle:nil];
            
            //            self.isBind = TRUE;
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"XWJLoginStoryboard" bundle:nil];
            [self.navigationController showViewController:[story instantiateViewControllerWithIdentifier:@"bindhouse1"] sender:nil];
            
        }
            break;
        default:
            break;
    }
}


-(void)downLoadData{
    NSString *houseUrl = @"http://www.hisenseplus.com:8100/appPhone/rest/build/myRooms";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    XWJAccount *account = [XWJAccount instance];
    [dict setValue:account.uid forKey:@"userid"];
    [manager POST:houseUrl parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        if(responseObject){
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSArray *array  =[[NSArray alloc]init];
            array = [dict objectForKey:@"data"];
            for (NSMutableDictionary *d in array) {
                [_subTitles addObject:[d objectForKey:@"B_name"]];
                [_titles addObject:[d objectForKey:@"A_name"]];
                [_danyuan addObject:[d objectForKey:@"R_dy"]];
                [_louhao addObject:[d objectForKey:@"R_id"]];
                [_JURID addObject:[d objectForKey:@"JU_RID"]];
                [_isDefault addObject:[d objectForKey:@"isDefault"]];
                NSLog(@"%@",_isDefault);

            }
        }

        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65.0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    UITableViewCell *cell;
    //    cell = [_tableView dequeueReusableCellWithIdentifier:kcellIdentifier forIndexPath:indexPath];
    XWJMyHouseCell *cell = [XWJMyHouseCell xwjMyHouseCellInitWithTableView:tableView];
    //    UILabel *title = (UILabel *)[cell viewWithTag:1];
    //    UILabel *subtitle = (UILabel *)[cell viewWithTag:2];
    //
    //    title.text = [_titles objectAtIndex:indexPath.row];
    //    subtitle.text = [NSString stringWithFormat:@"%@%@单元%@",[_subTitles objectAtIndex:indexPath.row],[_danyuan objectAtIndex:indexPath.row],[_louhao objectAtIndex:indexPath.row]];
    //
    //    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.titleLabel.text = [_titles objectAtIndex:indexPath.row];
    cell.DetailLabel.text =[NSString stringWithFormat:@"%@%@单元%@",[_subTitles objectAtIndex:indexPath.row],[_danyuan objectAtIndex:indexPath.row],[_louhao objectAtIndex:indexPath.row]];
    NSLog(@"_isDefault:%@",_isDefault);
    NSString *str= [NSString stringWithFormat:@"%@",_isDefault[indexPath.row]];
    if ([str isEqualToString:@"1"]) {
        cell.imageview.hidden = NO;
    }else{
        cell.imageview.hidden = YES;
    }
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *array = [tableView visibleCells];
    for (XWJMyHouseCell *cell in array) {
        if (cell.selected == YES) {
            cell.imageview.hidden = NO;
        }else{
            cell.imageview.hidden = YES;
        }
    }
    XWJMyHouseCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    //    UIImageView *image = cell.imageView;
    cell.imageview.hidden = NO;
    
    //向服务器发送数据请求把房产信息传到服务器
    NSString *changeUrl = @"http://www.hisenseplus.com:8100/appPhone/rest/build/changeDefault";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    NSMutableDictionary *housedict = [NSMutableDictionary dictionary];
    
    XWJAccount *account = [XWJAccount instance];
    [housedict setValue:account.uid forKey:@"userid"];
    [housedict setValue:self.JURID[indexPath.row] forKey:@"JU_RID"];
    //    NSLog(@"哈哈哈%@",self.JURID[indexPath.row]);
    [manager POST:changeUrl parameters:housedict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",responseObject);
        if(responseObject){
            
        }
      //  [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s fail %@",__FUNCTION__,error);
        
    }];

   


}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{

//    _guanjiaM = [NSString stringWithFormat:@"%@%@%@单元%@",[_titles objectAtIndex:indexPath.row],[_subTitles objectAtIndex:indexPath.row],[_danyuan objectAtIndex:indexPath.row],[_louhao objectAtIndex:indexPath.row]];
//
//    NSLog(@"++++%@",self.JURID[indexPath.row]);
//    //发送通知
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    [dict setObject:_guanjiaM forKey:@"room"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeRoomNotification" object:nil userInfo:dict];
//
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    //    self.scrollView.contentSize = CGSizeMake(0, SCREEN_SIZE.width+60);
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
    
}
-(void)viewDidAppear:(BOOL)animated
{
//    NSInteger selectedIndex = 0;
//    
//    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
//    
//    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//    
//    [super viewDidAppear:animated];
}

@end

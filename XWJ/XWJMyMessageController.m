//
//  XWJMyMessageController.m
//  XWJ
//
//  Created by Sun on 15/11/29.
//  Copyright © 2015年 Paul. All rights reserved.
//

#import "XWJMyMessageController.h"
#import "XWJAccount.h"
#import "XWJFindDetailViewController.h"
#import "XWJFindDetailTableViewCell.h"
#import "qingganViewController.h"

@interface XWJMyMessageController()<UITableViewDataSource,UITableViewDelegate>

@property UITableView *tableView;
@property NSMutableArray *titles;
@property NSMutableArray *subTitles;
@property NSMutableArray *msgArr;
@property NSMutableArray *sendTime;
@property NSMutableArray *finddetailArr;
@property NSMutableDictionary *dic;
@property NSMutableArray *idArray;


@end


@implementation XWJMyMessageController

static NSString *kcellIdentifier = @"cell";

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"我的消息";
    [self downLoadData];
    self.titles = [[NSMutableArray alloc]init];
    self.sendTime = [[NSMutableArray alloc]init];
    self.subTitles = [[NSMutableArray alloc]init];
    self.msgArr = [[NSMutableArray alloc]init];
    self.idArray = [[NSMutableArray alloc]init];
//    _msgArr = [NSMutableArray arrayWithObjects:@"mymsg1",@"mymsg2",@"mymsg3",@"mymsg1",@"mymsg2",@"mymsg3",@"mymsg1",@"mymsg2",@"mymsg3",@"mymsg1",@"mymsg2",@"mymsg3", nil];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        
        [self downLoadData];
        
    }];
    
    [self.view addSubview:_tableView];
}

-(void)downLoadData{
    NSString *messageUrl = @"http://www.hisenseplus.com:8100/appPhone/rest/user/myMsg";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    XWJAccount *account = [XWJAccount instance];
    [dict setValue:account.aid  forKey:@"a_id"];
    [dict setValue:@"0"  forKey:@"pageindex"];
    [dict setValue:@"8"  forKey:@"countperpage"];
    [dict setValue:account.uid forKey:@"userid"];
    [manager POST:messageUrl parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if(responseObject){
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSArray *array  =[[NSArray alloc]init];
            array = [dict objectForKey:@"data"];
//           NSLog(@"dic++++++ %@",array);
            for (NSMutableDictionary *d in array) {
                [_subTitles addObject:[d objectForKey:@"title"]];
                //                [_msgArr addObject:[d objectForKey:@"msg"]];
                [_msgArr addObject:@"mymsg2"];
                [_sendTime addObject:[d objectForKey:@"sendTime"]];
                [_titles addObject:@"有人评论了你的帖子"];
                [_idArray addObject:[d objectForKey:@"id"]];
                
               NSLog(@"dic++++++ %@",_idArray);
            }
        }
        
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}

-(void)downLoadFindData{
    NSString *messageUrl = @"http://www.hisenseplus.com:8100/appPhone/rest/find/findDetail";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    XWJAccount *account = [XWJAccount instance];
    [dict setValue:_idArray  forKey:@"id"];
    [dict setValue:account.uid forKey:@"userid"];
    [manager POST:messageUrl parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"dic***** %@",responseObject);
        
        if(responseObject){
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSDictionary *dicc =[[NSDictionary alloc]init];
            dicc = [dict objectForKey:@"data"];
            self.dic = [dicc objectForKey:@"find"];
            NSLog(@"dic*****%@",self.dic);
            
            UIStoryboard *find = [UIStoryboard storyboardWithName:@"FindStoryboard" bundle:nil];
            XWJFindDetailViewController * con = [find instantiateViewControllerWithIdentifier:@"findDetail"];
            //      con.finddetail = self.finddetailArr;
            //       con.dic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*) [self.finddetailArr objectAtIndex:indexPath.section*COLLECTION_NUMITEMS +indexPath.row]];
            con.dic = _dic;
            NSLog(@"****%@",con.dic);
            [self.navigationController showViewController:con sender:nil];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
  //  self.tabBarController.tabBar.hidden =YES;
    [self downLoadData];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@""];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    }
    cell.textLabel.text = [_titles objectAtIndex:indexPath.row];
    cell.textLabel.textColor = XWJColor(27, 28, 29);
    cell.detailTextLabel.text = [_subTitles objectAtIndex:indexPath.row];
    cell.detailTextLabel.numberOfLines = 3;
    cell.detailTextLabel.textColor = XWJColor(200, 200, 200);
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    cell.imageView.image = [UIImage imageNamed:[_msgArr objectAtIndex:indexPath.row]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.size.width-120, 20, 120, 30)];
    label.textColor = XWJColor(200, 200, 200);
    label.text = [_sendTime objectAtIndex:indexPath.row];
    [cell.contentView addSubview:label];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self downLoadFindData];
    
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{

}
@end

//
//  XWJZFDetailViewController.m
//  XWJ
//
//  Created by Sun on 15/12/9.
//  Copyright © 2015年 Paul. All rights reserved.
//

#import "XWJCZFDetailViewController.h"
#import "LCBannerView.h"
#import "XWJAccount.h"
#import "XWJWebViewController.h"
#define  CELL_HEIGHT 30.0
#define  COLLECTION_NUMSECTIONS 2
#define  COLLECTION_NUMITEMS 5
@interface XWJCZFDetailViewController ()<LCBannerViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>{
    CGFloat collectionCellHeight;
    CGFloat collectionCellWidth;
}
@property (strong, nonatomic) IBOutlet UIScrollView *backScroll;

@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *zhuangxiuLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *loucengLabel;
@property (weak, nonatomic) IBOutlet UILabel *shoufuLabel;
@property (weak, nonatomic) IBOutlet UILabel *niandaiLabel;
@property (weak, nonatomic) IBOutlet UILabel *yuegongLabel;
@property (weak, nonatomic) IBOutlet UILabel *fukuanLabel;
@property (weak, nonatomic) IBOutlet UIImageView *yaoshiView;
@property (weak, nonatomic) IBOutlet UIImageView *xuequView;
@property (weak, nonatomic) IBOutlet UILabel *miaosLabel;

@property (weak, nonatomic) IBOutlet UIButton *dialBtn;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionIView;
@property (weak, nonatomic) IBOutlet UIView *teseView;
@property (nonatomic) NSArray *collectionData;
@property (weak, nonatomic) IBOutlet UILabel *yueduLabel;
@property (weak, nonatomic) IBOutlet UILabel *chaoxiangLabel;
@property (weak, nonatomic) IBOutlet UIButton *shoucangBtn;
@property (weak, nonatomic) IBOutlet UILabel *liulanLabel;
@property NSMutableDictionary * datailDic;
@property NSArray *URLs;
@end

@implementation XWJCZFDetailViewController
static NSString *kcellIdentifier = @"collectionCellID";
static NSString *kheaderIdentifier = @"headerIdentifier";
@synthesize  URLs;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    //    UIScrollView *scrolView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, SCREEN_SIZE.height)];
    //    scrolView.contentSize = CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.height+300);
    //    [self.view  insertSubview:scrolView belowSubview:self.adView];
    
    
    if (self.type == HOUSEZU) {
        self.teseView.hidden = YES;
        self.collectionIView.hidden = NO;
//        self.collectionData = [NSArray arrayWithObjects:@"床",@"衣柜",@"空调",@"电视",@"冰箱",@"洗衣机",@"天然气",@"暖气",@"热水器",@"宽带",nil];
        [self.collectionIView registerNib:[UINib nibWithNibName:@"ZFCollectionCell" bundle:nil] forCellWithReuseIdentifier:kcellIdentifier];
        [self.collectionIView registerNib:[UINib nibWithNibName:@"XWJSupplementaryView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kheaderIdentifier];
        
        self.collectionIView.dataSource = self;
        self.collectionIView.delegate = self;
    }
    
    NSString *title;
    switch (self.type) {
        case HOUSENEW:{
            title = @"新房";
            //            [self getXinFangdetail];
        }
            break;
        case HOUSE2:{
            title = @"二手房";
            [self get2Fangdetail];
        }
            break;
        case HOUSEZU:{
            title = @"租房";
            [self getZFdetail];
        }
            break;
        default:
            break;
    }
    self.navigationItem.title = title;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.hidden  = YES;
    self.tabBarController.tabBar.hidden =YES;
}

-(void)popView{
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)addBackBtn{
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image  = [UIImage imageNamed:@"back"];
    back.frame = CGRectMake(5, 5, image.size.width, image.size.height);
    [back setImage:image forState:UIControlStateNormal];
    [back addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
    [self.adView addSubview:back];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.backScroll.contentSize = CGSizeMake(SCREEN_SIZE.width
                                             , SCREEN_SIZE.height +10+self.miaosLabel.bounds.size.height+100);
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden =NO;
    
}
/**
*id	二手房id	String
* userid	登录用户id	String
*/
//获取二手房的详细信息
-(void)get2Fangdetail{
    NSString *url = GET2HANDDETAIL_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[self.dic valueForKey:@"id"] forKey:@"id"];
    
    XWJAccount *acc  = [XWJAccount instance];
    [dict setValue:acc.uid  forKey:@"userid"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            
            
            NSDictionary *dic = (NSDictionary *)responseObject;
            self.datailDic = [dic objectForKey:@"data"];
            [self updateView];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}

-(void)getZFdetail{
    NSString *url = GETCHUZUDETAIL_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[self.dic valueForKey:@"id"] forKey:@"id"];
    
    XWJAccount *acc  = [XWJAccount instance];
    [dict setValue:acc.uid  forKey:@"userid"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            
            
            NSDictionary *dic = (NSDictionary *)responseObject;
            self.datailDic = [dic objectForKey:@"data"];
            [self updateView];
            
        }else
            [self addBackBtn];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        [self addBackBtn];

    }];
}
//图片按钮的点击事件
-(void)imgclick{
    XWJWebViewController * web = [[XWJWebViewController alloc] init];
    NSString *urls = [self.datailDic objectForKey:@"photo"]==[NSNull null]?@"":[self.dic objectForKey:@"photo"];
    
    NSArray *url = [urls componentsSeparatedByString:@","];
    web.url = [url objectAtIndex:0];
    [self.navigationController pushViewController:web animated:NO];
}
//更新出租房的详细信息
-(void)updateView{
    
    /*
     data =     {
     ReleaseTime = "12-19 13:43";
     area = "<null>";
     buildingArea = "<null>";
     buildingInfo = "\U6e56\U5c9b\U4e16\U5bb6";
     city = "<null>";
     clickCount = 5;
     contactPerson = "\U738b\U7ecf\U7406";
     contactPhone = 18088888888;
     des = "<null>";
     floorCount = 9;
     floors = 7;
     "house_Indoor" = 5;
     "house_Toilet" = 5;
     "house_living" = 5;
     id = 8;
     isCollected = 0;
     maidian = "<null>";
     niandai = "<null>";
     orientation = "\U53cc\U5357";
     photo = "http://www.hisenseplus.com/HisenseUpload/loupan/imag201512191343238102.jpg,http://www.hisenseplus.com/HisenseUpload/loupan/imag201512191343238262.jpg";
     renovationInfo = "\U7cbe\U88c5\U4fee";
     rent = 500;
     };
     */
    
//    NSArray *URLs = @[@"http://admin.guoluke.com:80/userfiles/files/admin/201509181707000766.png",
//                      @"http://admin.guoluke.com:80/userfiles/files/admin/201509181707000766.png",
//                      @"http://img.guoluke.com/upload/201509091054250274.jpg"];
    if ([self.datailDic objectForKey:@"photo"]!=[NSNull null]) {
        URLs = [[self.datailDic valueForKey:@"photo"] componentsSeparatedByString:@","];
    }
    
    

    
    if (URLs.count == 1) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = self.adView.frame;
        [self.adView addSubview:imageView];
        imageView.userInteractionEnabled = YES;

        [imageView sd_setImageWithURL:[NSURL URLWithString:[URLs lastObject]] placeholderImage:nil];
        UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgclick)];
        //点击的次数
        singleRecognizer.numberOfTapsRequired = 1;
        [imageView addGestureRecognizer:singleRecognizer];
    }else
    [self.adView addSubview:({
        
        float time = 3.0f;
        if (URLs.count==1) {
            time = MAXFLOAT;
        }
        LCBannerView *bannerView = [[LCBannerView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                                                                                  self.adView.bounds.size.height)
                                    
                                                              delegate:self
                                                             imageURLs:URLs
                                                      placeholderImage:nil
                                                         timerInterval:time
                                         currentPageIndicatorTintColor:XWJGREENCOLOR
                                                pageIndicatorTintColor:[UIColor whiteColor]
                                                                      :UIViewContentModeScaleAspectFit];
        bannerView;
    })];
    [self addBackBtn];

//    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",[self.datailDic objectForKey:@"buildingInfo"],[NSString stringWithFormat:@"%@室%@厅%@卫",[self.datailDic objectForKey:@"house_Indoor"],[self.datailDic objectForKey:@"house_living"],[self.datailDic objectForKey:@"house_Toilet"]]];
        self.titleLabel.text = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"buildingInfo"]==[NSNull null]?@"":[self.datailDic objectForKey:@"buildingInfo"]];
    self.timeLabel.text = [NSString stringWithFormat:@"发布时间：%@",[self.datailDic objectForKey:@"ReleaseTime"]];
    self.zoneLabel.text = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"area"]];
    self.moneyLabel.text = [NSString stringWithFormat:@"%@万元",[self.datailDic objectForKey:@"rent"]==[NSNull null]?@"":[self.datailDic objectForKey:@"rent"]];
    self.typeLabel.text = [NSString stringWithFormat:@"%@室%@厅%@卫",[self.datailDic objectForKey:@"house_Indoor"],[self.datailDic objectForKey:@"house_living"],[self.datailDic objectForKey:@"house_Toilet"]];
    self.sizeLabel.text = [NSString stringWithFormat:@"%.1fm²",[self.datailDic objectForKey:@"buildingArea"]==[NSNull null]?[@"0" floatValue]:[[self.datailDic valueForKey:@"buildingArea"] floatValue]];
    self.zhuangxiuLabel.text = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"renovationInfo"]==[NSNull null]?@"":[self.datailDic objectForKey:@"renovationInfo"]];
    //    self.priceLabel.text = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"renovationInfo"]];
    self.loucengLabel.text = [NSString stringWithFormat:@"%@/%@",[self.datailDic objectForKey:@"floors"],[self.datailDic objectForKey:@"floorCount"]];
    //    self.shoufuLabel.text = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"renovationInfo"]];
    self.niandaiLabel.text = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"niandai"]==[NSNull null]?@"":[self.datailDic objectForKey:@"niandai"]];
    //    self.yuegongLabel.text = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"renovationInfo"]];
    self.fukuanLabel.text = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"fkfs"]==[NSNull null]?@"":[self.datailDic objectForKey:@"fkfs"]];
        self.liulanLabel.text= [NSString stringWithFormat:@"浏览次数 %@",[self.datailDic objectForKey:@"clickCount"]==[NSNull null]?@"":[self.datailDic objectForKey:@"clickCount"]];
    

    [self.dialBtn setTitle:[NSString stringWithFormat:@"%@ %@",[self.datailDic objectForKey:@"contactPerson"]==[NSNull null]?@"":[self.datailDic objectForKey:@"contactPerson"],[self.datailDic objectForKey:@"contactPhone"]==[NSNull null]?@"":[self.datailDic objectForKey:@"contactPhone"]] forState:UIControlStateNormal];
    
    if([self.datailDic objectForKey:@"supporting"]!=[NSNull null]){

        if ([[self.datailDic objectForKey:@"supporting"] isKindOfClass:[NSArray class]]) {
            
            self.collectionData = [NSArray arrayWithArray:[self.datailDic objectForKey:@"supporting"]];
            [self.collectionIView reloadData];
        }
    }
    //    @property (weak, nonatomic) IBOutlet UIImageView *yaoshiView;
    //    @property (weak, nonatomic) IBOutlet UIImageView *xuequView;
    self.miaosLabel.text = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"description"]==[NSNull null]?@"":[self.datailDic objectForKey:@"description"]];
    NSString *collect = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"isCollected"]];
    
    if ([collect isEqualToString:@"0"]) {
        self.shoucangBtn.selected = NO;
    }else{
        self.shoucangBtn.selected = YES;
    }
    
}

- (void)bannerView:(LCBannerView *)bannerView didClickedImageIndex:(NSInteger)index {
    XWJWebViewController *web = [[XWJWebViewController alloc] init];
    
    web.url = URLs[index];
    [self.navigationController  showViewController:web sender:self];
}

-(void)dail:(NSString *)tel{
    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",tel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark -CollectionView datasource
//section
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    collectionCellHeight = self.collectionIView.frame.size.height/COLLECTION_NUMSECTIONS-1;
    collectionCellWidth = self.collectionIView.frame.size.width/COLLECTION_NUMITEMS-1;
    NSInteger count = self.collectionData.count;
    if (count>5) {
        return 2;
    }
    return 1;}
//item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.collectionData.count;
    if (count>5) {
        
        if (section==0) {
            return 5;
        }else
            return count-5;
    }
    return count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    NSString *reuseIdentifier;
    if ([kind isEqualToString: UICollectionElementKindSectionFooter ]){
        //        reuseIdentifier = kfooterIdentifier;
    }else{
        reuseIdentifier = kheaderIdentifier;
    }
    
    UICollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[view viewWithTag:1];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        label.textColor  = XWJGREENCOLOR;
        label.text  = @"配套设施";
    }
    UIButton *button  = (UIButton*)[view viewWithTag:2];
    button.hidden = YES;
    
    
    
    return view;
}
// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //重用cell
    UICollectionViewCell *cell = [self.collectionIView dequeueReusableCellWithReuseIdentifier:kcellIdentifier forIndexPath:indexPath];
    cell.userInteractionEnabled = NO;
    
    //赋值
    UIButton *btn = (UIButton *)[cell viewWithTag:1];
    
    
    NSString * key = [NSString stringWithFormat:@"%@",[self.collectionData[indexPath.section*COLLECTION_NUMITEMS+indexPath.row] objectForKey:@"dicValue"]];

    [btn setTitle:key forState:UIControlStateNormal];
    
    NSNumber *num = [self.collectionData[indexPath.section*COLLECTION_NUMITEMS+indexPath.row] objectForKey:@"isSup"];

    /*
     {
     dicKey = 1;
     dicValue = "\U5e8a";
     isSup = 1;
     */
    if ([num integerValue]==1) {
        btn.selected = YES;
    }
    //    cell.backgroundColor = [UIColor colorWithRed:68.0/255.0 green:70.0/255.0 blue:71.0/255.0 alpha:1.0];
    return cell;
    
}

//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionCellWidth, CELL_HEIGHT);
}
//定义每个Section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1, 0, 0, 0);//分别为上、左、下、右
}
//返回头headerView的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        
        CGSize size =  {self.view.bounds.size.width,30};
        return size;
    }else{
        CGSize size={0,0};
        return size;
    }
    
}
//返回头footerView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGSize size={0,0};
    return size;
}
//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
//每个item之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
//选择了某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell viewWithTag:1];
    btn.selected = YES;
    //    [cell setBackgroundColor:[UIColor greenColor]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)shoucang:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (self.type == HOUSE2) {
        [self shoucang:@"2"];
    }
    if (self.type ==HOUSEZU) {
        [self shouCang:@"3"];
    }
}

-(void)shouCang:(NSString *)type{
    NSString *url = GETXINFANGSHOUCANG_URL;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    /*
     userid	登录用户id	String
     type	类型（1：买新房，2：二手房，3：出租房）	String,1,2,3
     lpId	楼盘id	String
     */
    XWJAccount *account = [XWJAccount instance];
    [dict setValue:[self.datailDic valueForKey:@"id"]  forKey:@"lpId"];
    [dict setValue:type  forKey:@"type"];
    [dict setValue: account.uid  forKey:@"userid"];
    
//    NSString *collect = [NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"isCollected"]];
//    if ([collect isEqualToString:@"0"]) {
//        [dict setValue:@"1" forKey:@"isCollect"];
//    }else{
//        [dict setValue:@"0" forKey:@"isCollect"];
//    }
    if (self.shoucangBtn.selected) {
        [dict setValue:@"1" forKey:@"isCollect"];
    }else{
        [dict setValue:@"0" forKey:@"isCollect"];
    }
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dict = (NSDictionary *)responseObject;
            CLog(@"dic %@",dict);
            NSNumber *res =[dict objectForKey:@"result"];
            if ([res intValue] == 1) {
                
                NSString *errCode = [dict objectForKey:@"errorCode"];
                UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:nil message:errCode delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertview.delegate = self;
                [alertview show];
                
//                [self.navigationController popViewControllerAnimated:YES];
                
                
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
    
}

- (IBAction)dial:(UIButton *)sender {
    [self dail:[NSString stringWithFormat:@"%@",[self.datailDic objectForKey:@"contactPhone"]]];
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

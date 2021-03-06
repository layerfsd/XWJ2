//
//  XWJFindDetailViewController.m
//  XWJ
//
//  Created by Sun on 15/12/5.
//  Copyright © 2015年 Paul. All rights reserved.
//

#import "XWJFindDetailViewController.h"
#import "XWJFindDetailTableViewCell.h"
#import "XWJAccount.h"
#import "LCBannerView.h"
#import "XWJWebViewController.h"
#import "UIImage+Category.h"

#import "UITextView+placeholder.h"

#import "UMSocial.h"

#import "UMSocial.h"
#import "ProgressHUD/ProgressHUD.h"

#define KEY_HEADIMG @"headimg"
#define KEY_TITLE @"title"
#define KEY_TIME  @"time"
#define KEY_CONTENT @"content"

@interface XWJFindDetailViewController ()<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,LCBannerViewDelegate,UMSocialUIDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *CommentBtn;
@property (weak, nonatomic) IBOutlet UIButton *phraseBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic,copy)NSString* codeStr;

- (IBAction)shareDetail:(id)sender;
@property  UIControl *controlView;
@property  CGRect bottomRect;
@property(nonatomic,copy)NSString* shareImageStr;
@property(nonatomic,copy)NSString* sharecontStr;
@property(nonatomic,copy)NSString* shareUrl;
@end

@implementation XWJFindDetailViewController{

    NSInteger _currentPage;
}
@synthesize controlView;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currentPage = 0;
    self.textView.delegate = self;
    [self registerForKeyboardNotifications];
    
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 进入刷新状态后会自动调用这个block
        _currentPage = 0 ;
        [self getFind:0];
        [self.scrollView.mj_header endRefreshing];
        
    }];
    self.scrollView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        //进入加载状态后会自动调用这个block
        _currentPage ++ ;
        NSString *str  = [NSString stringWithFormat:@"%ld",_currentPage];
        [self getFind:0 WithPage:str];
        [self.scrollView.mj_footer endRefreshing];
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSMutableDictionary  *dic = [NSMutableDictionary dictionary];
    
    UIImage *image = [UIImage imageNamed:@"mor_icon_default"];
    [dic setObject:image forKey:KEY_HEADIMG];
    [dic setValue:@"小宝" forKey:KEY_TITLE];
    [dic setValue:@"2015-11-11" forKey:KEY_TIME];
    [dic setValue:@"保养几次了什么时候方便看车" forKey:KEY_CONTENT];
    [self getFind:0];
    self.textView.placeholder = @"在此发表评论";
    
    [self.phraseBtn addTarget:self action:@selector(phrase:) forControlEvents:UIControlEventTouchUpInside];
    //    self.array = [NSArray arrayWithObjects:dic,dic,dic,dic,dic,dic,dic, nil];
    
}
#pragma mark - 分享按钮响应
- (void)shareDetail:(id)sender{
    CLog(@"分享");
    UIImageView* temIV = [[UIImageView alloc] init];
    
    [temIV sd_setImageWithURL:[NSURL URLWithString:self.shareImageStr] placeholderImage:[UIImage imageNamed:@"devAdv_default"]];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"56938a23e0f55aac1d001cb6"
                                      shareText:self.sharecontStr
                                     shareImage:temIV.image
                                shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline]
                                       delegate:self];
    [UMSocialData defaultData].extConfig.wechatSessionData.url = self.shareUrl;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.shareUrl;
}
#pragma mark - //实现回调方法（可选)
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        CLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        /*
         这个地方哪有QQ分享  这个地方需要判断一下是哪分享成功了  我没数据线装不了app
         if ([UMShareToWechatSession isEqualToString:[[response.data allKeys] objectAtIndex:0]]) {
         self.codeStr = @"shareWXCount";
         }
         */
        
        NSInteger count = [self.shareBtn.titleLabel.text integerValue];
        count++;
        //    sender.enabled = NO;
        [self.shareBtn setTitle:[NSString stringWithFormat:@"%ld",(long)count] forState:UIControlStateNormal];
        self.codeStr = @"shareWXCount";
        [self createShareSuccessRequest];
    }
}
#pragma mark - 分享请求
- (void)createShareSuccessRequest{
    NSString* requestAddress = FINDSUCCESSSHARE;
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:requestAddress parameters:@{
                                              @"id":[self.dic valueForKey:@"id"],
                                              @"code":self.codeStr
                                              }
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              CLog(@"------%@",responseObject);
              
              if ([[responseObject objectForKey:@"result"] intValue]) {
                  
              }else{
                  
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              CLog(@"失败===%@", error);
          }];
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
//设置不能重复点赞
-(void)phrase:(UIButton *)sender{
    
    if(sender.selected){
        [ProgressHUD showError:@"不能重复点赞"];
    }else{
        
        sender.selected=YES;
        NSInteger count = [sender.titleLabel.text integerValue];
        count++;
        //    sender.enabled = NO;
        [sender setTitle:[NSString stringWithFormat:@"%ld",(long)count] forState:UIControlStateNormal];
        [self pubCommentLword:@"" type:@"点赞"];
    }
}
//将评论发布到服务器
-(void)pubCommentLword:(NSString *)leaveword type:(NSString *)types{
    NSString *url = GETFINDPUBCOM_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    /*
     findId	发现id	String
     types	类型	String,留言/点赞
     personId	登录用户id	String
     leaveWord	留言内容	String
     findType	发现类别	String
     leixing	区别是物业还是发现	String,find/supervise
     */
    XWJAccount *account = [XWJAccount instance];
    [dict setValue:[self.dic valueForKey:@"id"]  forKey:@"findId"];
    [dict setValue:types  forKey:@"types"];
    [dict setValue: account.uid  forKey:@"personId"];
    [dict setValue:leaveword  forKey:@"leaveWord"];
    [dict setValue:[self.dic valueForKey:@"types"]  forKey:@"findType"];
    [dict setValue:@"find" forKey:@"leixing"];
    
    [self leaveEditMode];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        if(responseObject){
            NSDictionary *dict = (NSDictionary *)responseObject;
            CLog(@"dic %@",dict);
            NSNumber *res =[dict objectForKey:@"result"];
            if ([res intValue] == 1) {
                
                [self getFind:0];
                NSString *errCode = [dict objectForKey:@"errorCode"];
                
                if ([types isEqualToString:@"点赞"]) {
                    [ProgressHUD showSuccess:@"点赞成功"];
                }else
                    [ProgressHUD showSuccess:@"评论成功"];
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}
//广告的横幅
- (void)bannerView:(LCBannerView *)bannerView didClickedImageIndex:(NSInteger)index{
    XWJWebViewController * web = [[XWJWebViewController alloc] init];
    NSString *urls = [self.dic objectForKey:@"Photo"]==[NSNull null]?@"":[self.dic objectForKey:@"Photo"];
    
    NSArray *url = [urls componentsSeparatedByString:@","];
    web.url = [url objectAtIndex:index];
    self.shareImageStr = [url firstObject];
    [self.navigationController pushViewController:web animated:NO];
}
//点击选择图片
-(void)imgclick{
    XWJWebViewController * web = [[XWJWebViewController alloc] init];
    NSString *urls = [self.dic objectForKey:@"Photo"]==[NSNull null]?@"":[self.dic objectForKey:@"Photo"];
    
    NSArray *url = [urls componentsSeparatedByString:@","];
    web.url = [url objectAtIndex:0];
    self.shareImageStr = [url firstObject];
    [self.navigationController pushViewController:web animated:NO];
}
//获得发现的详细的信息
-(void)getFind:(NSInteger )index{
    
    NSString *url = GETFIND_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[self.dic valueForKey:@"id"]  forKey:@"id"];
    [dict setValue:@"0" forKey:@"pageindex"];
    [dict setValue:@"10" forKey:@"countperpage"];
    
    CLog(@"______%@",self.dic);
    //    [dict setValue:[XWJAccount instance].uid forKey:@"userid"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        /*
         find =         {
         "a_id" = "<null>";
         appID = 12;
         clickPraiseCount = 0;
         content = "\U661f\U5df4\U514b\U4e4b\U9ebb\U8fa3\U706b\U9505";
         id = 10;
         leaveWordCount = 0;
         nickName = "<null>";
         photo = "http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535403.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535601.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535471.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535433.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535420.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535552.jpg";
         releaseTime = "12-08 20:13";
         shareQQCount = 0;
         shareWXCount = 0;
         types = "\U597d\U4eba\U597d\U4e8b";
         };
         */
        if(responseObject){
            NSDictionary *dict = (NSDictionary *)responseObject;
            CLog(@"dic %@",dict);
            NSNumber *res =[dict objectForKey:@"result"];
            if ([res intValue] == 1) {
                
                NSDictionary* temDic = responseObject[@"data"];
                NSDictionary* temDic1 = temDic[@"find"];
                //   CLog(@"-----%@\n----%@",temDic1,temDic1[@"id"]);
                NSString *dicstring = [NSString stringWithFormat:@"%@",temDic1];
                if ([dicstring isEqualToString:@"<null>"]) {
                    return ;
                }
                
                self.shareUrl =[NSString stringWithFormat:@"http://admin.hisenseplus.com/win/t_cm_finddetail.aspx?id=%@",temDic1[@"id"]];
                /*
                 
                 "A_id" = 1;
                 FindID = 22;
                 ID = 15;
                 LeaveWord = "\U671f\U5f85\U5723\U8bde\U8001\U7237\U7237\U7684\U5230\U6765";
                 NickName = "<null>";
                 PersonID = 36;
                 Photo = "<null>";
                 ReleaseTime = "12-15 0:00";
                 Types = "\U7559\U8a00";
                 */
                
//                self.array = [NSMutableArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"comments"]];
                NSArray *arr1  = [NSMutableArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"comments"]];
                self.array = [[NSMutableArray alloc]init];
                [self.array removeAllObjects];
                [self.array addObjectsFromArray:arr1];
                
                
                if([[dict objectForKey:@"data"] objectForKey:@"find"]!=[NSNull null]){
                    
                    self.dic = [NSMutableDictionary dictionaryWithDictionary:[(NSDictionary*)[dict objectForKey:@"data"] objectForKey:@"find"]];
                    CLog(@"%@",self.dic);
                    [self initView];
                }
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 130.0*self.array.count);
                [self.tableView reloadData];
                self.scrollView.contentSize = CGSizeMake(0,self.phraseBtn.frame.origin.y +60+130*self.array.count);
                
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}


//获得发现评论的下一页的详细的信息
-(void)getFind:(NSInteger )index WithPage:(NSString *)nextPage{
    
    NSString *url = GETFIND_URL;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[self.dic valueForKey:@"id"]  forKey:@"id"];
    [dict setValue:nextPage forKey:@"pageindex"];
    [dict setValue:@"5" forKey:@"countperpage"];
    
    CLog(@"______%@",self.dic);
    //    [dict setValue:[XWJAccount instance].uid forKey:@"userid"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [manager POST:url parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLog(@"%s success ",__FUNCTION__);
        
        /*
         find =         {
         "a_id" = "<null>";
         appID = 12;
         clickPraiseCount = 0;
         content = "\U661f\U5df4\U514b\U4e4b\U9ebb\U8fa3\U706b\U9505";
         id = 10;
         leaveWordCount = 0;
         nickName = "<null>";
         photo = "http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535403.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535601.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535471.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535433.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535420.jpg,http://www.hisenseplus.com/HisenseUpload/find_photo/imag201512082013535552.jpg";
         releaseTime = "12-08 20:13";
         shareQQCount = 0;
         shareWXCount = 0;
         types = "\U597d\U4eba\U597d\U4e8b";
         };
         */
        if(responseObject){
            NSDictionary *dict = (NSDictionary *)responseObject;
            CLog(@"dic %@",dict);
            NSNumber *res =[dict objectForKey:@"result"];
            if ([res intValue] == 1) {
                
                NSDictionary* temDic = responseObject[@"data"];
                NSDictionary* temDic1 = temDic[@"find"];
                //   CLog(@"-----%@\n----%@",temDic1,temDic1[@"id"]);
                NSString *dicstring = [NSString stringWithFormat:@"%@",temDic1];
                if ([dicstring isEqualToString:@"<null>"]) {
                    return ;
                }
                
                self.shareUrl =[NSString stringWithFormat:@"http://admin.hisenseplus.com/win/t_cm_finddetail.aspx?id=%@",temDic1[@"id"]];
                /*
                 
                 "A_id" = 1;
                 FindID = 22;
                 ID = 15;
                 LeaveWord = "\U671f\U5f85\U5723\U8bde\U8001\U7237\U7237\U7684\U5230\U6765";
                 NickName = "<null>";
                 PersonID = 36;
                 Photo = "<null>";
                 ReleaseTime = "12-15 0:00";
                 Types = "\U7559\U8a00";
                 */
                
 //               self.array = [NSMutableArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"comments"]];
                NSArray *arr2  = [NSMutableArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"comments"]];
                [self.array addObjectsFromArray:arr2];
                
                
                if([[dict objectForKey:@"data"] objectForKey:@"find"]!=[NSNull null]){
                    
                    self.dic = [NSMutableDictionary dictionaryWithDictionary:[(NSDictionary*)[dict objectForKey:@"data"] objectForKey:@"find"]];
                    CLog(@"%@",self.dic);
                    [self initView];
                }
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 130.0*self.array.count);
                [self.tableView reloadData];
                self.scrollView.contentSize = CGSizeMake(0,self.phraseBtn.frame.origin.y +60+130*self.array.count);
                
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        CLog(@"%s fail %@",__FUNCTION__,error);
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.textView resignFirstResponder];
}
-(void)initView{
    CLog(@"%@",self.dic);
    NSString * zanCount = [self.dic objectForKey:@"ClickPraiseCount"]==[NSNull null]?@" ":[NSString stringWithFormat:@"%@",[self.dic objectForKey:@"ClickPraiseCount"]];
    NSString *  leaveCount= [self.dic objectForKey:@"LeaveWordCount"]==[NSNull null]?@" ":[NSString stringWithFormat:@"%@",[self.dic objectForKey:@"LeaveWordCount"]];
    //    NSString * qqCount = [self.dic objectForKey:@"ShareQQCount"]==[NSNull null]?@" ":[NSString stringWithFormat:@"%@",[self.dic objectForKey:@"ShareQQCount"]];
    NSString * wxCount = [NSString stringWithFormat:@"%@", [self.dic objectForKey:@"ShareWXCount"]==[NSNull null]?@"0":[self.dic objectForKey:@"ShareWXCount"]];
    
    [_phraseBtn setTitle:zanCount forState:UIControlStateNormal];
    [_CommentBtn setTitle:leaveCount forState:UIControlStateNormal];
    [self.shareBtn setTitle:wxCount forState:UIControlStateNormal];
/*
       使用三目运算符来处理nsnull类型的字符串，用空的字符串来替换NSNull数据，使得NSNull不至于显示出来，或者是因为缺少字段数据而导致程序的崩溃
*/
    NSString * name = [self.dic objectForKey:@"NickName"]==[NSNull null]?@" ":[NSString stringWithFormat:@"%@",[self.dic objectForKey:@"NickName"]];
    
    [_infoBtn setTitle:name forState:UIControlStateNormal];
    _timelabel.text = [self.dic objectForKey:@"ReleaseTime"];
    _titleLabel.text=[self.dic objectForKey:@"content"];
    self.sharecontStr = [self.dic objectForKey:@"content"];
    _typeLabel.text = [self.dic objectForKey:@"Memo"];
    
    if ([[NSString stringWithFormat:@"%@",[self.dic objectForKey:@"canZan"]] isEqualToString:@"0"]) {
        
        self.phraseBtn.selected = YES;
    }else{
        self.phraseBtn.selected = NO;
    }
//   判断发现的类型
    NSString *type = [self.dic objectForKey:@"Memo"];
    if ([type isEqualToString:@"社区分享"]) {
        _typeLabel.backgroundColor = XWJColor(255,44, 56);
    }else if ([type isEqualToString:@"跳蚤市场"]){
        _typeLabel.backgroundColor = XWJColor(234, 116, 13);
    }else{
        _typeLabel.backgroundColor = XWJColor(67, 164, 83);
    }
    
    NSString * userP = [self.dic objectForKey:@"userP"]==[NSNull null]?nil:[self.dic objectForKey:@"userP"];
    if (userP) {
        [_infoBtn.imageView sd_setImageWithURL:[NSURL URLWithString:userP] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            CGFloat width=  _infoBtn.bounds.size.height-5;
            _infoBtn.imageView.layer.cornerRadius = width/2;
            [_infoBtn setImage:[image transformWidth:width height:width] forState:UIControlStateDisabled];
            
        }];
    }
    NSString *urls = [self.dic objectForKey:@"Photo"]==[NSNull null]?@"":[self.dic objectForKey:@"Photo"];
    
    NSArray *url = [urls componentsSeparatedByString:@","];
    
    if (url.count == 1) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[url lastObject]] placeholderImage:nil];
        UITapGestureRecognizer* singleRecognizer;
        singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgclick)];
        //点击的次数
        singleRecognizer.numberOfTapsRequired = 1;
        [self.imageView addGestureRecognizer:singleRecognizer];
    }else
        [self.imageView addSubview:({
            CGFloat time = 5.0f;
            
            if (url.count==1) {
                time = MAXFLOAT;
            }
            
            LCBannerView *bannerView = [[LCBannerView alloc] initWithFrame:CGRectMake(0, 0, self.imageView.bounds.size.width,self.imageView.bounds.size.height)
                                                                  delegate:self
                                                                 imageURLs:url
                                                          placeholderImage:nil
                                                             timerInterval:time
                                             currentPageIndicatorTintColor:XWJGREENCOLOR
                                                    pageIndicatorTintColor:[UIColor whiteColor]
                                                                          :UIViewContentModeScaleAspectFit];
            bannerView;
        })];
    
    //    [_imageView sd_setImageWithURL:[NSURL URLWithString:userP] placeholderImage:[UIImage imageNamed: @"demo"]];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.array.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XWJFindDetailTableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"findDetailCell"];
    if (!cell) {
        cell = [[XWJFindDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"findDetailCell"];
    }
    // Configure the cell...
    NSDictionary *dic = (NSDictionary *)self.array[indexPath.row];
    
    /*
     
     "A_id" = 1;
     FindID = 22;
     ID = 15;
     LeaveWord = "\U671f\U5f85\U5723\U8bde\U8001\U7237\U7237\U7684\U5230\U6765";
     NickName = "<null>";
     PersonID = 36;
     Photo = "<null>";
     ReleaseTime = "12-15 0:00";
     Types = "\U7559\U8a00";
     */
    
    
    [cell.headImgView  sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"Photo"]==[NSNull null]?@"":[dic objectForKey:@"Photo"]] placeholderImage:[UIImage imageNamed:@"headDefaultImg"] options:SDWebImageDelayPlaceholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        CGFloat width=  cell.headImgView.bounds.size.height;
        cell.headImgView.layer.cornerRadius = width/2;
        cell.headImgView.layer.masksToBounds = YES;
        if(image)
            [cell.headImgView  setImage:[image transformWidth:width height:width]];
        else{
            UIImage * img = [UIImage imageNamed:@"headDefaultImg"] ;
            [cell.headImgView  setImage:[img transformWidth:width height:width]];
        }
        
    }];
    
    //    [cell.headImgView sd_setImageWithURL:[NSURL URLWithString:[dic objectForKey:@"Photo"]==[NSNull null]?@"":[dic objectForKey:@"Photo"]]placeholderImage:[UIImage imageNamed:@"demo"]];
    cell.commenterLabel.text = [dic objectForKey:@"NickName"]==[NSNull null]?@" ":[dic objectForKey:@"NickName"];
    cell.timeLabel.text = [dic objectForKey:@"ReleaseTime"]==[NSNull null]?@" ":[dic objectForKey:@"ReleaseTime"];
    cell.contentLabel.text = [dic objectForKey:@"LeaveWord"]==[NSNull null]?@" ":[dic objectForKey:@"LeaveWord"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        return cell;
}

- (void)registerForKeyboardNotifications
{
    //使用NSNotificationCenter 鍵盤出現時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    //使用NSNotificationCenter 鍵盤隐藏時
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
}

//实现当键盘出现的时候计算键盘的高度大小。用于输入框显示位置
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    //kbSize即為鍵盤尺寸 (有width, height)
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到鍵盤的高度
    CLog(@"hight_hitht:%f",kbSize.height);
    
    self.bottomRect = self.bottomView.frame ;
    self.textView.text = @"";
    CGFloat keyboardhight;
    if(kbSize.height == 216)
    {
        keyboardhight = 0;
    }
    else
    {
        keyboardhight = 36;   //252 - 216 系统键盘的两个不同高度
    }
    [self beginAppearanceTransition:YES
                           animated:YES];
    //输入框位置动画加载
    //    [self beginMoveUpAnimation:keyboardhight];
}

//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.bottomView.frame = self.bottomRect;
    //do something
}

- (IBAction)enroll:(id)sender {
    if([self.textView.text isEqualToString:@"在此发表评论"] || [self.textView.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"评论内容不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        [self pubCommentLword:self.textView.text type:@"留言"];
        [self.textView resignFirstResponder];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    //    if (!controlView) {
    //        controlView        = [[UIControl alloc] initWithFrame:self.view.frame];
    //        [controlView addTarget:self action:@selector(leaveEditMode) forControlEvents:UIControlEventTouchUpInside];
    //        controlView.backgroundColor = [UIColor clearColor];
    //    }
    //    [self.view addSubview:controlView];
    
    //    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    //    btn.frame = CGRectMake(0, 0, 40, 40);
    //    [btn setTitle:@"完成" forState:UIControlStateNormal];
    //    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    //    [btn addTarget:self action:@selector(leaveEditMode) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *done= [[UIBarButtonItem  alloc] initWithCustomView:btn];
    //    self.navigationItem.rightBarButtonItem = done;
}



- (void)textViewDidEndEditing:(UITextView *)textView {
    
    [controlView removeFromSuperview];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)leaveEditMode {
    [self.textView resignFirstResponder];
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

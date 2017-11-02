//
//  ZhanghuViewController.m
//  HDJ
//
//  Created by xueyongwei on 16/5/23.
//  Copyright © 2016年 xueyongwei. All rights reserved.
//

#import "ChongZhiViewController.h"
#import "AppDelegate.h"
#import "TalkingDataGA.h"
#import <StoreKit/StoreKit.h>
#import "zhanghuHDView.h"
#import "ChongzhiTableViewCell.h"
#import "chognzhiListModel.h"

@interface ChongZhiViewController ()<UITableViewDelegate,UITableViewDataSource,SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,copy)NSString *productID;
@property (nonatomic,copy)NSString *charegeOrderID;
@property (nonatomic,strong)zhanghuHDView *hdView;
@end

@implementation ChongZhiViewController
-(zhanghuHDView *)hdView
{
    if (!_hdView) {
        _hdView = [[[NSBundle mainBundle]loadNibNamed:@"ZhanghuHdView" owner:self options:nil]lastObject];
    }
    
    return _hdView;
}
-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"充值";
    [self customTbaleView];
    [self prepareList];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"充值页面"];
    [self prepareMyInfo];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
     [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark ---🎈网络数据
-(void)prepareList
{
//    /v1/finance/chargeForm
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/finance/chargeForm"] parameters:nil inView:nil sucess:^(id result) {
        if (result&&[result isKindOfClass:[NSArray class]]) {
            NSArray *list = (NSArray *)result;
            [self.dataSource removeAllObjects];
            for (NSDictionary *itm in list) {
                chognzhiListModel *model = [chognzhiListModel mj_objectWithKeyValues:itm];
                [self.dataSource addObject:model];
            }
            [self.tableView reloadData];
        }

    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
    }];

}
-(void)chongzhiWith:(NSInteger)idx
{
    CoreSVPLoading(@"准备支付...", NO);
    chognzhiListModel *model = self.dataSource[idx];
    NSString *ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    NSString *vc = [NSString stringWithFormat:@"chargeChannelId=%d&chargeMenuOptionId=%ld&ts=%@%@",2,(long)model.productID,ts,SECUREKEY];
    NSDictionary *param = @{@"chargeMenuOptionId":[NSString stringWithFormat:@"%ld",(long)model.productID],@"chargeChannelId":@"2",@"ts":ts,@"vc":vc.md5};
    [XYWhttpManager XYWpost:[NSString stringWithFormat:@"%@%@",HeadUrl,@"/finance/preCharge"] parameters:param inView:nil sucess:^(id result) {
        if ([result objectForKey:@"chargeOrderId"]) {
            self.charegeOrderID = [result objectForKey:@"chargeOrderId"];
            self.productID = [NSString stringWithFormat:@"%ld",(long)model.productID];
            [self chareToApple];
            [TDGAVirtualCurrency onChargeRequst:self.charegeOrderID iapId:[NSString stringWithFormat:@"proudct:%ld",(long)idx] currencyAmount:model.amountRMB currencyType:@"CNY" virtualCurrencyAmount:model.goldBeans paymentType:@"iTunes"];
        }

    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);;
        [CoreSVP dismiss];

    }];
    
}
-(void)chareToApple
{
    DbLog(@"%@ %@",self.productID,self.charegeOrderID);
    if([SKPaymentQueue canMakePayments]){
        [self requestProductData:self.productID];
    }else{
        CoreSVPCenterMsg(@"不允许程序内付费");
        [CoreSVP dismiss];
    }

}
//请求商品
- (void)requestProductData:(NSString *)type{
    
    DbLog(@"-------------请求对应的产品信息----------------");
    NSArray *product = [[NSArray alloc] initWithObjects:type,nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    DbLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if([product count] == 0){
        DbLog(@"--------------没有商品------------------");
//        CoreSVPCenterMsg(@"没有商品信息！");
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"没有商品信息！" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
        [CoreSVP dismiss];
        return;
    }
    DbLog(@"productID:%@", response.invalidProductIdentifiers);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {

        if([pro.productIdentifier isEqualToString:self.productID]){
            p = pro;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    DbLog(@"发送购买请求");

    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    DbLog(@"------------------错误-----------------:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request{
    DbLog(@"------------反馈信息结束-----------------");
    
}


//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    
    for(SKPaymentTransaction *tran in transaction){
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                DbLog(@"交易完成");
                [self completeTransaction:tran];
                
                break;
            }
            case SKPaymentTransactionStatePurchasing:
                DbLog(@"商品添加进列表");
                CoreSVPLoading(@"支付中..", NO);
                break;
            case SKPaymentTransactionStateRestored:
                DbLog(@"已经购买过商品");
                CoreSVPSuccess(@"已恢复购买状态！");
                break;
            case SKPaymentTransactionStateFailed:
                DbLog(@"交易失败");
                
                [self failedTransaction:tran];
                break;
            default:
                break;
        }
    }
}

//交易结束
/**
 *  解析收据
 *
 *  @param transaction
 */
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    NSString * productIdentifier = transaction.payment.productIdentifier;
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    if (!productIdentifier) {
        [CoreSVP dismiss];
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"支付失败" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
        return;
    }
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    NSString *base64String = [receiptData base64EncodedStringWithOptions:0];
//    [self check:receiptData];
//    NSString * receipt = [NSString stringWithUTF8String:[base64Data bytes]];
    if ([base64String length] > 0) {
        // 向自己的服务器验证购买凭证
        CoreSVPLoading(@"正在验证...", NO);
        [self tellServerSucess:base64String];
    }else{
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"支付失败！" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
        [CoreSVP dismiss];
    }
    // Remove the transaction from the payment queue.
    
}
-(void)check:(NSData *)receipt
{
    // Create the JSON object that describes the request
    NSError *error;
    NSDictionary *requestContents = @{
                                      @"receipt-data": [receipt base64EncodedStringWithOptions:0]
                                      };
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:&error];
    
    if (!requestData) { /* ... Handle error ... */ }
    
    // Create a POST request with the receipt data.
    NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    // Make a connection to the iTunes Store on a background queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"购买失败" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
                                   [alv show];
                               } else {
                                   NSError *error;
                                   NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//                                   [CoreSVP dismiss];
                                   
                                   if (!jsonResponse) {
                                       UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"购买失败" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
                                       [alv show];
                                   }else{
                                       UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"购买成功！" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
                                       [alv show];
                                   }
                               }
                           }];

}
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [CoreSVP dismiss];
    if(transaction.error.code != SKErrorPaymentCancelled) {
        DbLog(@"购买失败!");
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"购买失败" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
    } else {
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"购买已取消" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
        DbLog(@"用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    // 恢复已经购买的产品
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}
-(void)tellServerSucess:(NSString *)transactionReceipt
{
    if (self.productID.integerValue<1) {
        [CoreSVP dismiss];
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"未获取到交易凭证！" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
        return;
    }
    if (transactionReceipt.length<10) {
        [CoreSVP dismiss];
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"未获取到交易凭证！" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
        return;
    }
   
    NSString *ts = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]*1000];
    NSString *vc = [NSString stringWithFormat:@"chargeOrderId=%@&receipt=%@&ts=%@%@",self.charegeOrderID,transactionReceipt,ts,SECUREKEY];
    NSDictionary *param = @{@"chargeOrderId":self.charegeOrderID,@"receipt":transactionReceipt,@"ts":ts,@"vc":vc.md5};
    
    NSString *url = [NSString stringWithFormat:@"%@/finance/setIapCertificate",HeadUrl];
    [XYWhttpManager XYWpost:url parameters:param inView:nil sucess:^(id result) {
        [CoreSVP dismiss];
        if (result) {
            DbLog(@"%@",result);
            if ([result objectForKey:@"success"]) {
                UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"充值成功！" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
                [alv show];
                [self prepareMyInfo];
                [TDGAVirtualCurrency onChargeSuccess:self.charegeOrderID];
                
            }else{
                UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"充值失败！" message:nil delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
                [alv show];
            }
        }
    } failure:^(NSError *error) {
        CoreSVPCenterMsg(error.localizedDescription);
        DbLog(@"%@",error.localizedDescription);;
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"交易出错！" message:error.localizedDescription delegate:nil cancelButtonTitle:@"好的" otherButtonTitles: nil];
        [alv show];
        [CoreSVP dismiss];
    }];
}
#pragma mark --- 准备数据
-(void)prepareMyInfo
{
    [UserInfoManager refreshMyselfInfoFinished:^{
        self.hdView.yueNumber = [UserInfoManager mySelfInfoModel].balance;
    }];
}
- (void)dealloc{
   
}

#pragma mark - tableView Delegate
-(void)customTbaleView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 50;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChongzhiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChongzhiTableViewCellID"];
    if (!cell) {
        cell = (ChongzhiTableViewCell*)[[[NSBundle mainBundle]loadNibNamed:@"ChongzhiTableViewCell" owner:self options:nil]lastObject ];
    }
    chognzhiListModel *model = self.dataSource[indexPath.row];
   
    cell.moneyLabel.text =  [NSString stringWithFormat:@"¥%.2f",model.amountRMB];
    
    if (model.present ==0) {
        cell.douziLabel.text = [NSString stringWithFormat:@"%ld",(long)model.goldBeans];
    }else{
        NSString *douzi = [NSString stringWithFormat:@"%ld",(long)model.goldBeans];
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:douzi];
        
        [AttributedStr addAttribute:NSFontAttributeName
         
                              value:[UIFont systemFontOfSize:14]
         
                              range:NSMakeRange(0, douzi.length)];
        
        [AttributedStr addAttribute:NSForegroundColorAttributeName
         
                              value:[UIColor colorWithHexColorString:@"333333"]
         
                              range:NSMakeRange(0, douzi.length)];
        
        NSString *present = [NSString stringWithFormat:@" 另赠送%ld金豆",(long)model.present];
        NSMutableAttributedString *AttPresent = [[NSMutableAttributedString alloc]initWithString:present];
        [AttPresent addAttribute:NSFontAttributeName
         
                           value:[UIFont systemFontOfSize:12]
         
                           range:NSMakeRange(0, present.length)];
        
        [AttPresent addAttribute:NSForegroundColorAttributeName
         
                           value:[UIColor colorWithHexColorString:@"888888"]
         
                           range:NSMakeRange(0, present.length)];
        
        [AttributedStr appendAttributedString:AttPresent];
        
        
        cell.douziLabel.attributedText = AttributedStr;
    }
    
    
//    cell.douziLabel.text = [NSString stringWithFormat:@"%ld",(long)model.goldBeans];
//    cell.textLabel.text = [NSString stringWithFormat:@"aaaa - %ld",(long)indexPath.row];
    if (indexPath.row == self.dataSource.count-1) {
        cell.fengeLabelH.constant = 0;
    }else{
        cell.fengeLabelH.constant = SINGLE_LINE_WIDTH;
    }
    return cell;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return self.hdView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 190;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self chongzhiWith:indexPath.row];
}

@end

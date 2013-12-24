//
//  AddBuddyViewCtl.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "AddBuddyViewCtl.h"

@interface AddBuddyViewCtl ()

@end

@implementation AddBuddyViewCtl

#pragma mark -life circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

//    UIBarButtonItem *addBuddyItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleBordered target:self action:@selector(addButty)];
//    [self.navigationItem setRightBarButtonItem:addBuddyItem];
//    [addBuddyItem release];
    
    [self CGRectMakeNavBar];
    
    //搜索框
    UIView *searchView=[[UIView alloc]init];
    searchView.frame=CGRectMake(0, 44, 320, 44);
    searchView.backgroundColor=[UIColor colorWithRed:(89/255.0) green:(86/255.0) blue:(87/255.0) alpha:1];
    [self.view addSubview:searchView];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame=CGRectMake(280, 54, 40, 30);
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addButty) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

#pragma mark -创建View
#pragma mark 创建navbar
-(void)CGRectMakeNavBar
{
    UIView *naView=[[UIView alloc]init];
    naView.backgroundColor=[UIColor colorWithRed:(37/255.0) green:(23/255.0) blue:(10/255.0) alpha:1];
    naView.frame=CGRectMake(0, 0, 320, 44);
    [self.view addSubview:naView];
    
    UILabel *zhLabel=[[UILabel alloc]initWithFrame:CGRectMake(140, 4, 200, 40)];
    zhLabel.text=@"添加联系人";
    zhLabel.font=[UIFont boldSystemFontOfSize:20];//字体需要调整
    zhLabel.backgroundColor=[UIColor clearColor];
    zhLabel.textColor=[UIColor colorWithRed:(225/255.0) green:(242/255.0) blue:(0/255.0) alpha:1];
    [naView addSubview:zhLabel];
    
    UIButton *backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    backbutton.frame=CGRectMake(20, 15, 18, 18);
    [backbutton setBackgroundImage:[UIImage imageNamed:@"topback_yellow@2x.png"] forState:UIControlStateNormal];
    [backbutton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [naView addSubview:backbutton];
}
//23根据用户名搜索用户
//请求地址	http://116.12.56.40/api.php?m=users&a=getuserList&username=2
//请求方式	request
//输入参数	Username：用户名（根据要求输出数据只显示一条）
//输出参数(json)	成功返回
//{"result":1,"result_text":"\u6210\u529f\uff01","list":{"0":"2","id":1,"1":"a2","username":"a2","2":"boxilai","name":"shanghai","3":"1111111","disc":"1111111","4":1,"city_id":1,"5":"5f4dcc3b5aa765d61d8327deb882cf99","password":"5f4dcc3b5aa765d61d8327deb882cf99","6":"tanggod@gmail.com","email":"tanggod@gmail.com","7":"1231231243","phonenum":"1231231243","8":"Uploads\/images\/2013-10-22\/5265d7b22d4c6.png","photopath":"Uploads\/images\/2013-10-22\/5265d7b22d4c6.png","9":1,"10":"shanghai","11":1,"country_id":1},"total_count":1}
-(void)back
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setBuddyNameField:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
-(void)addButty{
    [[XMPPServer xmppRoster] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //XMPPHOST 就是服务器名，  主机名
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",self.buddyNameField.text,OpenFireHostName]];
    //[presence addAttributeWithName:@"subscription" stringValue:@"好友"];
    [[XMPPServer xmppRoster] subscribePresenceToUser:jid];
//    [XMPPHelper xmppRoster]
    
    [self.view endEditing:YES];
    
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"添加好友结果" message:@"SUCCESS!!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
     */
}

@end

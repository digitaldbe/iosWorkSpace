//
//  GPeopleViewController.m
//  BaseProject
//
//  Created by ioschen on 13-12-9.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "GPeopleViewController.h"

@interface GPeopleViewController ()

@end

@implementation GPeopleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithRed:(217/255.0) green:(220/255.0) blue:(219/255.0) alpha:1]];
    [self CGRectMakeNavBar];
    [self CGRectMakePeopleView];
}
#pragma mark -创建View
#pragma mark 创建navbar
-(void)CGRectMakeNavBar
{
    UIView *naView=[[UIView alloc]init];
    naView.backgroundColor=[UIColor colorWithRed:(37/255.0) green:(23/255.0) blue:(10/255.0) alpha:1];
    naView.frame=CGRectMake(0, 0, 320, 44);
    [self.view addSubview:naView];
    
    UILabel *zhLabel=[[UILabel alloc]initWithFrame:CGRectMake(140, 4, 100, 40)];
    zhLabel.text=@"群聊的名字";
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
-(void)back
{
    [self dismissModalViewControllerAnimated:YES];
}
//2.根据 群名 获取所有用户的接口
//请求地址	 http://116.12.56.40/api.php?m=group&a=groupUsers&groupname=test
//
//请求方式	request
//传入值	groupname:群组名
//输入参数	成功返回
//{"result":1,"result_text":"\u67e5\u8be2\u6210\u529f","list":[{"username":"a2","administrator":0},{"username":"a3","administrator":0},{"username":"a4","administrator":0},{"username":"a5","administrator":0}]}
//
//3.根据 创建组用户
//请求地址	http://116.12.56.40:9090/plugins/groupservice/group?action=addGroupUsers&adminname=a3&groupname=t2&usernames=a2,a4
//请求方式	request
//传入值	groupname:群组名
//输入参数	成功返回
//{"result":1,"result_text":"create success"}
//
//
//7. 判断是否为管理员
//请求地址	http://116.12.56.40/api.php?m=group&a=isGroupAdmin&adminname=a2&groupname=test
//请求方式
//输入参数	成功返回
//{"result":1,"result_text":"\u6210\u529f"}
//
//4.根据 删除组用户
//请求地址	http://116.12.56.40:9090/plugins/groupservice/group?action=delGroupUsers&adminname=a3&groupname=t4&usernames=a2,a4
//请求方式	request
//传入值	adminname：群主名
//groupname：组名
//usernames：用户名
//输入参数	成功返回
//{"result":1,"result_text":"create success"}


-(void)CGRectMakePeopleView
{
    NSLog(@"头像加");
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 60,66, 66)];
    imageView.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
    [self.view addSubview:imageView];
    UILabel *namelabel=[[UILabel alloc]init];
    namelabel.frame=CGRectMake(20, 130, 66, 20);
    namelabel.text=@"Best";
    namelabel.textColor=[UIColor grayColor];
    namelabel.backgroundColor=[UIColor clearColor];
    [self.view addSubview:namelabel];
    
    UIImageView *imageViea=[[UIImageView alloc]initWithFrame:CGRectMake(80, 60,66, 66)];
    imageViea.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
    [self.view addSubview:imageViea];
    UILabel *namelabea=[[UILabel alloc]init];
    namelabea.frame=CGRectMake(90, 130, 66, 20);
    namelabea.text=@"Best";
    namelabea.textColor=[UIColor grayColor];
    namelabea.backgroundColor=[UIColor clearColor];
    [self.view addSubview:namelabea];
    
    UIImageView *imageVieb=[[UIImageView alloc]initWithFrame:CGRectMake(150, 60,66, 66)];
    imageVieb.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
    [self.view addSubview:imageVieb];
    UILabel *namelabeb=[[UILabel alloc]init];
    namelabeb.frame=CGRectMake(160, 130, 66, 20);
    namelabeb.text=@"Best";
    namelabeb.textColor=[UIColor grayColor];
    namelabeb.backgroundColor=[UIColor clearColor];
    [self.view addSubview:namelabeb];
    
    UIImageView *imageViec=[[UIImageView alloc]initWithFrame:CGRectMake(220, 60,66, 66)];
    imageViec.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
    [self.view addSubview:imageViec];
    UILabel *namelabec=[[UILabel alloc]init];
    namelabec.frame=CGRectMake(230, 130, 66, 20);
    namelabec.text=@"Best";
    namelabec.textColor=[UIColor grayColor];
    namelabec.backgroundColor=[UIColor clearColor];
    [self.view addSubview:namelabec];
    
    UIImageView *imageAdd=[[UIImageView alloc]initWithFrame:CGRectMake(10, 150,66, 66)];
    imageAdd.image=[UIImage imageNamed:@"topaddfriend_chat.png"];
    [self.view addSubview:imageAdd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  UserinfoViewController.m
//  BaseProject
//
//  Created by ioschen on 13-12-4.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "UserinfoViewController.h"
//#import "ChatViewController.h"
#import "YUChatViewController.h"
@interface UserinfoViewController ()
{
    NSString *chatUserName;
}
@end

@implementation UserinfoViewController
@synthesize chatUser;
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
    [self CGRectMainView];
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
    zhLabel.text=@"详细资料";
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
-(void)CGRectMainView
{
    UIImageView *imageview=[[UIImageView alloc]init];
    imageview.frame=CGRectMake(20, 60, 80, 80);
    imageview.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
    [self.view addSubview:imageview];
    
    UILabel *namelabel=[[UILabel alloc]init];
    namelabel.frame=CGRectMake(111, 60, 100, 40);
    namelabel.backgroundColor=[UIColor clearColor];
    namelabel.text=@"Name";
    [self.view addSubview:namelabel];
    UILabel *idlabel=[[UILabel alloc]init];
    idlabel.frame=CGRectMake(111, 100, 100, 40);
    idlabel.backgroundColor=[UIColor clearColor];
    idlabel.textColor=[UIColor grayColor];
    idlabel.text=[NSString stringWithFormat:@"ID: %@",[[self.chatUser componentsSeparatedByString:@"@"] objectAtIndex:0]];
    [self.view addSubview:idlabel];
    
    //第一个背景
    UIImageView *imageviewone=[[UIImageView alloc]init];
    imageviewone.frame=CGRectMake(20, 158, 280, 40);
    imageviewone.image=[UIImage imageNamed:@"box2_setting3@2x.png"];
    [self.view addSubview:imageviewone];
    UILabel *addresstextlabel=[[UILabel alloc]init];
    addresstextlabel.frame=CGRectMake(20, 10, 100, 20);
    addresstextlabel.backgroundColor=[UIColor clearColor];
    addresstextlabel.text=@"地区";
    addresstextlabel.textColor=[UIColor grayColor];
    [imageviewone addSubview:addresstextlabel];
    UILabel *addresslabel=[[UILabel alloc]init];
    addresslabel.frame=CGRectMake(120, 10, 100, 20);
    addresslabel.backgroundColor=[UIColor clearColor];
    addresslabel.text=@"大陆";
    [imageviewone addSubview:addresslabel];
    //第二个背景
    UIImageView *imageviewtwo=[[UIImageView alloc]init];
    imageviewtwo.frame=CGRectMake(20, 199, 280, 80);
    imageviewtwo.image=[UIImage imageNamed:@"box2_setting1@2x.png"];
    [self.view addSubview:imageviewtwo];
    UILabel *infotetxlabel=[[UILabel alloc]init];
    infotetxlabel.frame=CGRectMake(20, 20, 100, 40);
    infotetxlabel.backgroundColor=[UIColor clearColor];
    infotetxlabel.text=@"个性签名";
    infotetxlabel.textColor=[UIColor grayColor];
    [imageviewtwo addSubview:infotetxlabel];
    UILabel *infolabel=[[UILabel alloc]init];
    infolabel.frame=CGRectMake(120, 20, 100, 40);
    infolabel.backgroundColor=[UIColor clearColor];
    infolabel.text=@"义薄云天";
    [imageviewtwo addSubview:infolabel];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame=CGRectMake(110, 300, 80, 40);
    [button setTitle:@"发消息" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
-(void)chat
{
    //ChatViewController *chatViewCtl = [[ChatViewController alloc] init];
    YUChatViewController *chatViewCtl=[[YUChatViewController alloc]init];
    chatViewCtl.chatWithUser = chatUser;
    [chatViewCtl setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:chatViewCtl animated:YES];
    //[self.navigationController pushViewController:chatViewCtl animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

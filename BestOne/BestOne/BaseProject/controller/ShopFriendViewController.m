//
//  ShopFriendViewController.m
//  BaseProject
//
//  Created by ioschen on 13-12-4.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "ShopFriendViewController.h"

@interface ShopFriendViewController ()

@end

@implementation ShopFriendViewController

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
    //电子书文图collectionview也一样
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
    zhLabel.text=@"商家朋友";
    zhLabel.font=[UIFont boldSystemFontOfSize:20];//字体需要调整
    zhLabel.backgroundColor=[UIColor clearColor];
    zhLabel.textColor=[UIColor colorWithRed:(225/255.0) green:(242/255.0) blue:(0/255.0) alpha:1];
    [naView addSubview:zhLabel];
    
    UIButton *backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    backbutton.frame=CGRectMake(20, 15, 18, 18);
    [backbutton setBackgroundImage:[UIImage imageNamed:@"topback_yellow@2x.png"] forState:UIControlStateNormal];
    [backbutton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [naView addSubview:backbutton];
    
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 60, 100, 100)];
    imageView.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
    [self.view addSubview:imageView];
    
    UILabel *namelabel=[[UILabel alloc]init];
    namelabel.frame=CGRectMake(20, 165, 180, 20);
    namelabel.text=@"Best one";
    namelabel.textColor=[UIColor grayColor];
    namelabel.backgroundColor=[UIColor clearColor];
    [self.view addSubview:namelabel];
}
-(void)back
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  SeePictureViewController.m
//  BestOne
//
//  Created by ioschen on 13-12-13.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import "SeePictureViewController.h"

@interface SeePictureViewController ()

@end

@implementation SeePictureViewController
@synthesize url;
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
    [self CGRectMakeNavBar];
    
    UIImageView *bigImage=[[UIImageView alloc]init];
    UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    bigImage.image=image;
    //bigImage.frame=CGRectMake(20, 80, 250, 360);
    bigImage.frame=CGRectMake(1, 50, image.size.width/2, image.size.height/2);
    [self.view addSubview:bigImage];
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
    zhLabel.text=@"picture";
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
    //    BuddyViewController *buddyview=[[BuddyViewController alloc]init];
    //    [self presentModalViewController:buddyview animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

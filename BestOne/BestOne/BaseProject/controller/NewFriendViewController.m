//
//  NewFriendViewController.m
//  BaseProject
//
//  Created by ioschen on 13-12-4.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "NewFriendViewController.h"

@interface NewFriendViewController ()

@end

@implementation NewFriendViewController

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
    self.view.backgroundColor=[UIColor whiteColor];
    [self CGRectMakeNavBar];
    newList=[[NSMutableArray alloc]initWithObjects:@"张三",@"李四",@"王武",@"眔", nil];
    [self CGRectMakeTableView];
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
    zhLabel.text=@"新朋友";
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
#pragma mark CGRectMakeTableView
-(void)CGRectMakeTableView
{
    newTable=[[UITableView alloc]initWithFrame:CGRectMake(0,44,self.view.frame.size.width, [newList count]*44) style:UITableViewStylePlain];
    newTable.dataSource=self;
    newTable.delegate=self;
    [self.view addSubview:newTable];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [newList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:TableSampleIdentifier];
    }
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
    imageView.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
    [cell.contentView addSubview:imageView];
    
    UILabel *namelabel=[[UILabel alloc]init];
    namelabel.frame=CGRectMake(80, 10, 180, 20);
    namelabel.text=[newList objectAtIndex:indexPath.row];
    //namelabel
    [cell.contentView addSubview:namelabel];

    UILabel *timelabel=[[UILabel alloc]init];
    timelabel.frame=CGRectMake(210, 10, 180, 20);
    switch (indexPath.row) {
        case 0:
            timelabel.text=@"等待验证";
            break;
        case 1:
            timelabel.text=@"接受按钮";
        case 2:
            timelabel.text=@"已添加";
        case 3:
            timelabel.text=@"添加按钮";
        default:
            break;
    }
    timelabel.textColor=[UIColor grayColor];
    [cell.contentView addSubview:timelabel];
    
    //cell.textLabel.text=[newList objectAtIndex:indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

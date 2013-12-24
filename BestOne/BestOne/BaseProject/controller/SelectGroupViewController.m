//
//  SelectGroupViewController.m
//  BaseProject
//
//  Created by ioschen on 13-12-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "SelectGroupViewController.h"
#import "GroupChatViewController.h"
@interface SelectGroupViewController ()

@end

@implementation SelectGroupViewController
@synthesize groupList;
@synthesize descriptionArray;
@synthesize administratorArray;
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
    [self.view setBackgroundColor:[UIColor colorWithRed:(217/255.0) green:(220/255.0) blue:(219/255.0) alpha:1]];
	// Do any additional setup after loading the view.
    [self CGRectMakeNavBar];
    administratorArray=[[NSMutableArray alloc]init];
    descriptionArray=[[NSMutableArray alloc]init];
    groupList=[[NSMutableArray alloc]init];
    [self getAllgroup];
    
    //groupList=[[NSMutableArray alloc]initWithObjects:@"sanre(3)",@"iosjsjsj(34)",@"nimei(6)", nil];
    groupTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 44, 320, [groupList count]*80) style:UITableViewStylePlain];
    groupTable.dataSource=self;
    groupTable.delegate=self;
    [self.view addSubview:groupTable];
}
#pragma mark -
#pragma mark 根据用户查所有群组
-(void)getAllgroup
{
    NSError *error;
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://116.12.56.40/api.php?m=group&a=userGroups&username=a2"]];
    //a2改成当前用户
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    NSDictionary *groupDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    //暂时不判断result=1
    NSArray *groupArray=[groupDic objectForKey:@"list"];
    NSLog(@"%@",groupArray);
    for (int i=0; i<[groupArray count]; i++) {
        [administratorArray addObject:[[groupArray objectAtIndex:i]objectForKey:@"administrator"]];
        [descriptionArray addObject:[[groupArray objectAtIndex:i]objectForKey:@"description"]];
        [groupList addObject:[[groupArray objectAtIndex:i]objectForKey:@"groupName"]];
    }
    NSLog(@"%@",administratorArray);
    NSLog(@"%@",descriptionArray);
    NSLog(@"%@",groupList);
}

//6.删除组
//请求地址	http://116.12.56.40:9090/plugins/groupservice/group?action=createGroup&adminname=a3&groupname=t2
//请求方式	request
//传入值	adminname：群主名
//groupname：组名
//usernames：用户名
//输入参数	成功返回
//{"result":1,"result_text":"create success"}
//
//
//7. 判断是否为管理员
//请求地址	http://116.12.56.40/api.php?m=group&a=isGroupAdmin&adminname=a2&groupname=test
//请求方式
//输入参数	成功返回
//{"result":1,"result_text":"\u6210\u529f"}

#pragma mark -创建View
#pragma mark 创建navbar
-(void)CGRectMakeNavBar
{
    UIView *naView=[[UIView alloc]init];
    naView.backgroundColor=[UIColor colorWithRed:(37/255.0) green:(23/255.0) blue:(10/255.0) alpha:1];
    naView.frame=CGRectMake(0, 0, 320, 44);
    [self.view addSubview:naView];
    
    UILabel *zhLabel=[[UILabel alloc]initWithFrame:CGRectMake(140, 4, 100, 40)];
    zhLabel.text=@"选择群组";
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
-(void)back{
    [self dismissModalViewControllerAnimated:YES];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupList count];
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
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
    imageView.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
    [cell.contentView addSubview:imageView];
    
    UILabel *namelabel=[[UILabel alloc]init];
    namelabel.frame=CGRectMake(80, 40, 180, 20);
    namelabel.text=[groupList objectAtIndex:indexPath.row];
    [cell.contentView addSubview:namelabel];
    
    //cell.textLabel.text=[groupList objectAtIndex:indexPath.row];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"群聊，点击群聊右上方图标进去群联系人列表，里面还可以点击");
    GroupChatViewController *groupChat=[[GroupChatViewController alloc]init];
    [self presentModalViewController:groupChat animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

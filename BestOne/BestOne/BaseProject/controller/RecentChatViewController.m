//
//  RecentChatViewController.m
//  BaseProject
//
//  Created by ioschen on 13-11-28.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "RecentChatViewController.h"
#import "BuddyViewController.h"
#import "ChatViewController.h"
#import "YUChatViewController.h"
//#import "GroupViewController.h"
#import "SelectPeopleViewController.h"
#import "YUCardCell.h"
@interface RecentChatViewController ()

@end

@implementation RecentChatViewController
@synthesize recentList;
@synthesize touImageDict;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
//        UIBarButtonItem *txlButton=[[UIBarButtonItem alloc] initWithTitle:@"群聊" style:UIBarButtonItemStylePlain target:self action:@selector(btnAction:)];
//        txlButton.tag=102;
//        UIBarButtonItem *qlButton = [[UIBarButtonItem alloc] initWithTitle:@"通讯录" style:UIBarButtonItemStylePlain target:self action:@selector(btnAction:)];
//        qlButton.tag=101;
//        NSArray *rightButtons=[NSArray arrayWithObjects:txlButton,qlButton, nil];
//        self.navigationItem.rightBarButtonItems=rightButtons;
    }
    return self;
}
#pragma mark -
#pragma mark 根据用户名查询用户头像
-(void)getTouXiang:(NSString *)Tusername
{
    NSError *error;
    NSString *stringurl=[NSString stringWithFormat:@"http://116.12.56.40/api.php?m=users&a=getuserList&username=%@",Tusername];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:stringurl]];//a2改成当前用户
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *groupDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    //暂时不判断result=1
    NSLog(@"用户头像%@",groupDic);
    linshiImage=[[NSString alloc]init];
    linshiImage=[FTPURL stringByAppendingString:[[[groupDic objectForKey:@"list"]objectAtIndex:0]objectForKey:@"photopath"]];
    NSLog(@"%@",[FTPURL stringByAppendingString:[[[groupDic objectForKey:@"list"]objectAtIndex:0]objectForKey:@"photopath"]]);
}
-(void)selectTouxiang
{
    for (int i=0; i<[recentList count]; i++) {
        [self getTouXiang:[recentList objectAtIndex:i]];
        UIImage *image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:linshiImage]]];
        NSData *Imagedata=UIImageJPEGRepresentation(image, 1.0);
        //创建文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //获取路径,参数NSDocumentDirectory要获取那种路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];//获得需要的路径
        //切换成当前目录
        [fileManager changeCurrentDirectoryPath:[documentsDirectory stringByExpandingTildeInPath]];
        
        NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
        [dateformat setDateFormat:@"yyyyMMddHHmmss"];
        NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
        NSString *filename=[[dateformat stringFromDate:[NSDate date]]stringByAppendingString:@".png"];
        
        //创建文件fileName文件名称，contents文件的内容，如果开始没有内容可以设置为nil，attributes文件的属性，初始为nil
        [fileManager createFileAtPath:filename contents:nil attributes:nil];
        //[fileManager removeItemAtPath:@"createdNewFile" error:nil];//删除待删除的文件
        NSString *path=[documentsDirectory stringByAppendingPathComponent:filename];
        [Imagedata writeToFile:path atomically:YES];
        NSLog(@"%@",path);
        [touImageDict setObject:path forKey:[recentList objectAtIndex:i]];
    }
    NSLog(@"%@所有用户头像%@",recentList,touImageDict);
    [recentTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    recentList=[[NSMutableArray alloc]init];
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"headImage"ofType:@"plist"];
    touImageDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    allrecent=[[NSMutableDictionary alloc]init];
    [self CGRectMakeNavBar];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    //dbPath： 数据库路径，在Document中。
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"Test.db"];
    //创建数据库实例 db  这里说明下:如果路径中不存在"Test.db"的文件,sqlite会自动创建"Test.db"
    db= [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return ;
    }
    [self ssf];
    //[NSThread detachNewThreadSelector:@selector(selectTouxiang) toTarget:self withObject:nil];
    [self CGRectMakeTableView];
}
                                            
//用来判断或者提前判断，在读取
#pragma mark 创建表
-(void)ssf
{
    //a2是receiver   no must
    NSString * sql = [NSString stringWithFormat:
                      @"SELECT * FROM %@ WHERE receiver = '%@' or sender = '%@'",TABLENAME,@"a2",@"a2"];
    //sender is me(get receiver)  or receiver is me(get sender)   isread messages
    NSLog(@"%@",sql);
    [self selectSql:sql];
    //查询只要sender和receiver不要username
}
#pragma mark 查
-(void)selectSql:(NSString *)sql
{
    NSLog(@"查");
    if ([db open]) {
        [recentList removeAllObjects];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            //int Id = [rs intForColumn:ID];
            NSString * chatReceiver = [rs stringForColumn:RECEIVER];
//            int chatIsread=[rs intForColumn:ISREAD];
            NSLog(@"%@",chatReceiver);
            [allrecent setObject:@"user" forKey:chatReceiver];
            recentList=[NSMutableArray arrayWithArray:[allrecent allKeys]];
        }
        [db close];
    }else{
        NSLog(@"no open");
    }
    NSLog(@"天天苍苍苍苍野野茫茫茫茫%@",recentList);
}
#pragma mark -创建View
#pragma mark 创建navbar
-(void)CGRectMakeNavBar
{
    UIView *naView=[[UIView alloc]init];
    naView.backgroundColor=[UIColor colorWithRed:(37/255.0) green:(23/255.0) blue:(10/255.0) alpha:1];
    naView.frame=CGRectMake(0, 0, 320, 44);
    [self.view addSubview:naView];
    
    UILabel *zhLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 4, 100, 40)];
    zhLabel.text=@"聊天";
    zhLabel.font=[UIFont boldSystemFontOfSize:20];//字体需要调整
    zhLabel.backgroundColor=[UIColor clearColor];
    zhLabel.textColor=[UIColor colorWithRed:(225/255.0) green:(242/255.0) blue:(0/255.0) alpha:1];
    [naView addSubview:zhLabel];
    
    UIButton *txlbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    txlbutton.frame=CGRectMake(220, 12, 32, 23);//通讯录
    [txlbutton setBackgroundImage:[UIImage imageNamed:@"topcontact@2x.png"] forState:UIControlStateNormal];
    txlbutton.tag=101;
    [txlbutton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [naView addSubview:txlbutton];
    
    UIButton *qlbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    qlbutton.frame=CGRectMake(280, 12, 23, 23);//聊天
    [qlbutton setBackgroundImage:[UIImage imageNamed:@"topgroup@2x.png"] forState:UIControlStateNormal];
    qlbutton.tag=102;
    [qlbutton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [naView addSubview:qlbutton];
}
#pragma mark CGRectMakeTableView
-(void)CGRectMakeTableView
{
    recentTable=[[UITableView alloc]initWithFrame:CGRectMake(0,44,self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    recentTable.dataSource=self;
    recentTable.delegate=self;
    [self.view addSubview:recentTable];
    
    //搜索框
    UIView *searchView=[[UIView alloc]init];
    searchView.frame=CGRectMake(0, 44, 320, 44);
    searchView.backgroundColor=[UIColor colorWithRed:(89/255.0) green:(86/255.0) blue:(87/255.0) alpha:1];
    recentTable.tableHeaderView=searchView;
    UISearchBar* searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(20, 7, 308, 29)];
    searchBar.placeholder=@"搜索朋友";
    searchBar.backgroundColor=[UIColor clearColor];//修改搜索框背景
    searchBar.translucent = YES;//指定控件是否会有透视效果
    //去掉搜索框背景
    //1.
    [[searchBar.subviews objectAtIndex:0]removeFromSuperview];
    //2.
    for (UIView *subview in searchBar.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }
    //3自定义背景
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box1_searchchat.png"]];
    [searchBar insertSubview:imageView atIndex:1];
    //[imageView release];
    [searchView addSubview:searchBar];
    
//    //改变搜索按钮文字
//    //改变UISearchBar取消按钮字体
//    for(id cc in [searchBar subviews])
//    {
//        if([cc isKindOfClass:[UIButton class]])
//        {
//            UIButton *btn = (UIButton *)cc;
//            [btn setTitle:@"搜索"  forState:UIControlStateNormal];
//        }
//    }
}
//4输入搜索文字时隐藏搜索按钮，清空时显示
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsScopeBar = YES;
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    searchBar.showsScopeBar = NO;
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [recentList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cardCell";
    YUCardCell *cell =(YUCardCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[YUCardCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.namelabel.text=[recentList objectAtIndex:indexPath.row];
    NSURL *piUrl=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"file://localhost",[touImageDict objectForKey:[recentList objectAtIndex:indexPath.row]]]];
    cell.imageView.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:piUrl]];
    cell.infolabel.text=@"2";//最后一条信息
    cell.timelabel.text=@"s";//最后一条消息时间
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(void)btnAction:(id)sender{
    UIButton *t = (UIButton *)sender;
    switch (t.tag) {
        case 101:{
            BuddyViewController *bdVC = [[BuddyViewController alloc]init];
            [self presentModalViewController:bdVC animated:YES];
            //[self.navigationController pushViewController:bdVC animated:YES];
            //bdVC.title=@"通讯录";
            break;
        }case 102:{
            SelectPeopleViewController *select=[[SelectPeopleViewController alloc]init];
            [self presentModalViewController:select animated:YES];
//            GroupViewController *grVC = [[[GroupViewController alloc] init]autorelease];
//            [self presentModalViewController:grVC animated:YES];
//            //[self.navigationController pushViewController:grVC animated:YES];
//            grVC.title=@"群聊";暂时用自定义群聊，不用xmpp
            break;
        }
        default:
            break;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *user=[NSString stringWithFormat:@"%@",[recentList objectAtIndex:indexPath.row]];
    NSString *username=[user stringByAppendingString:@"@win-945i4ijdlln"];
    NSLog(@"%@",username);
    NSURL *piUrl=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"file://localhost",[touImageDict objectForKey:[recentList objectAtIndex:indexPath.row]]]];
    NSURL *pimeUrl=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"file://localhost",[touImageDict objectForKey:@"a2"]]];
    //ChatViewController *chatViewCtl = [[ChatViewController alloc] init];
    YUChatViewController *chatViewCtl = [[YUChatViewController alloc] init];
    chatViewCtl.chatWithUser =username;
    chatViewCtl.headImageurlstring=[piUrl absoluteString];
    chatViewCtl.headImagemeurlstring=[pimeUrl absoluteString];
    //如果没有默认
    [chatViewCtl setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:chatViewCtl animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

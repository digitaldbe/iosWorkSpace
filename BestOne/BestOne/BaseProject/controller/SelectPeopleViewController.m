//
//  SelectPeopleViewController.m
//  BaseProject
//
//  Created by ioschen on 13-12-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "SelectPeopleViewController.h"
#import "NameIndex.h"
#import "SelectGroupViewController.h"
@interface SelectPeopleViewController ()
@end

@implementation SelectPeopleViewController
@synthesize friendsList;
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
    selectArray=[[NSMutableArray alloc]init];
    [self CGRectMakeNavBar];
    [self CGRectMakeMainView];
    //[self.view setBackgroundColor:[UIColor r
    self.friendsList=[[NSMutableArray alloc]init];
    [self search];
    pngArray=[[NSMutableArray alloc]init];
    
    [peopleTable setEditing:YES animated:YES]; //显示多选圆圈
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
    zhLabel.text=@"选择联系人";
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
-(void)CGRectMakeMainView
{
    //搜索框
    UIView *searchView=[[UIView alloc]init];
    searchView.frame=CGRectMake(0, 44, 320, 44);
    searchView.backgroundColor=[UIColor colorWithRed:(89/255.0) green:(86/255.0) blue:(87/255.0) alpha:1];
    [self.view addSubview:searchView];
    
    //UISearchBar * searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    UISearchBar* searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(10, 2, 284, 29)];//568 58
    //searchBar.barStyle=UIBarStyleDefault;
    //searchBar.barStyle=UIBarStyleBlackOpaque;
    searchBar.barStyle=UIBarStyleBlack;
    searchBar.backgroundImage=[UIImage imageNamed:@"box1_searchchat@2x.png"];
//    searchBar.translucent = YES;
//    searchBar.barStyle = UIBarStyleBlackTranslucent;
//    //searchBar.showsCancelButton = YES;
//    [searchBar sizeToFit];
    [searchView addSubview:searchBar];
    //tableview
    peopleTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 88, 320, self.view.frame.size.height-96) style:UITableViewStylePlain];
    peopleTable.dataSource=self;
    peopleTable.delegate=self;
    [self.view addSubview:peopleTable];
    
    UIButton *sgbutton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    sgbutton.frame=CGRectMake(0, 2, 280, 80);
    [sgbutton setTitle:@"选择一个群" forState:UIControlStateNormal];
    [sgbutton addTarget:self action:@selector(selectGroup) forControlEvents:UIControlEventTouchUpInside];
    peopleTable.tableHeaderView=sgbutton;
    //添加进群view
    okView=[[UIView alloc]init];
    okView.frame=CGRectMake(0, self.view.frame.size.height-48, self.view.frame.size.width, 48);
    okView.backgroundColor=[UIColor colorWithRed:(89/255.0) green:(86/255.0) blue:(87/255.0) alpha:1];
    [self.view addSubview:okView];
    
    [self CGRectMakeScrollView];
    
    
    UIButton *okbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    okbutton.frame=CGRectMake(230, 4, 84, 34);
    [okbutton setBackgroundImage:[UIImage imageNamed:@"bottom3okchatgroup_a.png"] forState:UIControlStateNormal];
    [okbutton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];//人数0不可以点击
    [okView addSubview:okbutton];
    countLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 8, 20, 18)];
    countLabel.backgroundColor=[UIColor clearColor];
    [okbutton addSubview:countLabel];
    //创建一个label选择人数放进去放在按钮上面
}
-(void)CGRectMakeScrollView
{
    scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0, self.view.frame.size.width-90, 44)];//48
    //开启滚动分页功能，如果不需要这个功能关闭即可
    [scrollView setPagingEnabled:YES];
    //隐藏横向与纵向的滚动条,是否显示水平拖动条,是否显示竖直拖动条
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setDelegate:self];
    CGSize newSize = CGSizeMake([selectArray count]*50+50,0);
    [scrollView setContentSize:newSize];
    [okView addSubview:scrollView];//scrollView大小设置为按钮的个数x宽度加一个
    
    for (int i=0; i<[selectArray count]; i++) {
        button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame=CGRectMake(45*i, 2, 44, 44);
        [button setTitle:[selectArray objectAtIndex:i]forState:UIControlStateNormal];
        button.tag=i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
    }
    lineImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"box3_chatgroup.png"]];
    lineImageView.frame=CGRectMake([selectArray count]*50+5, 5, 40, 40);
    [scrollView addSubview:lineImageView];
}
-(void)buttonClick:(id)sender
{
    //其他的只需要在这里换数组就行了。数据放在这里，解析成数组。。
    UIButton *buttonC = (UIButton *)sender;
    //    buttonC.selected=!buttonC.selected;
    //    [buttonC setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    
    for (int j = 0; j<[selectArray count]; j++)
    {
        if (buttonC.tag==j)
        {
            
        }
    }
}
-(void)selectGroup
{
    SelectGroupViewController *selectGroup=[[SelectGroupViewController alloc]init];
    [self presentModalViewController:selectGroup animated:YES];
}
//5根据 创建组
//请求地址	http://116.12.56.40:9090/plugins/groupservice/group?action=createGroup&adminname=a3&groupname=t2
//请求方式	request
//传入值	adminname：群主名
//groupname：组名
//usernames：用户名
//输入参数	成功返回
//{"result":1,"result_text":"create success"}
//-------------------
#pragma mark
#pragma mark 构建列表索引
-(void)search
{
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];//这个是建立索引的核心
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
    //测试
    NSArray * nameArray = @[@"白飞",@"andy",@"张冲",@"林峰",@"kylin",@"王磊",@"emily",@"陈标",@"billy",@"q韦丽",@"wandy",@"e张冲",@"f林f峰",@"1kylin",@"e王e磊",@"cemily",@"3陈标",@"34billy",@"@韦丽",@"sandy",@"a张冲",@"f林峰",@"jkylin",@"k王磊",@"eemily",@"v陈标",@"xbilly",@"z韦丽",@"xandy",@"m张冲",@"n林峰",@"bkylin",@"j王磊",@"4ecmily",@"g陈标",@"dbilly",@"f韦f丽",@"vandy",@"w张冲",@"x林峰",@"tkylin",@"j王磊",@"gemily",@"e陈标",@"ebilly",@"e韦丽",@"fandy",@"s张冲",@"s林峰",@"lkylin",@"2王磊"];
    for (int i = 0; i<[nameArray count]; i++) {
        NameIndex *item = [[NameIndex alloc] init];
        item._lastName= [nameArray objectAtIndex:i];
        item._originIndex = i;
        [temp addObject:item];
    }
    
    
    //名字分section
    for (NameIndex *item in temp) {
        //getUserName是实现中文拼音检索的核心，见NameIndex类
        NSInteger sect = [theCollation sectionForObject:item collationStringSelector:@selector(getLastName)];
        //设定姓的索引编号
        item._sectionNum = sect;
    }
    
    //返回27，是a－z和＃
    NSInteger highSection = [[theCollation sectionTitles] count];
    //tableView 会被分成27个section
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i=0; i<=highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    //根据sectionNum把名字加入到对应section数组里
    for (NameIndex *item in temp) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:item._sectionNum] addObject:item];
    }
    //进行排序后，加入到数据源中
    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(getFirstName)]; //按firstName进行排序
        [self.friendsList addObject:sortedSection];//这里friendsList是自己定义的列表数据源
    }
}
#pragma mark 配置列表的delegate和datasource
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray * existTitles = [NSMutableArray array];
    NSArray * allTitles = [[UILocalizedIndexedCollation currentCollation]sectionTitles];
    //section数组为空的title过滤掉，不显示
    for (int i=0; i<[allTitles count]; i++) {
        if ([[self.friendsList objectAtIndex:i] count] > 0) {
            [existTitles addObject:[allTitles objectAtIndex:i]];
        }
    }
    return existTitles;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.friendsList count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.friendsList objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.friendsList objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
    imageView.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
    [cell.contentView addSubview:imageView];
    
    UILabel *namelabel=[[UILabel alloc]init];
    namelabel.frame=CGRectMake(80, 40, 180, 20);
    namelabel.text=[NSString stringWithFormat:@"%@",((NameIndex*)[[self.friendsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row])._lastName];
    //namelabel
    [cell.contentView addSubview:namelabel];
    
    
    //    cell.textLabel.text = [NSString stringWithFormat:@"%@%@",((NameIndex*)[[self.friendsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row])._lastName,((NameIndex*)[[self.friendsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row])._firstName];
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@",((NameIndex*)[[self.friendsList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row])._lastName];
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;//点击没有高亮显示;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma tableView delegate methods
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}
//添加一项
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"新添加了好友");
    [selectArray addObject:indexPath];
    NSLog(@"添加一项Select---->:%@",selectArray);
    CGSize newSize = CGSizeMake([selectArray count]*50+50,0);
    [scrollView setContentSize:newSize];
    selectpeopleButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    selectpeopleButton.tag=indexPath.section*10000+indexPath.row;
    [selectpeopleButton setTitle:[NSString stringWithFormat:@"%d",selectpeopleButton.tag] forState:UIControlStateNormal];
    selectpeopleButton.frame=CGRectMake([selectArray count]*50-50, 2, 44, 44);
    [scrollView addSubview:selectpeopleButton];
    
    lineImageView.frame=CGRectMake([selectArray count]*50+5, 5, 40, 40);
    countLabel.text=[NSString stringWithFormat:@"%d",[selectArray count]];
    //scrollview的frame相差一个单位
}
//取消一项
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [selectArray removeObject:indexPath];
    NSLog(@"取消一项Deselect---->:%@",selectArray);
    NSLog(@"%d",indexPath.section*1000+indexPath.row);
    if (selectpeopleButton.tag==(indexPath.section*10000+indexPath.row)) {
        [selectpeopleButton removeFromSuperview];
    }
    CGSize newSize = CGSizeMake([selectArray count]*50+50,0);
    [scrollView setContentSize:newSize];
    
    lineImageView.frame=CGRectMake([selectArray count]*50+5, 5, 40, 40);
    countLabel.text=[NSString stringWithFormat:@"%d",[selectArray count]];
    //scrollview的frame相差一个单位
}
////选择后
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"选择后%@",selectedDic);
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
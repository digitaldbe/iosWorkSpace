//
//  BuddyViewController.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "BuddyViewController.h"
//#import "ChatViewController.h"
#import "AddBuddyViewCtl.h"
#import "XMPPHelper.h"
#import "YUAppDelegate.h"

#import "NewFriendViewController.h"
#import "ShopFriendViewController.h"

#import "UserinfoViewController.h"

#import "RecentChatViewController.h"
@interface BuddyViewController (){
    
    //在线用户
    NSMutableArray *onlineUsers;
    //离线用户
    NSMutableArray *offlineUsers;
    
    NSString *chatUserName;
}
@property(nonatomic,retain) NSMutableArray *onlineUsers;
@property(nonatomic,retain) NSMutableArray *offlineUsers;

@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation BuddyViewController
@synthesize onlineUsers;
@synthesize offlineUsers;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//删除暂时没有，编辑tablevbiew暂时保留

//#pragma mark - life circle
//-(void)loadView{
//    [super loadView];
//    //删除好友
//    UIBarButtonItem *deleteBuddyItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(toDeleteButty)];
//    
//    
//    //添加好友
//    UIBarButtonItem *addBuddyItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toAddButty)];
//    
//    NSArray *arrayButton=[NSArray arrayWithObjects:addBuddyItem,deleteBuddyItem, nil];
//    [self .navigationItem setRightBarButtonItems:arrayButton];
//    //[arrayButton release];
//    [deleteBuddyItem release];
//    [addBuddyItem release];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.onlineUsers = [NSMutableArray array];
    self.offlineUsers = [NSMutableArray array];
    //设定在线用户委托
    [XMPPServer sharedServer].chatDelegate = self;
    UISearchBar *searchTxl=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchTxl.delegate=self;
    self.tableView.tableHeaderView=searchTxl;
    //[self.view addSubview:searchTxl];
    
    self.dataArray = [[NSMutableArray alloc]init];
    //[self getData];
    
    [self CGRectMakeNavBar];
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
    zhLabel.text=@"通讯录";
    zhLabel.font=[UIFont boldSystemFontOfSize:20];//字体需要调整
    zhLabel.backgroundColor=[UIColor clearColor];
    zhLabel.textColor=[UIColor colorWithRed:(225/255.0) green:(242/255.0) blue:(0/255.0) alpha:1];
    [naView addSubview:zhLabel];
    
    UIButton *backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    backbutton.frame=CGRectMake(20, 15, 18, 18);
    [backbutton setBackgroundImage:[UIImage imageNamed:@"topback_yellow@2x.png"] forState:UIControlStateNormal];
    [backbutton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [naView addSubview:backbutton];
    
    UIButton *addFriendbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    addFriendbutton.frame=CGRectMake(280, 15, 18, 18);
    [addFriendbutton setBackgroundImage:[UIImage imageNamed:@"topaddfriend_chat@2x.png"] forState:UIControlStateNormal];
    [addFriendbutton addTarget:self action:@selector(toAddButty) forControlEvents:UIControlEventTouchUpInside];
    [naView addSubview:addFriendbutton];
}
-(void)back
{
//    [self dismissModalViewControllerAnimated:YES];
    RecentChatViewController *recent=[[RecentChatViewController alloc]init];
    [self presentModalViewController:recent animated:YES];
}
//- (void)getData{
//    YUAppDelegate *delegate =[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = [[delegate xmppRosterStorage] mainThreadManagedObjectContext];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
//    NSFetchRequest *request = [[NSFetchRequest alloc]init];
//    [request setEntity:entity];
//    NSError *error ;
//    NSArray *friends = [context executeFetchRequest:request error:&error];
//    [self.dataArray removeAllObjects];
//    [self.dataArray addObjectsFromArray:friends];
//    NSLog(@"%@",self.dataArray);
//}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSLog(@"输出login%@",login);
    if (login) {
        if ([[XMPPServer sharedServer] connect]) {
            NSLog(@"show buddy list");
        }
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有设置账号" delegate:self cancelButtonTitle:@"设置" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    [self queryRoster];
}

-(void)queryRoster{
    /*
     <iq type="get"
     　　from="xiaoming@example.com"
     　　to="example.com"
     　　id="1234567">
     　　<query xmlns="jabber:iq:roster"/>
     <iq />
     */
    NSLog(@"------queryRoster------");  
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *myJID = [XMPPServer xmppStream].myJID;
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:myJID.domain];
    [iq addAttributeWithName:@"id" stringValue:@""];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:queryElement];
    NSLog(@"组装后的xml:%@",iq.stringValue);
    [[XMPPServer xmppStream] sendElement:iq];
}
//- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
//    NSString *userId = [[sender myJID] user];//当前用户
//    //    NSLog(@"didReceiveIQ--iq is:%@",iq.XMLString);
//    if ([@"result" isEqualToString:iq.type]) {
//        NSXMLElement *query = iq.childElement;
//        if ([@"query" isEqualToString:query.name]) {
//            NSArray *items = [query children];
//            for (NSXMLElement *item in items) {
//                //订阅签署状态
//                NSString *subscription = [item attributeStringValueForName:@"subscription"];
//                
//                if ([subscription isEqualToString:@"both"]) {
//                    NSString *jid = [item attributeStringValueForName:@"jid"];
//                    XMPPJID *xmppJID = [XMPPJID jidWithString:jid];
//                    
//                    //群组：
//                    NSArray *groups = [item elementsForName:@"group"];
//                    for (NSXMLElement *groupElement in groups) {
//                        NSString *groupName = groupElement.stringValue;
//                        
//                        //                        CHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//                        //                        [appDelegate.allUsers addObject:jid];
//                        //                        NSLog(@"所有用户%@",appDelegate.allUsers);
//                        NSLog(@"didReceiveIQ----xmppJID:%@ , in group:%@",jid,groupName);
//                        //[[XMPPServer xmppRoster] addUser:xmppJID withNickname:@""];
//                    }
//                }
//                
//                else if ([subscription isEqualToString:@"from"]){
//                    
//                }
//                
//                else if ([subscription isEqualToString:@"to"]){
//                    
//                }
//            }
//        }
//    }
//    return YES;
//}
//- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
//    if ([@"result" isEqualToString:iq.type]) {
//        NSXMLElement *query = iq.childElement;
//        if ([@"query" isEqualToString:query.name]) {
//            NSArray *items = [query children];
//            for (NSXMLElement *item in items) {
//                NSString *jid = [item attributeStringValueForName:@"jid"];
//                XMPPJID *xmppJID = [XMPPJID jidWithString:jid];
//                NSLog(@"获取当前用户在线%@",xmppJID);
//                //[self.allUsers addObject:xmppJID];
//            }
//        }
//    }
//}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        //[self toChat];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;//加一个固定的，字母排序后续
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section ==0) {
        return 2;
    }else if (section ==1) {
        return self.onlineUsers.count;
    }else if (section == 2){
        return self.offlineUsers.count;
    }
    return self.offlineUsers.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"userCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.section ==0)
    {
        if (indexPath.row==0) {
            cell.textLabel.text=@"新朋友";
            cell.imageView.image=[UIImage imageNamed:@"iconchatfriends.png"];
        }else if (indexPath.row==1){
            cell.textLabel.text=@"商家朋友";
            cell.imageView.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
        }
    }else if (indexPath.section ==1) {
        cell.textLabel.text = [self.onlineUsers objectAtIndex:[indexPath row]];
        
        //头像
        XMPPJID *jid = [XMPPJID jidWithString:cell.textLabel.text];
        UIImage *photo = [XMPPHelper xmppUserPhotoForJID:jid];
        if (photo)
            cell.imageView.image = photo;
        else
            cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
    }else if (indexPath.section ==2){
        cell.textLabel.text = [self.offlineUsers objectAtIndex:[indexPath row]];
        
        //头像
        XMPPJID *jid = [XMPPJID jidWithString:cell.textLabel.text];
        UIImage *photo = [XMPPHelper xmppUserPhotoForJID:jid];
        if (photo)
            cell.imageView.image = photo;
        else
            cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
    }
    
    //文本
    //cell.textLabel.text = [onlineUsers objectAtIndex:[indexPath row]];
    //标记
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex ==0){
        return nil;
    }else if (sectionIndex ==1) {
        return @"在线人员";
    }else if (sectionIndex ==2){
        return @"离线人员";
    }
    return @"好友列表";//暂时不要按字母排序(搜索)
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            NSLog(@"进去新朋友页面");
            NewFriendViewController *newFriend=[[NewFriendViewController alloc]init];
            [self presentModalViewController:newFriend animated:YES];
        }else if (indexPath.row==1){
            NSLog(@"进去商家朋友页面");
            ShopFriendViewController *shopFriend=[[ShopFriendViewController alloc]init];
            [self presentModalViewController:shopFriend animated:YES];
        }
    }else{
        chatUserName = (NSString *)[self.onlineUsers objectAtIndex:indexPath.row];
        UserinfoViewController *userinfo=[[UserinfoViewController alloc]init];
        userinfo.chatUser=chatUserName;
        [self presentModalViewController:userinfo animated:YES];
        
        //start a Chat
        
//        chatUserName = (NSString *)[self.onlineUsers objectAtIndex:indexPath.row];
//        
//        ChatViewController *chatViewCtl = [[ChatViewController alloc] init];
//        chatViewCtl.chatWithUser = chatUserName;
//        [chatViewCtl setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
//        [self presentModalViewController:chatViewCtl animated:YES];
//        //[self.navigationController pushViewController:chatViewCtl animated:YES];
//        [chatViewCtl release];
    }
}

//tableView的编辑模式中当提交一个编辑操作时候调用：比如删除，添加等
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        if (indexPath.section == 0) {
            [self.onlineUsers removeObjectAtIndex:indexPath.row];
        }else{
            [self.offlineUsers removeObjectAtIndex:indexPath.row];
        }
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        //解除服务器上好友关系
        XMPPJID *jid = [XMPPJID jidWithString:cell.textLabel.text];
        [[XMPPServer xmppRoster] removeUser:jid];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

//每次设置为编辑模式之前，都会访问这个方法：
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.tableView.tag;
    //尼玛，你这个编辑模式竟然可以把在线好友拖到离线里面，把离线好友拖拽到在线里面
}

//编辑模式的时候，拖动的时候会调用这个方法：
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    //TODO
}

#pragma mark - private 
//删除好友
-(void)toDeleteButty{
    self.tableView.tag = UITableViewCellEditingStyleDelete;//删除状态：以tag值来传递编辑状态
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
}

//添加好友
-(void)toAddButty{
    AddBuddyViewCtl *addBuddyCtl = [[AddBuddyViewCtl alloc] init];
    //[self.navigationController pushViewController:addBuddyCtl animated:YES];
    [self presentModalViewController:addBuddyCtl animated:YES];
}

#pragma mark - KKChatDelegate
//在线好友
-(void)newBuddyOnline:(NSString *)buddyName{
    if (![self.onlineUsers containsObject:buddyName]) {
        [self.onlineUsers addObject:buddyName];
        [self.offlineUsers removeObject:buddyName];
        [self.tableView reloadData];
    }
}

//好友下线
-(void)buddyWentOffline:(NSString *)buddyName{
    if (![self.offlineUsers containsObject:buddyName]) {
        [self.onlineUsers removeObject:buddyName];
        [self.offlineUsers addObject:buddyName];
        [self.tableView reloadData];
    }
}

@end


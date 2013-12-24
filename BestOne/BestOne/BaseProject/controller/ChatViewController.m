//
//  ChatViewController.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

/*
 内需要分开，都写在一个里面太乱，发送语音视频等应该重复利用，不是重写，copy
 。。。。。。。
 */

#import "ChatViewController.h"
#import "Statics.h"
#import "KKMessageCell.h"
#import "VoiceCell.h"
#import "VideoCell.h"
#import "NSString+Base64.h"//引入方法
#import "NSData+Base64.h"//字符串转换成data
//#import "BuddyViewController.h"
#import "PlayVideoViewController.h"
#import "SeePictureViewController.h"
#import "JumpWebViewController.h"

#import "RecentChatViewController.h"

#define padding 20

@interface ChatViewController (){
}
@property(nonatomic,retain)NSMutableArray *fmdbmessages;
@end

@implementation ChatViewController
@synthesize avPlay = _avPlay;

@synthesize chatWithUser = _chatWithUser;
@synthesize tView = _tView;
@synthesize messageTextField = _messageTextField;
@synthesize fmdbmessages = _fmdbmessages;
@synthesize sendView=_sendView;
//@synthesize sendButton=_sendButton;
@synthesize talkButton=_talkButton;
@synthesize keyButton=_keyButton;
@synthesize addButton=_addButton;
@synthesize recordBtn=_recordBtn;
@synthesize voiceurlstring;
#pragma mark - life circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self audio];
    voiceDictionary=[[NSMutableDictionary alloc]init];
    [self.recordBtn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [self.recordBtn addTarget:self action:@selector(btnUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordBtn addTarget:self action:@selector(btnDragUp:) forControlEvents:UIControlEventTouchDragExit];
    //[self.playBtn addTarget:self action:@selector(playRecordSound:) forControlEvents:UIControlEventTouchDown];
    /*
     UIControlEventTouchDown      // 按下
     UIControlEventTouchDragExit  // in到out触发
     UIControlEventTouchUpInside // 在按钮及其一定外围内松开
     */

    [self CGRectMakeNavBar];
    //[self.tabBarController.view setHidden:YES];
    self.fmdbmessages=[[NSMutableArray alloc]init];
//    fmdbdictionary=[[NSMutableDictionary alloc]init];
    [self createData];
    [self createTable];
    [self ssf];
    self.tView.delegate = self;
    self.tView.dataSource = self;
    self.tView.backgroundColor=[UIColor colorWithRed:(217/255.0) green:(220/255.0) blue:(219/255.0) alpha:0];
    //------------------------------------------------------
    UITapGestureRecognizer *tapRecognizer2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableviewClick)];
    self.tView.userInteractionEnabled=YES;
    [self.tView addGestureRecognizer:tapRecognizer2];
    //------------------------------------------------------
    //监视手势控制
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tView addGestureRecognizer:recognizer];
    
    self.tView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    [_messageTextField becomeFirstResponder];
    
    _messageTextField.delegate=self;
    [_messageTextField addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置信息代理
    [XMPPServer sharedServer].messageDelegate = self;
    
	// Do any additional setup after loading the view, typically from a nib.
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _keyButton.hidden=YES;
    _recordBtn.hidden=YES;//一开始语音隐藏
}
-(void)tableviewClick
{
    //键盘退出第一响应，位置，坐标还原
    //左边滑动事件  链接电话蓝色高亮显示，直接打开或者拨打
    //textview用可显示富文本的，显示表情
    //接收视频。图片显示进度条最没有必要吗
    //语音喇叭模式等
    [self.messageTextField resignFirstResponder];
    _sendView.frame=CGRectMake(0, self.view.frame.size.height-39, 320, 80);
}
#pragma mark 滑动退出
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    //如果往右滑
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"****************向右滑****************");
        RecentChatViewController *recentView=[[RecentChatViewController alloc]init];
        [self presentViewController:recentView animated:YES completion:nil];
    }
}
#pragma mark - 数据库
#pragma mark 创建数据库
-(void)createData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"Test.db"];
    //创建数据库实例 db  这里说明下:如果路径中不存在"Test.db"的文件,sqlite会自动创建"Test.db"
    //db=[[FMDatabase alloc]init];
    db= [FMDatabase databaseWithPath:dbPath] ;
    if (![db open]) {
        NSLog(@"数据库打开失败");
        return ;
    }
}

#pragma mark 创建表
-(void)createTable
{
    //add已读未读01
    if ([db open]) {
        //username是接收者
        NSLog(@"创建表");
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS PERSONINFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, sender TEXT, receiver TEXT, message TEXT, bigurl TEXT, sendtime TEXT, isread INTEGER, messagetype TEXT)"];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating db table");
        } else {
            NSLog(@"success to creating db table");
        }
        [db close];
    }else{
        NSLog(@"no open");
    }
}
#pragma mark 增
-(void)addSql:(NSString *)YUUsername andsender:(NSString *)YUSender andmessade:(NSString *)YUMessage andBigurl:(NSURL *)YUBigurl andsendtime:(NSString *)YUSendtime andisread:(int)YUIsread andReceiver:(NSString *)YUReceiver andMessagetype:(NSString *)YUMessagetype
{
    NSLog(@"添加");
    if ([db open]) {
        NSString *insertSql2=[NSString stringWithFormat:
                              @"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@','%@', '%@', '%@', '%@','%d', '%@', '%@')",
                              TABLENAME, USERNAME, SENDER, MESSAGE, BIGURL, SENDTIME,ISREAD,RECEIVER,MESSAGETYPE, YUUsername, YUSender, YUMessage, YUBigurl, YUSendtime,YUIsread,YUReceiver,YUMessagetype];
        BOOL res = [db executeUpdate:insertSql2];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
        [db close];
    }
    NSLog(@"添加");
}
-(void)ssf
{
    //这个要判断
    NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
    NSLog(@"array:%@",array);
    NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到
    
    NSString * sql = [NSString stringWithFormat:
                      @"SELECT * FROM %@ WHERE (sender = '%@' and receiver = '%@') or (sender = '%@' and receiver = '%@')",TABLENAME,@"a2",nowUser,nowUser,@"a2"];//sql都大写或者都小写
    NSLog(@"%@",sql);
    [self selectSql:sql];
    //查询只要sender和receiver不要username
}
#pragma mark 查
-(void)selectSql:(NSString *)sql
{
    NSLog(@"查");
    if ([db open]) {
        [self.fmdbmessages removeAllObjects];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            //int Id = [rs intForColumn:ID];
            NSString * chatUserName = [rs stringForColumn:USERNAME];
            NSString * chatSender = [rs stringForColumn:SENDER];
            NSString * chatMessage = [rs stringForColumn:MESSAGE];
            NSString * chatBigurl = [rs stringForColumn:BIGURL];
            NSString * chatSendtime = [rs stringForColumn:SENDTIME];
            NSString * chatReceiver = [rs stringForColumn:RECEIVER];
            NSString * chatMessagetype = [rs stringForColumn:MESSAGETYPE];
            int chatIsread=[rs intForColumn:ISREAD];
            //            NSLog(@"id=%d chatUserName=%@ chatSender=%@ chatMessage=%@ chatBigurl=%@ chatSendtime=%@",ID chatUserName,chatSender,chatMessage,chatBigurl,chatSendtime);
            NSLog(@"chatUserName=%@ chatSender=%@ chatMessage=%@ chatBigurl=%@ chatSendtime=%@ chatIsread=%d chatReceiver=%@ chatMessagetype=%@",chatUserName,chatSender,chatMessage,chatBigurl,chatSendtime,chatIsread,chatReceiver,chatMessagetype);
            
            fmdbdictionary=[[NSMutableDictionary alloc]init];
            [fmdbdictionary setObject:chatMessage forKey:@"msg"];
            [fmdbdictionary setObject:chatSender forKey:@"sender"];
            [fmdbdictionary setObject:chatSendtime forKey:@"time"];
            [fmdbdictionary setObject:chatMessagetype forKey:@"type"];
            [fmdbdictionary setObject:chatBigurl forKey:@"url"];
            [self.fmdbmessages addObject:fmdbdictionary];
        }
        [db close];
    }else{
        NSLog(@"no open");
    }
    //FMDB提供如下多个方法来获取不同类型的数据：
    //    intForColumn:
    //    longForColumn:
    //    longLongIntForColumn:
    //    boolForColumn:
    //    doubleForColumn:
    //    stringForColumn:
    //    dateForColumn:
    //    dataForColumn:
    //    dataNoCopyForColumn:
    //    UTF8StringForColumnIndex:
    //    objectForColumn:
    NSLog(@"天天苍苍苍苍野野茫茫茫茫%@",self.fmdbmessages);
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
    zhLabel.text=_chatWithUser;
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

- (void)viewDidUnload
{
    [self setTView:nil];
    [self setMessageTextField:nil];
    [self setSendView:nil];
    [self setTalkButton:nil];
    [self setKeyButton:nil];
    [self setAddButton:nil];
    [self setRecordBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat screenHeight = self.view.bounds.size.height;
    __block CGRect frame = self.sendView.frame;
    
    if (frame.origin.y != screenHeight - keyboardSize.height - 40.) {
        frame.origin.y = screenHeight - keyboardSize.height - 40.;//lxf
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.sendView.frame = frame;
                             
                         } completion:^(BOOL finished) {
                             self.sendView.frame = frame;
                         }];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat screenHeight = self.view.bounds.size.height;
    __block CGRect frame = self.sendView.frame;
    frame.origin.y = screenHeight- 40;//lxf
    self.sendView.frame = frame;
    
    //    [UIView animateWithDuration:fAniTimeSecond animations:^{
    //        self.viewItems.frame = frame;
    //    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    NSLog(@"Should");
//}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"Did");
    //_allView.frame=CGRectMake(0, 44, 320,self.view.frame.size.height-44-35-328);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return [self.messages count];
    if ([self.fmdbmessages count]==0) {
        return 0;
    }else{
        return [self.fmdbmessages count];
    }
    return [self.fmdbmessages count];}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dict = [self.fmdbmessages objectAtIndex:indexPath.row];
    NSLog(@"-------> %@",self.fmdbmessages);
    NSString *sender = [dict objectForKey:@"sender"];//发送者
    NSString *message = [dict objectForKey:@"msg"];//消息
    NSString *time = [dict objectForKey:@"time"];//时间
    NSString *type = [dict objectForKey:@"type"];//时间
    NSString *url = [dict objectForKey:@"url"];//时间
    NSLog(@"在本地转换后的聊天信息%@",message);
    if ([type isEqualToString:@"text"]) {
        NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
        [height setObject:@"text" forKey:@"Height"];
        NSLog(@"保存成功");
        static NSString *identifier = @"msgCell";
        KKMessageCell *cell =(KKMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[KKMessageCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        NSLog(@"文本开头");
        //判断解析
        CGSize textSize = {260.0 ,10000.0};
        CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
        size.width +=(padding/2);
        cell.messageContentView.text = message;
        cell.accessoryType = UITableViewCellAccessoryNone;
        //cell.userInteractionEnabled = NO;因为带电话发邮件所以要
        
        UIImage *bgImage = nil;
        
        UIImageView *headView=[[UIImageView alloc]init];
        headView.frame=CGRectMake(275, 30, 40, 40);
        headView.image=[UIImage imageNamed:@"iconchatfriends.png"];
        [cell.contentView addSubview:headView];
        
        UIImageView *headView2=[[UIImageView alloc]init];
        headView2.frame=CGRectMake(10, 30, 40, 40);
        headView2.image=[UIImage imageNamed:@"iconchatfriends.png"];
        [cell.contentView addSubview:headView2];
        
        //发送消息
        if ([sender isEqualToString:@"a2"]) {
            bgImage = [[UIImage imageNamed:@"GreenBubble2.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:15];
            
            //        [cell.messageContentView setFrame:CGRectMake(320-size.width - padding, padding*2, size.width, size.height)];
            [cell.messageContentView setFrame:CGRectMake(320-size.width - padding-50, padding*2, size.width+20, size.height)];//我把cell的长度加一点，就可以显示最后一个字符呢，不然永远显示不了最后一个字符，靠右显示的
            //[cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
            
            headView2.hidden=YES;
            //cell.headImageView.frame=CGRectMake(275, 30, 40, 40);
            //cell.headImageView.image=[UIImage imageNamed:@"iconchatfriends.png"];
        }else {
            //背景图
            bgImage = [[UIImage imageNamed:@"BlueBubble2.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
            [cell.messageContentView setFrame:CGRectMake(padding+50, padding*2, size.width+20, size.height)];
            
            headView.hidden=YES;
            //cell.headImageView.frame=CGRectMake(10, 30, 40, 40);
            
            //[cell.bgImageView setFrame:CGRectMake(cell.messageContentView.frame.origin.x - padding/2, cell.messageContentView.frame.origin.y - padding/2, size.width + padding, size.height + padding)];
            //cell.imageView.image=[UIImage imageNamed:@"iconchatfriends.png"];
        }
        //cell.contentView.backgroundColor=[UIColor clearColor];
        [cell.messageContentView setBackgroundColor:[UIColor grayColor]];
        cell.bgImageView.image = bgImage;
        cell.senderAndTimeLabel.text=[NSString stringWithFormat:@"%@ %@", sender, time];
        
        return cell;
    }else if ([type isEqualToString:@"voice"]){
        NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
        [height setObject:@"voice" forKey:@"Height"];
        NSLog(@"保存成功");
        
        static NSString *identifier = @"voCell";
        VoiceCell *vcell =(VoiceCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (vcell == nil) {
            vcell = [[VoiceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        vcell.accessoryType = UITableViewCellAccessoryNone;
        //vcell.userInteractionEnabled = NO;
        //发送消息//[sender isEqualToString:@"me"]
        if ([sender isEqualToString:@"a2"]) {
            [vcell.voicebutton setFrame:CGRectMake(110, 10, 160, 40)];
            [vcell.voicebutton addTarget:self action:@selector(playRecordSound:) forControlEvents:UIControlEventTouchUpInside];
            vcell.headImageView.frame=CGRectMake(275, 12, 40, 40);
        }else {
            [vcell.voicebutton setTitle:@"点击我播放语音" forState:UIControlStateNormal];
            [vcell.voicebutton setFrame:CGRectMake(padding+40, padding*2, 100+20, 40)];
            vcell.headImageView.frame=CGRectMake(5, 2, 40, 40);
        }
        vcell.selectionStyle = UITableViewCellSelectionStyleNone;
        vcell.senderAndTimeLabel.text=[NSString stringWithFormat:@"%@ %@",sender,time];
        return vcell;
    }else if ([type isEqualToString:@"picture"]){
        NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
        [height setObject:@"picture" forKey:@"Height"];
        NSLog(@"保存成功");
        static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                 TableSampleIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:TableSampleIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        if ([sender isEqualToString:@"a2"]) {
            UIImageView *ima=[[UIImageView alloc]init];
            NSURL *piUrl=[NSURL URLWithString:url];
            ima.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:piUrl]];
            NSLog(@"%@ image ur",url);
            ima.frame=CGRectMake(170, 10, 100, 100);
            [cell.contentView addSubview:ima];
            
            UITapGestureRecognizer *tapRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ClickEventOnImage:)];
            ima.userInteractionEnabled=YES;
            [ima addGestureRecognizer:tapRecognizer];
            
            UIButton *buurl=[[UIButton alloc]init];
            buurl.titleLabel.text=url;
            buurl.tag=9999;
            [buurl addTarget:self action:@selector(ClickEventOnImage:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:buurl];
            
            UIImageView *imHe=[[UIImageView alloc]init];
            imHe.frame=CGRectMake(275, 12, 40, 40);
            imHe.image=[UIImage imageNamed:@"iconchatfriends.png"];
            [cell.contentView addSubview:imHe];
        }else {
            UIImageView *ima=[[UIImageView alloc]init];
            NSURL *piUrl=[NSURL URLWithString:url];
            ima.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:piUrl]];
            ima.frame=CGRectMake(padding, padding*2, 100, 100);
            [cell.contentView addSubview:ima];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if ([type isEqualToString:@"video"]){
        NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
        [height setObject:@"video" forKey:@"Height"];
        NSLog(@"保存成功");
        static NSString *identifier = @"viCell";
        VideoCell *vdcell =(VideoCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (vdcell == nil) {
            vdcell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        vdcell.accessoryType = UITableViewCellAccessoryNone;
        if ([sender isEqualToString:@"a2"]) {
            [vdcell.videoButton setTitle:@"点击播放VIDEO" forState:UIControlStateNormal];
            [vdcell.videoButton setFrame:CGRectMake(120, 10, 150, 100)];
            vdcell.videoButton.tag=10000;
            [vdcell.videoButton setTitle:url forState:UIControlStateNormal];
            [vdcell.videoButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            
            vdcell.headImageView.frame=CGRectMake(275, 12, 40, 40);
        }else {
            [vdcell.videoButton setTitle:@"点击播放VIDEO" forState:UIControlStateNormal];
            [vdcell.videoButton setFrame:CGRectMake(padding, padding*2, 150, 100)];
            [vdcell.videoButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
            
            vdcell.headImageView.frame=CGRectMake(5, 2, 40, 40);
        }
        vdcell.selectionStyle = UITableViewCellSelectionStyleNone;
        return vdcell;
    }else{
        static NSString *identifier = @"voCell";
        VoiceCell *vcell =(VoiceCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (vcell == nil) {
            vcell = [[VoiceCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        }
        //发送消息
        if ([sender isEqualToString:@"me"]) {
            [vcell.voicebutton setFrame:CGRectMake(padding, padding*2, 100+20, 40)];
            
        }else {
            [vcell.voicebutton setFrame:CGRectMake(padding, padding*2, 100+20, 40)];
        }
        return vcell;
    }
}
#pragma mark
#pragma mark 点击图片放大显示，单独view
-(void) ClickEventOnImage:(id)sender
{
    UIButton *bu = (UIButton *)sender;
    if (bu.tag==9999) {
        NSLog(@"t.titleLabel.text  %@",bu.titleLabel.text);
    }
    NSURL *buUrl=[NSURL URLWithString:bu.titleLabel.text];
    NSLog(@"imageview点击事件ok");
//    JumpWebViewController *jump=[[JumpWebViewController alloc]init];
//    [self presentViewController:jump animated:YES completion:nil];
    SeePictureViewController *seepic=[[SeePictureViewController alloc]init];
    seepic.url=buUrl;
    [self presentViewController:seepic animated:YES completion:nil];
    //长按复制有了，删除这些了，滑动删除等等什么的
    //发送名片也不需要了
}
#pragma mark 播放录音
- (IBAction)playRecordSound:(id)sender
{
    NSLog(@"播放录音data %@",getvoiceData);
    NSURL *url=[voiceDictionary objectForKey:@"voiceurl"];
    NSLog(@"%@",url);
    //    //2 NSString转换成NSURL
    //    NSURL * url = [NSURL URLWithString:urlStr];
    //    NSURL * url = [[NSURL alloc] initWithString:urlStr];
    if (self.avPlay.playing) {
        [self.avPlay stop];
        return;
    }
    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    self.avPlay = player;
    [self.avPlay play];
}
-(void)playVideo:(id)sender
{
    UIButton *t = (UIButton *)sender;
    if (t.tag==10000) {
        NSLog(@"t.titleLabel.text  %@",t.titleLabel.text);
    }
    NSURL *viUrl=[NSURL URLWithString:t.titleLabel.text];
    NSLog(@"开始播放视频");
    PlayVideoViewController *playv=[[PlayVideoViewController alloc]init];
    playv.url=viUrl;
    [self presentViewController:playv animated:YES completion:nil];
}
//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
    NSString *heightString=[height objectForKey:@"Height"];
    NSLog(@"保存成功");
    if ([heightString isEqualToString:@"text"]) {
        NSMutableDictionary *dict  = [self.fmdbmessages objectAtIndex:indexPath.row];
        NSString *msg = [dict objectForKey:@"msg"];
        
        CGSize textSize = {260.0 , 10000.0};
        CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
        
        size.height += padding*2;
        
        CGFloat height = size.height < 65 ? 65 : size.height;
        return height;
    }
    else if ([heightString isEqualToString:@"voice"]){
        return 50;
    }else if ([heightString isEqualToString:@"picture"]){
        return 160;
    }else if ([heightString isEqualToString:@"video"]){
        return 210;
    }else{
        return 210;
    }
    return 210;
}

#pragma mark - private
- (IBAction)biaoQing:(id)sender {
    //表情可以用第三方
    //微信一排7个三排，再左右滑,第三排6个，最后一个位置用来删除表情
    //可以加个经常使用的表情
    //消息对方y已读未读，不是自己
}

- (IBAction)picture:(id)sender {
    UIImagePickerController* pickerImage = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        pickerImage.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerImage.sourceType];
    }
    pickerImage.delegate = self;
    pickerImage.allowsEditing = NO;
    [self presentViewController:pickerImage animated:YES completion:nil];
    
    //在下面还要判断来自相册还是现拍，视频因为只有10秒，还坑爹的马赛克1m所以只能现拍，iOS微信不能上传
}
//-(void)sendImage:(UIImage *)image{
//    NSData *imgData;
//    if (UIImagePNGRepresentation(image) == nil) {
//        imgData = UIImageJPEGRepresentation(image, 1);
//    } else {
//        imgData = UIImagePNGRepresentation(image);
//    }
//    //    <Picture>				//图片类型
//    //    <JPG>Picture Data</JPG>		//图片数据，考虑性能，最大5K Byte
//    //    <Group>Group Name</Group>		//可选，用于提供群名称，表示群消息
//    //    <Link>Http Link</Link>		//可选，文件链接，点击下载
//    //    <Path>Local File Path</File>	//可选，本地文件链接
//    //    </Picture>
//    NSString *imgStr = [imgData base64EncodedString];
//    NSXMLElement *jpg = [NSXMLElement elementWithName:@"JPG"];
//    [jpg setStringValue:[NSString stringWithFormat:@"%@",imgStr]];
//    
//    NSXMLElement *pic = [NSXMLElement elementWithName:@"Picture"];
//    [pic addChild:jpg];
//    
//    //生成XML消息文档
//    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
//    //消息类型
//    [mes addAttributeWithName:@"type" stringValue:@"chat"];
//    //发送给谁
//    [mes addAttributeWithName:@"to" stringValue:_chatWithUser];
//    //由谁发送
//    [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
//    //组合
//    [mes addChild:pic];
//    
//    //发送消息
//    [[XMPPServer xmppStream] sendElement:mes];
//    
//    self.messageTextField.text = @"";
//    [self.messageTextField resignFirstResponder];
//}
//------------------------------------------------------
- (IBAction)video:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray *temp_MediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        picker.mediaTypes = temp_MediaTypes;
        picker.delegate = self;
        picker.allowsImageEditing = YES;
    }
    [self presentModalViewController:picker animated:YES];
}
#pragma 拍照选择照片协议方法
//下面两个函数是遵守UIImagePickerControllerDelegate这个协议所实现的类.这样就能够完整的实现,获取照片或者视频,然后写入文件的过程.
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        NSString *imageFile=[documentsDirectory stringByAppendingPathComponent:@"temp.jpg"];
        success = [fileManager fileExistsAtPath:imageFile];
        if(success) {
            success = [fileManager removeItemAtPath:imageFile error:&error];
        }
        //------------------------------------------------------
//        UIImageView *imageview=[[UIImageView alloc]init];
//        imageview.frame=CGRectMake(0, 0, 200, 200);
//        imageview.image=image;
//        [self.tView addSubview:imageview];

        [UIImageJPEGRepresentation(image, 1.0f)writeToFile:imageFile atomically:YES];
        //-------------------------------------------------------------------------
        //    <Picture>				//图片类型
        //    <JPG>Picture Data</JPG>		//图片数据，考虑性能，最大5K Byte
        //    <Group>Group Name</Group>		//可选，用于提供群名称，表示群消息
        //    <Link>Http Link</Link>		//可选，文件链接，点击下载
        //    <Path>Local File Path</File>	//可选，本地文件链接
        //    </Picture>
        NSData *imgData = [NSData dataWithContentsOfFile:imageFile];
        NSString *imgStr = [imgData base64EncodedString];
        NSXMLElement *jpg = [NSXMLElement elementWithName:@"JPG"];
        [jpg setStringValue:[NSString stringWithFormat:@"%@",imgStr]];
        NSXMLElement *pic = [NSXMLElement elementWithName:@"Picture"];
        [pic addChild:jpg];
        NSString *message =pic.XMLString;
        NSLog(@"输出地址%@",message);
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithUser];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
        //组合
        [mes addChild:pic];
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        self.messageTextField.text = @"";
        [self.messageTextField resignFirstResponder];
        //------------------------------------------------------
        NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
        NSLog(@"array:%@",array);
        NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到
        
        NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
        [height setObject:@"picture" forKey:@"Height"];
        NSLog(@"保存成功");
        
        NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
        [dateformat setDateFormat:@"yyyyMMddHHmmss"];
        NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
        
        NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *pictureurl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.jpg", strUrl,[dateformat stringFromDate:[NSDate date]]]];

        NSString* pictureurlstring=[pictureurl absoluteString];//NSURL转换成NSString
        
        [self writeToFile:imgData :[NSString stringWithFormat:@"%@/%@.jpg", strUrl,[dateformat stringFromDate:[NSDate date]]]];
        NSLog(@"pictureurlstring %@",pictureurlstring);
        [self addSql:@"a2" andsender:@"a2" andmessade:nil andBigurl:pictureurl andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"picture"];
        [self ssf];
        [self.tView reloadData];
        //大图
//        UIImage *aimage = [UIImage imageWithData:imgData];
//        UIImageView *imageview=[[UIImageView alloc]init];
//        imageview.frame=CGRectMake(0, 0, 200, 200);
//        imageview.image=aimage;
//        [self.tView addSubview:imageview];
    }
    else if([mediaType isEqualToString:@"public.movie"]){
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"%@", videoURL);
        NSLog(@"found a video");
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        
        /****************************************/
        
        NSString *videoFile = [documentsDirectory stringByAppendingPathComponent:@"temp.mov"];
        NSLog(@"videoFile %@", videoFile);
        
        success = [fileManager fileExistsAtPath:videoFile];
        if(success) {
            success = [fileManager removeItemAtPath:videoFile error:&error];
        }
        [videoData writeToFile:videoFile atomically:YES];
        //CFShow([[NSFileManager defaultManager] directoryContentsAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents"]]);
        //NSLog(videoURL);
        
        //------------------------------------------------------
        NSData *avData = [NSData dataWithContentsOfFile:videoFile];
        //UIImage *aimage = [UIImage imageWithData: imageData];
        NSString *avStr = [avData base64EncodedString];
        NSXMLElement *av = [NSXMLElement elementWithName:@"Av"];
        [av setStringValue:[NSString stringWithFormat:@"%@",avStr]];
        NSXMLElement *video = [NSXMLElement elementWithName:@"Video"];
        [video addChild:av];
        NSString *message =video.XMLString;
        NSLog(@"输出地址%@",message);
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithUser];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
        //组合
        [mes addChild:video];
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        self.messageTextField.text = @"";
        [self.messageTextField resignFirstResponder];
        //------------------------------------------------------
        NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
        NSLog(@"array:%@",array);
        NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到
        
        NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
        [height setObject:@"video" forKey:@"Height"];
        NSLog(@"保存成功");
        
        NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
        [dateformat setDateFormat:@"yyyyMMddHHmmss"];
        NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
        NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *videourl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mov", strUrl,[dateformat stringFromDate:[NSDate date]]]];
        NSString* videourlstring=[videourl absoluteString];//NSURL转换成NSString
        [self writeToFile:avData :[NSString stringWithFormat:@"%@/%@.mov", strUrl,[dateformat stringFromDate:[NSDate date]]]];
        NSLog(@"pictureurlstring %@",videourlstring);
        
        [self addSql:@"a2" andsender:@"a2" andmessade:nil andBigurl:videourl andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"video"];
        [self ssf];
        [self.tView reloadData];
        //大图
        //------------------------------------------------------
    }
    [picker dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}
//------------------------------------------------------

#pragma mark sender text
- (void)sendButton:(id)sender {
    //        <Text>					//文本类型
    //        <Content>Message Content</Content>	//文本内容，考虑性能，最大20K Byte
    //        </Text>
    //本地输入框中的信息
    NSString *message = self.messageTextField.text;
    NSString *addmessage = self.messageTextField.text;
    if (message.length > 0) {
        NSXMLElement *content = [NSXMLElement elementWithName:@"Content"];
        [content setStringValue:[NSString stringWithFormat:@"%@",message]];
        NSXMLElement *text = [NSXMLElement elementWithName:@"Text"];
        [text addChild:content];
        message=text.XMLString;
        
        //XMPPFramework主要是通过KissXML来生成XML文件
        //生成<body>文档
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"chat"];
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_chatWithUser];
        //由谁发送
        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
        //组合
        [mes addChild:body];
        
        //发送消息
        [[XMPPServer xmppStream] sendElement:mes];
        
        self.messageTextField.text = @"";
        
        //------------------------------------------------------
        NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
        NSLog(@"array:%@",array);
        NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到
        [self addSql:@"a2" andsender:@"a2" andmessade:addmessage andBigurl:nil andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"text"];//if not nowuser no get message
        //重新刷新tableView
        [self ssf];
        [self.tView reloadData];
    }
}//点击键盘，不发送，点击语音需要退出键盘响应//文字发了不退

#pragma mark - 接收到的消息
#pragma mark KKMessageDelegate
-(void)newMessageReceived:(NSDictionary *)messageCotent{
    NSString *sender=[messageCotent objectForKey:@"sender"];
    NSArray *array=[sender componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
    NSLog(@"array:%@",array);
    NSString *senderName=[array objectAtIndex:0];

    NSString *time=[messageCotent objectForKey:@"time"];
    //判断有无url//上面也一样，解析都放在这个里面
    
    NSString *msg=[messageCotent objectForKey:@"msg"];
    //先转换成NSData，然后用NSXMlParser进行解析
    NSData *myRequestData = [ NSData dataWithBytes: [msg UTF8String]  length:[msg length]];
    NSXMLParser *myParser = [[NSXMLParser alloc] initWithData:myRequestData];
    [myParser setDelegate:self];
    //    [myParser setShouldProcessNamespaces:YES];
    //    [myParser setShouldReportNamespacePrefixes:YES];
    //    [myParser setShouldResolveExternalEntities:NO];
    BOOL success = [myParser parse];//判断是否成功
    [myParser parse];
    if(success) {
        NSLog(@"修改xml文件成功");
    }else{
        NSLog(@"修改xml文件失败");
    }
    //------------------------------------------------------
    if ([msg hasPrefix:@"<Voice>"]) {
        NSLog(@"语音");
        NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
        [height setObject:@"voice" forKey:@"Height"];
        NSLog(@"保存成功");
        
        //        NSDateFormatter *dateformat=[[[NSDateFormatter  alloc]init]autorelease];
        //        [dateformat setDateFormat:@"yyyyMMddHHmmss"];
        //        NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
        NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *voiceurl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/ld.aac", strUrl]];
        [voiceDictionary setObject:voiceurl forKey:@"voiceurl"];
        
        voiceurlstring=[voiceurl absoluteString];//NSURL转换成NSString
        
        NSString *voiceString= [textDic objectForKey:@"data"];
        getvoiceData=[voiceString base64DecodedData];
        //[getvoiceData writeToFile:voiceurlstring atomically:NO];
        [self writeToFile:getvoiceData :[NSString stringWithFormat:@"%@/ld.aac", strUrl]];
        NSLog(@"voiceurlstring %@",voiceurlstring);
        [self addSql:@"a2" andsender:senderName andmessade:nil andBigurl:voiceurl andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"voice"];
    }else if ([msg hasPrefix:@"<Text>"]){
        NSLog(@"Text");
        NSString* Textmessage=[textDic objectForKey:@"content"];
        [self addSql:@"a2" andsender:senderName andmessade:Textmessage andBigurl:nil andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"text"];//if not nowuser no get message
    }else if ([msg hasPrefix:@"<Picture>"]){
        NSLog(@"Picture");
        [self addSql:@"a2" andsender:senderName andmessade:msg andBigurl:nil andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"picture"];//if not nowuser no get message
    }else if ([msg hasPrefix:@"<Video>"]){
        NSLog(@"Video");
        //------------------------------------------------------
//        NSData *avData = [NSData dataWithContentsOfFile:videoFile];
//        //UIImage *aimage = [UIImage imageWithData: imageData];
//        NSString *avStr = [avData base64EncodedString];
//        NSXMLElement *av = [NSXMLElement elementWithName:@"Av"];
//        [av setStringValue:[NSString stringWithFormat:@"%@",avStr]];
//        NSXMLElement *video = [NSXMLElement elementWithName:@"Video"];
//        [video addChild:av];
//        NSString *message =video.XMLString;
//        NSLog(@"输出地址%@",message);
//        //生成<body>文档
//        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//        [body setStringValue:message];
//        //生成XML消息文档
//        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
//        //消息类型
//        [mes addAttributeWithName:@"type" stringValue:@"chat"];
//        //发送给谁
//        [mes addAttributeWithName:@"to" stringValue:_chatWithUser];
//        //由谁发送
//        [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
//        //组合
//        [mes addChild:video];
//        //发送消息
//        [[XMPPServer xmppStream] sendElement:mes];
//        self.messageTextField.text = @"";
//        [self.messageTextField resignFirstResponder];
//        //------------------------------------------------------
//        NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
//        NSLog(@"array:%@",array);
//        NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到
//        //先转换成NSData，然后用NSXMlParser进行解析
//        NSData *myRequestData = [ NSData dataWithBytes: [message UTF8String]  length:[message length]];
//        NSXMLParser *myParser = [[NSXMLParser alloc] initWithData:myRequestData];
//        [myParser setDelegate:self];
//        //    [myParser setShouldProcessNamespaces:YES];
//        //    [myParser setShouldReportNamespacePrefixes:YES];
//        //    [myParser setShouldResolveExternalEntities:NO];
//        BOOL success = [myParser parse];//判断是否成功
//        [myParser parse];
//        if(success) {
//            NSLog(@"修改xml文件成功");
//        }else{
//            NSLog(@"修改xml文件失败");
//        }
//        NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
//        [height setObject:@"video" forKey:@"Height"];
//        NSLog(@"保存成功");
//        
//        NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
//        [dateformat setDateFormat:@"yyyyMMddHHmmss"];
//        NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
//        
//        NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//        NSURL *videourl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mov", strUrl,[dateformat stringFromDate:[NSDate date]]]];
//        
//        NSString* videourlstring=[videourl absoluteString];//NSURL转换成NSString
//        
//        NSString *videoString= [textDic objectForKey:@"data"];
//        getvoiceData=[videoString base64DecodedData];
//        [self writeToFile:getvoiceData :[NSString stringWithFormat:@"%@/%@.aac", strUrl,[dateformat stringFromDate:[NSDate date]]]];
//        NSLog(@"pictureurlstring %@",videourlstring);
//        [self addSql:@"a2" andsender:@"a2" andmessade:nil andBigurl:videourl andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"video"];
//        [self ssf];
//        [self.tView reloadData];
//        //大图
        //------------------------------------------------------
        [self addSql:@"a2" andsender:senderName andmessade:msg andBigurl:nil andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"video"];//if not nowuser no get message
    }else{
        //文字...表情
        [self addSql:@"a2" andsender:senderName andmessade:msg andBigurl:nil andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"text"];//if not nowuser no get message
    }
    //------------------------------------------------------
    //每次执行sql和每次写变量一样
    [self ssf];
    [self.tView reloadData];
}
//--------------------
-(void)writeToFile:(NSData *)data:(NSString *) fileName{
    NSString *filePath=[NSString stringWithFormat:@"%@",fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO){
        NSLog(@"file not exist,create it...");
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }else {
        NSLog(@"file exist!!!");
    }
    
    FILE *file = fopen([fileName UTF8String], [@"ab+" UTF8String]);
    
    if(file != NULL){
        fseek(file, 0, SEEK_END);
    }
    int readSize = [data length];
    fwrite((const void *)[data bytes], readSize, 1, file);
    fclose(file);
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    textDic = [[NSMutableDictionary alloc] init];
    currentTagName = [[NSString alloc] init];
}
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"%@",parseError);
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentTagName = elementName;
    if ([currentTagName isEqualToString:@"Text"])
    {
        //        if ([currentTagName isEqualToString:@"Content"]) {
        //            NSLog(@"<#string#>");
        //        }
    }
    //    else if ([currentTagName isEqualToString:@"Voice"])
    //    {
    //        if ([currentTagName isEqualToString:@"Data"])
    //        {
    //            [textDic setObject:qName forKey:@"data"];
    //        }
    //    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    //文本
	if ([currentTagName isEqualToString:@"Content"]) {
        [textDic setObject:string forKey:@"content"];
        NSLog(@"文本内容 %@",[textDic objectForKey:@"content"]);
	}
    
    //语音
    if ([currentTagName isEqualToString:@"Data"]) {
        [textDic setObject:string forKey:@"data"];
        NSLog(@"语音内容 %@",[textDic objectForKey:@"data"]);
	}
    //    if ([currentTagName isEqualToString:@"Duration"]) {
    //        [textDic setObject:string forKey:@"duration"];
    //        NSLog(@"语音时长 %@",[textDic objectForKey:@"Duration"]);
    //	}
    
    //    //图片
    //    if ([currentTagName isEqualToString:@"Data"]) {
    //        [textDic setObject:string forKey:@"data"];
    //        NSLog(@"语音内容 %@",[textDic objectForKey:@"data"]);
    //	}
    //
    //    //视频
    //    if ([currentTagName isEqualToString:@"Data"]) {
    //        [textDic setObject:string forKey:@"data"];
    //        NSLog(@"语音内容 %@",[textDic objectForKey:@"data"]);
    //	}
    //
    //    //表情
    //    if ([currentTagName isEqualToString:@"Data"]) {
    //        [textDic setObject:string forKey:@"data"];
    //        NSLog(@"语音内容 %@",[textDic objectForKey:@"data"]);
    //	}
    
    
    //[elementString appendString:string];
}
//遇到结束标签时候出发
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName;
{
    currentTagName = nil;
}
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"遇到文档结束时候触发");
    //self.notes = nil;
}

-(IBAction)jianopan:(id)sender
{
    _keyButton.hidden=YES;
    _recordBtn.hidden=YES;
    _talkButton.hidden=NO;
    NSLog(@"点击了键盘");
}
-(IBAction)btnAction:(id)sender{
    //语音2键盘1加3按住说话4(tag)
    UIButton *t = (UIButton *)sender;
    switch (t.tag) {
        case 2:
        {//点击语音
            NSLog(@"点击了语音");
            _keyButton.hidden=NO;
            _talkButton.hidden=YES;
            _recordBtn.hidden=NO;
            break;
        }
        case 3:
        {
            if (_sendView.frame.origin.y==self.view.frame.size.height-78)
            {
                _sendView.frame=CGRectMake(0, self.view.frame.size.height-39, 320, 80);
            }else
            {
                _sendView.frame=CGRectMake(0, self.view.frame.size.height-78, 320, 80);
            }
            break;
        }
        default:
            break;
    }
}

//--------------------
#pragma mark
#pragma mark 按下不送开始录音
- (void)btnDown:(id)sender//UIControlEventTouchDown      // 按下
{
    //创建录音文件，准备录音
    if ([recorder prepareToRecord]) {
        //开始
        [recorder record];
    }
}
#pragma mark 松开按钮发送
- (void)btnUp:(id)sender//UIControlEventTouchUpInside // 在按钮及其一定外围内松开
{
    cTime = recorder.currentTime;
    NSLog(@"播放2时间%f",recorder.currentTime);
    //if (cTime > 1) {//如果录制时间<1 不发送
    if (cTime > 0) {
        NSLog(@"发出去");
        [recorder stop];
        [self sendVoice];//转码
    }else {
        //删除记录的文件
        [recorder deleteRecording];
        //删除存储的
        [recorder stop];
    }
}

#pragma mark sender voice
-(void)sendVoice{
    //    <Voice>					//语音类型
    //    <Data>Voice Data</Data>		//语音数据，考虑性能，最大5K Byte
    //    <Duration>milliseconds</Duration>   //语音时长，单位为毫秒
    //    <Group>Group Name</Group>		//可选，用于提供群名称，表示群消息
    //    <Link>Http Link</Link>		//可选，文件链接，点击下载
    //    <Path>Local File Path</File>	//可选，本地文件链接
    //    </Voice>
    
    //_avPlay= [[AVAudioPlayer alloc] initWithData:voiceData error:nil];

    //1.获取音频文件路径 例如：(这里就是urlplay)
    //NSURL *recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat: @"%.0f.%@", [NSDatetimeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];

    
    //2.将音频文件转成NSData
    NSData *voiceData = [[NSData alloc] initWithContentsOfURL:urlPlay];
    NSLog(@"voiceData %@",voiceData);
    //3.将NSData转成base64的NSString类型
    NSString *voStr=[voiceData base64EncodedString];
    NSLog(@"voStr %@",voStr);
    
    NSXMLElement *data = [NSXMLElement elementWithName:@"Data"];
    [data setStringValue:[NSString stringWithFormat:@"%@",voStr]];
    
    NSXMLElement *duration = [NSXMLElement elementWithName:@"Duration"];
    [duration setStringValue:[NSString stringWithFormat:@"%f",cTime]];
    
    NSXMLElement *voice = [NSXMLElement elementWithName:@"Voice"];
    [voice addChild:data];
    [voice addChild:duration];
    
    NSString *message =voice.XMLString;
    //XMPPFramework主要是通过KissXML来生成XML文件
    //--------------------------------------
    //XMPPFramework主要是通过KissXML来生成XML文件
    //生成<body>文档
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:_chatWithUser];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults] stringForKey:USERID]];
    //组合
    [mes addChild:body];
    
    //发送消息
    [[XMPPServer xmppStream] sendElement:mes];
    self.messageTextField.text = @"";
    [self.messageTextField resignFirstResponder];
    //------------------------------------------------------
    NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
    NSLog(@"array:%@",array);
    NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到
    //先转换成NSData，然后用NSXMlParser进行解析
    NSData *myRequestData = [ NSData dataWithBytes: [message UTF8String]  length:[message length]];
    NSXMLParser *myParser = [[NSXMLParser alloc] initWithData:myRequestData];
    [myParser setDelegate:self];
    //    [myParser setShouldProcessNamespaces:YES];
    //    [myParser setShouldReportNamespacePrefixes:YES];
    //    [myParser setShouldResolveExternalEntities:NO];
    BOOL success = [myParser parse];//判断是否成功
    [myParser parse];
    if(success) {
        NSLog(@"修改xml文件成功");
    }else{
        NSLog(@"修改xml文件失败");
    }
    NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
    [height setObject:@"voice" forKey:@"Height"];
    NSLog(@"保存成功");
    
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *voiceurl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.aac", strUrl,[dateformat stringFromDate:[NSDate date]]]];
    
    voiceDictionary=[[NSMutableDictionary alloc]init];
    [voiceDictionary setObject:voiceurl forKey:@"voiceurl"];
    
    voiceurlstring=[voiceurl absoluteString];//NSURL转换成NSString
    
    NSString *voiceString= [textDic objectForKey:@"data"];
    getvoiceData=[voiceString base64DecodedData];
    [getvoiceData writeToFile:voiceurlstring atomically:NO];
    [self writeToFile:getvoiceData :[NSString stringWithFormat:@"%@/%@.aac", strUrl,[dateformat stringFromDate:[NSDate date]]]];
    NSLog(@"voiceurlstring %@",voiceurlstring);
    [self addSql:@"a2" andsender:@"a2" andmessade:nil andBigurl:voiceurl andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"voice"];
    [self ssf];
    [self.tView reloadData];
}
////------------------------------------------------------
//NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
//NSLog(@"array:%@",array);
//NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到
////先转换成NSData，然后用NSXMlParser进行解析
//NSData *myRequestData = [ NSData dataWithBytes: [message UTF8String]  length:[message length]];
//NSXMLParser *myParser = [[NSXMLParser alloc] initWithData:myRequestData];
//[myParser setDelegate:self];
////    [myParser setShouldProcessNamespaces:YES];
////    [myParser setShouldReportNamespacePrefixes:YES];
////    [myParser setShouldResolveExternalEntities:NO];
//BOOL success = [myParser parse];//判断是否成功
//[myParser parse];
//if(success) {
//    NSLog(@"修改xml文件成功");
//}else{
//    NSLog(@"修改xml文件失败");
//}
////------------------------------------------------------
//if ([message hasPrefix:@"<Voice>"]) {
//    NSLog(@"语音");
//    NSUserDefaults *height=[NSUserDefaults standardUserDefaults];
//    [height setObject:@"voice" forKey:@"Height"];
//    NSLog(@"保存成功");
//    
//    //        NSDateFormatter *dateformat=[[[NSDateFormatter  alloc]init]autorelease];
//    //        [dateformat setDateFormat:@"yyyyMMddHHmmss"];
//    //        NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
//    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSURL *voiceurl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/ld.aac", strUrl]];
//    
//    voice=[[NSMutableDictionary alloc]init];
//    [voice setObject:voiceurl forKey:@"voiceurl"];
//    
//    voiceurlstring=[voiceurl absoluteString];//NSURL转换成NSString
//    
//    NSString *voiceString= [textDic objectForKey:@"data"];
//    getvoiceData=[voiceString base64DecodedData];
//    [getvoiceData writeToFile:voiceurlstring atomically:NO];
//    [self writeToFile:getvoiceData :[NSString stringWithFormat:@"%@/ld.aac", strUrl]];
//    NSLog(@"voiceurlstring %@",voiceurlstring);
//    [self addSql:@"a2" andsender:@"a2" andmessade:nil andBigurl:voiceurl andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"voice"];
//}else if ([message hasPrefix:@"<Text>"]){
//    NSLog(@"Text");
//    NSString* Textmessage=[textDic objectForKey:@"content"];
//    [self addSql:@"a2" andsender:@"a2" andmessade:Textmessage andBigurl:nil andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"text"];//if not nowuser no get message
//}else if ([message hasPrefix:@"<Picture>"]){
//    NSLog(@"Picture");
//    [self addSql:@"a2" andsender:@"a2" andmessade:message andBigurl:nil andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"picture"];//if not nowuser no get message
//}else if ([message hasPrefix:@"<Video>"]){
//    NSLog(@"Video");
//    [self addSql:@"a2" andsender:@"a2" andmessade:message andBigurl:nil andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"video"];//if not nowuser no get message
//}else{
//    //文字...表情
//    [self addSql:@"a2" andsender:@"a2" andmessade:message andBigurl:nil andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"text"];//if not nowuser no get message
//}
////重新刷新tableView
//[self ssf];
//[self.tView reloadData];
#pragma mark 往上移动删除
- (void)btnDragUp:(id)sender//UIControlEventTouchDragExit  // in到out触发
{
    //删除录制文件
    [recorder deleteRecording];
    [recorder stop];
    NSLog(@"取消发送");
}
- (void)audio
{
    //录音设置
    NSMutableDictionary *recordSetting=[[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    /////
//    NSDateFormatter *dateformat=[[[NSDateFormatter  alloc]init]autorelease];
//    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
//    NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]); 
    /////
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/ll.aac", strUrl]];
    urlPlay = url;
    NSLog(@"%@",urlPlay);
    NSLog(@"%@",url);
    
    NSError *error;
    //初始化
    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    //recorder = [[AVAudioRecorder alloc] initWithURL:url settings:nil error:nil];
    //开启音量检测
    recorder.meteringEnabled = YES;
    recorder.delegate = self;
}

@end
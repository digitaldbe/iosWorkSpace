//
//  YUChatViewController.m
//  BestOne
//
//  Created by ioschen on 13-12-11.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import "YUChatViewController.h"
#import "Statics.h"
#import "KKMessageCell.h"
#import "VoiceCell.h"
#import "VideoCell.h"
#import "ImageCell.h"
#import "NSString+Base64.h"//引入方法
#import "NSData+Base64.h"//字符串转换成data
//#import "BuddyViewController.h"
#import "PlayVideoViewController.h"
#import "SeePictureViewController.h"
#import "JumpWebViewController.h"

#import "RecentChatViewController.h"

#define padding 20
#define BEGIN_FLAG @"["
#define END_FLAG @"]"
@interface YUChatViewController ()
@property(nonatomic,retain)NSMutableArray *fmdbmessages;
@end

@implementation YUChatViewController
@synthesize avPlay = _avPlay;
@synthesize chatWithUser = _chatWithUser;
@synthesize fmdbmessages = _fmdbmessages;
@synthesize voiceurlstring;
@synthesize headImageurlstring;
@synthesize headImagemeurlstring;
#pragma mark - life circle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self audio];
    voiceDictionary=[[NSMutableDictionary alloc]init];
    self.fmdbmessages=[[NSMutableArray alloc]init];
    [self createData];
    [self createTable];
    [self ssf];
    [self CGRectMakeNavBar];
    [self CGRectMakeMainView];
    //设置信息代理
    [XMPPServer sharedServer].messageDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
-(void)tableviewClick
{
    //键盘退出第一响应，位置，坐标还原
    //左边滑动事件  链接电话蓝色高亮显示，直接打开或者拨打
    //textview用可显示富文本的，显示表情
    //接收视频。图片显示进度条最没有必要吗
    //语音喇叭模式等
    [sendText resignFirstResponder];
    typeMessage.frame=CGRectMake(0, self.view.frame.size.height-44, 320, 248);
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
        NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS PERSONINFO (ID INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, sender TEXT, receiver TEXT, message TEXT, bigurl TEXT, sendtime TEXT, isread INTEGER, messagetype TEXT, voicetime TEXT, smallpicture TEXT)"];
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
-(void)addSql:(NSString *)YUUsername andsender:(NSString *)YUSender andmessade:(NSString *)YUMessage andBigurl:(NSURL *)YUBigurl andsendtime:(NSString *)YUSendtime andisread:(int)YUIsread andReceiver:(NSString *)YUReceiver andMessagetype:(NSString *)YUMessagetype andVoicetime:(NSString *)YUVoicetime andSmallpicture:(NSURL *)YUSmallpicture
{
    NSLog(@"添加");
    if ([db open]) {
        NSString *insertSql2=[NSString stringWithFormat:
                              @"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@') VALUES ('%@','%@', '%@', '%@', '%@','%d', '%@', '%@', '%@', '%@')",
                              TABLENAME, USERNAME, SENDER, MESSAGE, BIGURL, SENDTIME,ISREAD,RECEIVER,MESSAGETYPE,VOICETIME,SMALLPICTURE, YUUsername, YUSender, YUMessage, YUBigurl, YUSendtime,YUIsread,YUReceiver,YUMessagetype,YUVoicetime,YUSmallpicture];
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
            NSString * chatSmallpicture = [rs stringForColumn:SMALLPICTURE];
            //int chatVoicetime=[rs intForColumn:VOICETIME];
            NSString * chatVoicetime=[rs stringForColumn:VOICETIME];
            //            NSLog(@"id=%d chatUserName=%@ chatSender=%@ chatMessage=%@ chatBigurl=%@ chatSendtime=%@",ID chatUserName,chatSender,chatMessage,chatBigurl,chatSendtime);
            NSLog(@"chatUserName=%@ chatSender=%@ chatMessage=%@ chatBigurl=%@ chatSendtime=%@ chatIsread=%d chatReceiver=%@ chatMessagetype=%@",chatUserName,chatSender,chatMessage,chatBigurl,chatSendtime,chatIsread,chatReceiver,chatMessagetype);
            
            fmdbdictionary=[[NSMutableDictionary alloc]init];
            [fmdbdictionary setObject:chatMessage forKey:@"msg"];
            [fmdbdictionary setObject:chatSender forKey:@"sender"];
            [fmdbdictionary setObject:chatSendtime forKey:@"time"];
            [fmdbdictionary setObject:chatMessagetype forKey:@"type"];
            [fmdbdictionary setObject:chatBigurl forKey:@"url"];
            [fmdbdictionary setObject:chatSmallpicture forKey:@"smp"];
            //[fmdbdictionary setObject:[NSString stringWithFormat:@"%d",chatVoicetime] forKey:@"vtime"];
            [fmdbdictionary setObject:chatVoicetime forKey:@"vtime"];
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
    zhLabel.text=[[self.chatWithUser componentsSeparatedByString:@"@"] objectAtIndex:0];
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
- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat screenHeight = self.view.bounds.size.height;
    __block CGRect frame = typeMessage.frame;
    
    if (frame.origin.y != screenHeight - keyboardSize.height - 40.) {
        frame.origin.y = screenHeight - keyboardSize.height - 40.;//lxf
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             typeMessage.frame = frame;
                             
                         } completion:^(BOOL finished) {
                             typeMessage.frame = frame;
                         }];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat screenHeight = self.view.bounds.size.height;
    __block CGRect frame = typeMessage.frame;
    frame.origin.y = screenHeight- 44;//lxf
    typeMessage.frame = frame;
    
    //    [UIView animateWithDuration:fAniTimeSecond animations:^{
    //        self.viewItems.frame = frame;
    //    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)CGRectMakeMainView
{
    //聊天
    chatView=[[UITableView alloc]initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-88) style:UITableViewStylePlain];
    chatView.backgroundColor=[UIColor colorWithRed:(217/255.0) green:(220/255.0) blue:(219/255.0) alpha:1];
    chatView.dataSource=self;
    chatView.delegate=self;
    //------------------------------------------------------
    UITapGestureRecognizer *tapRecognizer2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableviewClick)];
    chatView.userInteractionEnabled=YES;
    [chatView addGestureRecognizer:tapRecognizer2];
    //------------------------------------------------------
    //监视手势控制
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [chatView addGestureRecognizer:recognizer];
    //chatView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //------------------------------------------------------
    //chatView.clipsToBounds=YES;
    chatView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:chatView];
    //语音
    typeMessage=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-44, 320, 248)];
    typeMessage.backgroundColor=[UIColor redColor];
    [self.view addSubview:typeMessage];//整体
    
    voiceView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    voiceView.backgroundColor=[UIColor colorWithRed:(89/255.0) green:(86/255.0) blue:(87/255.0) alpha:1];
    [typeMessage addSubview:voiceView];//语音键盘等
    keyboardButton=[UIButton buttonWithType:UIButtonTypeCustom];
    keyboardButton.frame=CGRectMake(2, 4, 36, 36);
    //[keyboardButton setTitle:@"keyb" forState:UIControlStateNormal];
    [keyboardButton setBackgroundImage:[UIImage imageNamed:@"button7type_a.png"] forState:UIControlStateNormal];
    [keyboardButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    keyboardButton.tag=100;
    [voiceView addSubview:keyboardButton];
    UIButton *sayButton=[UIButton buttonWithType:UIButtonTypeCustom];
    sayButton.frame=CGRectMake(88, 4, 228, 36);
    [sayButton addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    [sayButton addTarget:self action:@selector(btnUp:) forControlEvents:UIControlEventTouchUpInside];
    [sayButton addTarget:self action:@selector(btnDragUp:) forControlEvents:UIControlEventTouchDragExit];
    [sayButton setBackgroundImage:[UIImage imageNamed:@"button7holdtotalk_a.png"] forState:UIControlStateNormal];
    [voiceView addSubview:sayButton];
    voiceButton=[UIButton buttonWithType:UIButtonTypeCustom];
    voiceButton.frame=CGRectMake(2, 4, 36, 36);
    //[voiceButton setTitle:@"voice" forState:UIControlStateNormal];
    [voiceButton setBackgroundImage:[UIImage imageNamed:@"button7talk_a.png"] forState:UIControlStateNormal];
    [voiceButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    voiceButton.tag=101;
    [voiceView addSubview:voiceButton];
    UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame=CGRectMake(44, 4, 36, 36);
    [addButton setBackgroundImage:[UIImage imageNamed:@"button7addon_a.png"] forState:UIControlStateNormal];
    //[addButton setTitle:@"add" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addShow) forControlEvents:UIControlEventTouchUpInside];
    [voiceView addSubview:addButton];
    sendText=[[UITextField alloc]initWithFrame:CGRectMake(88, 6, 188, 34)];
    sendText.backgroundColor=[UIColor whiteColor];
    sendText.delegate=self;
    [sendText addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventTouchUpInside];
    [voiceView addSubview:sendText];
    sendButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame=CGRectMake(278, 4, 40, 36);
    [sendButton setTitle:@"send" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButton:) forControlEvents:UIControlEventTouchUpInside];
    [voiceView addSubview:sendButton];

    
    biaoqingView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, 204)];//48
    biaoqingView.backgroundColor=[UIColor colorWithRed:(37/255.0) green:(23/255.0) blue:(19/255.0) alpha:1];
    //开启滚动分页功能，如果不需要这个功能关闭即可
    [biaoqingView setPagingEnabled:YES];
    //隐藏横向与纵向的滚动条,是否显示水平拖动条,是否显示竖直拖动条
    [biaoqingView setShowsVerticalScrollIndicator:NO];
    [biaoqingView setShowsHorizontalScrollIndicator:NO];
    [biaoqingView setDelegate:self];
    //------------------------------------------------------
    //用于设置表情位置
    int xIndex=0;
    int yIndex=0;
    emotionArray=[[NSMutableArray alloc]init];
    //给动态数组添加105张表情和建立105个按钮
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion"ofType:@"plist"];
    emotiondata = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSLog(@"%@", emotiondata);
    NSArray* pngArray=[emotiondata allKeys];
    NSLog(@"pngArray %@",pngArray);
    for (int i=0; i<[pngArray count]; i++) {
        UIImage *image=[UIImage imageNamed:[pngArray objectAtIndex:i]];
        UIButton  *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(10+xIndex*32, 10+yIndex*32, 32.0f, 32.0f);
        [button setBackgroundImage:image forState:UIControlStateNormal];
        button.tag=i;
        [button addTarget:self action:@selector(didSelectAFace:) forControlEvents:UIControlEventTouchUpInside];
        [biaoqingView addSubview:button];
        xIndex+=1;
        //每一行添加9张图片，当满9张时，跳到下一排
        if (xIndex==9) {
            xIndex=0;
            yIndex+=1;
        }
    }
    [biaoqingView setContentSize:CGSizeMake(300.0f, 12+(yIndex+1)*32)];
    [typeMessage addSubview:biaoqingView];//表情
    //------------------------------------------------------
    
    
    moreView=[[UIView alloc]initWithFrame:CGRectMake(0, 44, 320, 64)];
    moreView.backgroundColor=[UIColor colorWithRed:(37/255.0) green:(23/255.0) blue:(19/255.0) alpha:1];
    [typeMessage addSubview:moreView];//图片视频等
    UIButton *biaoqingButton=[UIButton buttonWithType:UIButtonTypeCustom];
    biaoqingButton.frame=CGRectMake(10, 2, 64, 60);
    [biaoqingButton setBackgroundImage:[UIImage imageNamed:@"button7emotion_a.png"] forState:UIControlStateNormal];
    //[biaoqingButton setTitle:@"love" forState:UIControlStateNormal];
    [biaoqingButton addTarget:self action:@selector(biqoaingShow) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:biaoqingButton];
//    UILabel *biaoqingLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 44, 44, 20)];
//    biaoqingLabel.text=@"表情";
//    biaoqingLabel.backgroundColor=[UIColor clearColor];
//    [moreView addSubview:biaoqingLabel];
    UIButton *imgButton=[UIButton buttonWithType:UIButtonTypeCustom];
    imgButton.frame=CGRectMake(94, 2, 64, 60);
    [imgButton setBackgroundImage:[UIImage imageNamed:@"button7img_a.png"] forState:UIControlStateNormal];
    [imgButton addTarget:self action:@selector(picture:) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:imgButton];
//    UILabel *imgLabel=[[UILabel alloc]initWithFrame:CGRectMake(64, 44, 44, 20)];
//    imgLabel.text=@"图片";
//    imgLabel.backgroundColor=[UIColor clearColor];
//    [moreView addSubview:imgLabel];
    UIButton *videoButton=[UIButton buttonWithType:UIButtonTypeCustom];
    videoButton.frame=CGRectMake(188, 2, 64, 60);
    [videoButton setBackgroundImage:[UIImage imageNamed:@"button7video_a.png"] forState:UIControlStateNormal];
    [videoButton addTarget:self action:@selector(video:) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:videoButton];
//    UILabel *videoLabel=[[UILabel alloc]initWithFrame:CGRectMake(128, 44, 44, 20)];
//    videoLabel.text=@"拍摄";
//    videoLabel.backgroundColor=[UIColor clearColor];
//    [moreView addSubview:videoLabel];
}
#pragma mark 选择表情
-(void)didSelectAFace:(id)sender
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"emotion"ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSLog(@"%@", data);
    NSArray* pngStringArray=[data allValues];
    
    UIButton *tempBtn=(UIButton *)sender;
    NSString *faceStr=[NSString stringWithFormat:@"%@",[pngStringArray objectAtIndex:tempBtn.tag]];
    NSLog(@"文字解码  %@",faceStr);
    sendText.text=[sendText.text stringByAppendingString:faceStr];
}
//------------------------------------------------------
#pragma mark
#pragma mark 聊天输入类型
-(void)addShow
{
    NSLog(@"add show");
    //键盘退出
    [sendText resignFirstResponder];
    moreView.hidden=NO;
    //typeMessage.frame.origin.y=self.view.frame.size.height-108;
    //    if (typeMessage.frame.origin.y==self.view.frame.size.height-108) {
    //        typeMessage.frame=CGRectMake(0, self.view.frame.size.height-44, 320, 248);
    //    }else{
    //        typeMessage.frame=CGRectMake(0, self.view.frame.size.height-108, 320, 248);
    //    }
    typeMessage.frame=CGRectMake(0, self.view.bounds.size.height-108, 320, 248);
}
-(void)biqoaingShow
{
    moreView.hidden=YES;
    typeMessage.frame=CGRectMake(0, self.view.bounds.size.height-248, 320, 248);
    //typeMessage.frame=CGRectMake(0, self.view.frame.size.height-248, 320, 248);
    
    //表情可以用第三方
    //微信一排7个三排，再左右滑,第三排6个，最后一个位置用来删除表情
    //可以加个经常使用的表情
}
-(void)btnAction:(id)sender{
    //语音101键盘100(tag)
    UIButton *t = (UIButton *)sender;
    [sendText resignFirstResponder];//如果点击键盘，光标定位键盘
    typeMessage.frame=CGRectMake(0, self.view.frame.size.height-44, 320, 248);
    switch (t.tag) {
        case 101:
        {//点击语音
            NSLog(@"点击了语音");
            voiceButton.hidden=YES;
            sendText.hidden=YES;
            sendButton.hidden=YES;
            break;
        }
        case 100:
        {//点击键盘
            NSLog(@"点击了键盘");
            voiceButton.hidden=NO;
            sendText.hidden=NO;
            sendButton.hidden=NO;
            [sendText becomeFirstResponder];
            break;
        }
        default:
            break;
    }
}
////图文混排
//-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
//    NSRange range=[message rangeOfString: BEGIN_FLAG];
//    NSRange range1=[message rangeOfString: END_FLAG];
//    //判断当前字符串是否还有表情的标志。
//    if (range.length>0 && range1.length>0) {
//        if (range.location > 0) {
//            [array addObject:[message substringToIndex:range.location]];
//            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
//            NSString *str=[message substringFromIndex:range1.location+1];
//            [self getImageRange:str :array];
//        }else {
//            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
//            //排除文字是“”的
//            if (![nextstr isEqualToString:@""]) {
//                [array addObject:nextstr];
//                NSString *str=[message substringFromIndex:range1.location+1];
//                [self getImageRange:str :array];
//            }else {
//                return;
//            }
//        }
//        
//    } else if (message != nil) {
//        [array addObject:message];
//    }
//}
//
//#define KFacialSizeWidth  18
//#define KFacialSizeHeight 18
//#define MAX_WIDTH 150
//-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
//{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    [self getImageRange:message :array];
//    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
//    NSArray *data = array;
//    UIFont *fon = [UIFont systemFontOfSize:13.0f];
//    CGFloat upX = 0;
//    CGFloat upY = 0;
//    CGFloat X = 0;
//    CGFloat Y = 0;
//    if (data) {
//        for (int i=0;i < [data count];i++) {
//            NSString *str=[data objectAtIndex:i];
//            NSLog(@"str--->%@",str);
//            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
//            {
//                if (upX >= MAX_WIDTH)
//                {
//                    upY = upY + KFacialSizeHeight;
//                    upX = 0;
//                    X = 150;
//                    Y = upY;
//                }
//                NSLog(@"str(image)---->%@",str);
//                NSString *imageName=[str substringWithRange:NSMakeRange(2, str.length - 3)];
//                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
//                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
//                [returnView addSubview:img];
//                upX=KFacialSizeWidth+upX;
//                if (X<150) X = upX;
//            } else {
//                for (int j = 0; j < [str length]; j++) {
//                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
//                    if (upX >= MAX_WIDTH)
//                    {
//                        upY = upY + KFacialSizeHeight;
//                        upX = 0;
//                        X = 150;
//                        Y =upY;
//                    }
//                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(150, 40)];
//                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
//                    la.font = fon;
//                    la.text = temp;
//                    la.backgroundColor = [UIColor clearColor];
//                    [returnView addSubview:la];
//                    upX=upX+size.width;
//                    if (X<150) {
//                        X = upX;
//                    }
//                }
//            }
//        }
//    }
//    returnView.frame = CGRectMake(15.0f,1.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
//    NSLog(@"%.1f %.1f", X, Y);
//    return returnView;
//}
//------------------------------------------------------
#pragma mark - 四种气泡
#pragma mark 泡泡文本
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf withPosition:(int)position{
    //1和0不要 //计算大小
    UIFont *font = [UIFont systemFontOfSize:14];
	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
	// build single chat bubble cell with given text
	UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
	returnView.backgroundColor = [UIColor clearColor];
	
    //背影图片
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"SenderVoiceNodeDownloading":@"ReceiverTextNodeBkg" ofType:@"png"]];
    
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height/2)]];
	NSLog(@"%f,%f",size.width,size.height);
	
    //添加文本信息
	UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(fromSelf?15.0f:22.0f, 20.0f, size.width+10, size.height+10)];
	bubbleText.backgroundColor = [UIColor clearColor];
	bubbleText.font = font;
	bubbleText.numberOfLines = 0;
	bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
//    if (text) {
//        NSString *temp=@"我";//[happy]
//        NSRange rang=[text rangeOfString:temp];
//        NSLog(@"搜索的字符串在中起始点的index 为 %d", rang.location);
//        NSLog(@"搜索的字符串在中结束点的index 为 %d", rang.location + rang.length);
//        //将搜索中的字符串替换成为一新的字符串;
//        NSString *str=[text stringByReplacingCharactersInRange:rang withString:@"产"];
//        bubbleText.text = str;
//    }
    bubbleText.text=text;
	bubbleImageView.frame = CGRectMake(0.0f, 14.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+20.0f);
    
	if(fromSelf)
		returnView.frame = CGRectMake(320-position-(bubbleText.frame.size.width+30.0f), 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
	else
		returnView.frame = CGRectMake(position, 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
	
	[returnView addSubview:bubbleImageView];
	[returnView addSubview:bubbleText];
    
    return returnView;
}

#pragma mark 泡泡语音
- (UIView *)yuyinView:(NSInteger)logntime from:(BOOL)fromSelf withIndexRow:(NSInteger)indexRow  withPosition:(int)position withUrl:(NSString *)voiceurl{
    //语音已读未读标记
    //根据语音长度
    int yuyinwidth = 66+fromSelf;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = indexRow;
    //------------------------------------------------------
    button.tag=20000;//或者tag用传参
    [button addTarget:self action:@selector(playRecordSound:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:voiceurl forState:UIControlStateNormal];
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    //------------------------------------------------------
    if(fromSelf)
		button.frame =CGRectMake(320-position-yuyinwidth, 10, yuyinwidth, 54);
	else
		button.frame =CGRectMake(position, 10, yuyinwidth, 54);
    
    //image偏移量
    UIEdgeInsets imageInsert;
    imageInsert.top = -10;
    imageInsert.left = fromSelf?button.frame.size.width/3:-button.frame.size.width/3;
    button.imageEdgeInsets = imageInsert;
    
    [button setImage:[UIImage imageNamed:fromSelf?@"SenderVoiceNodePlaying":@"ReceiverVoiceNodePlaying"] forState:UIControlStateNormal];
//    UIImage *backgroundImage = [UIImage imageNamed:fromSelf?@"SenderVoiceNodeDownloading":@"ReceiverVoiceNodeDownloading"];
    UIImage *backgroundImage = [UIImage imageNamed:fromSelf?@"SenderVoiceNodeDownloading":@"ReceiverTextNodeBkg"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:20 topCapHeight:0];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(fromSelf?-30:button.frame.size.width, 0, 30, button.frame.size.height)];
    label.text = [NSString stringWithFormat:@"%d''",logntime];
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [button addSubview:label];
    
    return button;
}
#pragma mark 泡泡图片
- (UIView *)pictureView:(BOOL)fromSelf withPosition:(int)position
{//时间长度可以学习语音的传值
	UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
	returnView.backgroundColor = [UIColor clearColor];
	
    //背影图片
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"SenderVoiceNodeDownloading":@"ReceiverTextNodeBkg" ofType:@"png"]];
    
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height/2)]];
	
	bubbleImageView.frame = CGRectMake(0.0f, 14.0f, 120+30.0f, 90+20.0f);
    
	if(fromSelf)
		returnView.frame = CGRectMake(320-position-(120+30.0f)-60, 0.0f, 120+30.0f, 90+30.0f);
	else
		returnView.frame = CGRectMake(position+55, 0.0f, 120+30.0f, 90+30.0f);
	
	[returnView addSubview:bubbleImageView];
    return returnView;
}
#pragma mark 泡泡视频
- (UIView *)videoView:(BOOL)fromSelf
{//时间长度可以学习语音的传值
    //主要是横屏和竖屏 宽高比例
	UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
	returnView.backgroundColor = [UIColor clearColor];
	
    //背影图片
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"SenderVoiceNodeDownloading":@"ReceiverTextNodeBkg" ofType:@"png"]];
    
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height/2)]];
	
	bubbleImageView.frame = CGRectMake(0.0f, 14.0f, 120.0f, 140.0f);
    
	if(fromSelf)
		returnView.frame = CGRectMake(140.0f, 0.0f, 120.0f, 150.0f);
	else
		returnView.frame = CGRectMake(55, 0.0f, 120.0f, 150.0f);
	
	[returnView addSubview:bubbleImageView];    
    return returnView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fmdbmessages count];//0条就返回0
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dict = [self.fmdbmessages objectAtIndex:indexPath.row];
    NSLog(@"-------> %@",self.fmdbmessages);
    NSString *sender = [dict objectForKey:@"sender"];//发送者
    NSString *message = [dict objectForKey:@"msg"];//消息
    NSString *time = [dict objectForKey:@"time"];//时间
    NSString *type = [dict objectForKey:@"type"];//时间
    NSString *url = [dict objectForKey:@"url"];//时间
    NSString *surl=[dict objectForKey:@"smp"];//小图地址
    NSString *vtime=[dict objectForKey:@"vtime"];
    NSLog(@"在本地转换后的聊天信息%@",message);
    
    //---------------------日期和时间---------------------------------
    UILabel* senderAndTimeLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 20)];
    senderAndTimeLabel.textAlignment = UITextAlignmentCenter;
    senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
    senderAndTimeLabel.textColor = [UIColor lightGrayColor];
    senderAndTimeLabel.text=[NSString stringWithFormat:@"%@ %@",sender,time];
    senderAndTimeLabel.backgroundColor=[UIColor clearColor];
    //photo也可以提取出来//创建头像
    UIImageView *photo;
    if ([sender isEqualToString:@"a2"]){
        photo = [[UIImageView alloc]initWithFrame:CGRectMake(320-60, 10, 50, 50)];
        NSURL *piUrl=[NSURL URLWithString:headImagemeurlstring];
        photo.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:piUrl]];
    }else{
        photo = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
        NSURL *piUrl=[NSURL URLWithString:headImageurlstring];
        photo.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:piUrl]];
    }
    //------------------------------------------------------
    if ([type isEqualToString:@"text"]) {
        //文字还要有限度，不能发送太多
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }else{
            for (UIView *cellView in cell.subviews){
                [cellView removeFromSuperview];
            }
        }
        if ([sender isEqualToString:@"a2"]) {
            [cell addSubview:[self bubbleView:message from:YES withPosition:65]];
        }else{
            [cell addSubview:[self bubbleView:message from:NO withPosition:65]];
        }
        [cell addSubview:senderAndTimeLabel];
        [cell addSubview:photo];
        return cell;
    }else if ([type isEqualToString:@"voice"]){
        static NSString *CellIdentifier = @"voiCell";
        UITableViewCell *vicell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (vicell == nil) {
            vicell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            vicell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }else{
            for (UIView *cellView in vicell.subviews){
                [cellView removeFromSuperview];
            }
        }
        if ([sender isEqualToString:@"a2"]) {
            int voicetime=[vtime intValue];
            [vicell addSubview:[self yuyinView:voicetime from:YES withIndexRow:indexPath.row withPosition:65 withUrl:url]];
        }else{
            [vicell addSubview:[self yuyinView:2 from:NO withIndexRow:indexPath.row withPosition:65 withUrl:url]];
        }
        [vicell addSubview:photo];
        [vicell addSubview:senderAndTimeLabel];
        return vicell;
    }else if ([type isEqualToString:@"picture"]){
        static NSString *CellIdentifier = @"vimCell";
        UITableViewCell *vimcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (vimcell == nil) {
            vimcell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            vimcell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }else{
            for (UIView *cellView in vimcell.subviews){
                [cellView removeFromSuperview];
            }
        }
        UIButton *imageButton=[UIButton buttonWithType:UIButtonTypeCustom];
        imageButton.tag=10000;
        [imageButton setTitle:url forState:UIControlStateNormal];
        [imageButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [imageButton addTarget:self action:@selector(seeBigImage:) forControlEvents:UIControlEventTouchUpInside];
        if ([sender isEqualToString:@"a2"]) {
            NSURL *piUrl=[NSURL URLWithString:url];
            UIImage *backG=[UIImage imageWithData:[NSData dataWithContentsOfURL:piUrl]];
            CGSize size = CGSizeMake(120,88);  // 设置尺寸
            backG=[UIImage createRoundedRectImage:backG size:size radius:6];
            [vimcell addSubview:[self pictureView:YES withPosition:indexPath.row]];
            
            [imageButton setBackgroundImage:backG forState:UIControlStateNormal];
            imageButton.frame=CGRectMake(115, 20, 120, 88);
            //120, 20, backG.size.width, backG.size.height
            [vimcell addSubview:imageButton];
        }else{
            [vimcell addSubview:[self pictureView:NO withPosition:indexPath.row]];
            
            NSURL *piUrl=[NSURL URLWithString:url];
            UIImage *backG=[UIImage imageWithData:[NSData dataWithContentsOfURL:piUrl]];
            CGSize size = CGSizeMake(120,88);  // 设置尺寸
            backG=[UIImage createRoundedRectImage:backG size:size radius:6];
            [imageButton setBackgroundImage:backG forState:UIControlStateNormal];
            imageButton.frame=CGRectMake(85, 20, 120, 88);
            //120, 20, backG.size.width, backG.size.height
            [vimcell addSubview:imageButton];
        }
        [vimcell addSubview:photo];
        [vimcell addSubview:senderAndTimeLabel];
        return vimcell;
    }else if ([type isEqualToString:@"video"]){
        static NSString *CellIdentifier = @"vidCell";
        UITableViewCell *vidcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (vidcell == nil) {
            vidcell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            vidcell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }else{
            for (UIView *cellView in vidcell.subviews){
                [cellView removeFromSuperview];
            }
        }
        UIButton *videoButton=[UIButton buttonWithType:UIButtonTypeCustom];
        videoButton.tag=10000;
        [videoButton setTitle:url forState:UIControlStateNormal];
        [videoButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [videoButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];//图片背景地址也可以过来
        UILabel *label=[[UILabel alloc]init];
        label.backgroundColor=[UIColor clearColor];
        [videoButton addSubview:label];
        //添加一个播放三角形按钮
        UIButton *sanjiao=[[UIButton alloc]init];
        [sanjiao setBackgroundImage:[UIImage imageNamed:@"video_play.png"] forState:UIControlStateNormal];
        sanjiao.frame=CGRectMake(28, 43, 34, 34);
        [videoButton addSubview:sanjiao];
        if ([sender isEqualToString:@"a2"]) {
            NSURL *spurl=[NSURL URLWithString:surl];
            UIImage *backG=[UIImage imageWithData:[NSData dataWithContentsOfURL:spurl]];
            CGSize size = CGSizeMake(90,116);  // 设置尺寸
            backG=[UIImage createRoundedRectImage:backG size:size radius:6];
            [vidcell addSubview:[self videoView:YES]];
            [videoButton setBackgroundImage:backG forState:UIControlStateNormal];
            videoButton.frame=CGRectMake(153, 22, 90, 116);
            
            label.frame=CGRectMake(10, 100, 80, 20);
            label.text=vtime;
            [vidcell addSubview:videoButton];
        }else{
            NSURL *piUrl=[NSURL URLWithString:url];
            UIImage *backG=[UIImage imageWithData:[NSData dataWithContentsOfURL:piUrl]];
            CGSize size = CGSizeMake(90,116);  // 设置尺寸
            backG=[UIImage createRoundedRectImage:backG size:size radius:6];
            [vidcell addSubview:[self videoView:NO]];
            
            [videoButton setBackgroundImage:backG forState:UIControlStateNormal];
            videoButton.frame=CGRectMake(75, 20, 90, 116);

            label.frame=CGRectMake(10, 100, 80, 20);
            label.text=vtime;
            [vidcell addSubview:videoButton];
        }
        [vidcell addSubview:photo];
        [vidcell addSubview:senderAndTimeLabel];
        return vidcell;

    }else{//这个可以不要
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
        [vcell addSubview:photo];
        [vcell addSubview:senderAndTimeLabel];
        return vcell;
    }
}
#pragma mark
#pragma mark 点击图片放大显示，单独view
-(void)seeBigImage:(id)sender
{
    UIButton *image = (UIButton *)sender;
    if (image.tag==100000) {
        NSLog(@"t.text  %@",image.titleLabel.text);
    }
    NSLog(@"imageview点击事件ok");
    SeePictureViewController *seepic=[[SeePictureViewController alloc]init];
    NSURL *imaUrl=[NSURL URLWithString:image.titleLabel.text];
    seepic.url=imaUrl;
    [self presentViewController:seepic animated:YES completion:nil];
    //长按复制有了，删除这些了，滑动删除等等什么的
    //发送名片也不需要了
}
#pragma mark 播放录音
-(void)playRecordSound:(id)sender
{
    UIButton *playButton = (UIButton *)sender;
    if (playButton.tag==20000) {
        NSLog(@"playButton  %@",playButton.titleLabel.text);
    }
    NSLog(@"播放录音");
    NSURL *vUrl=[NSURL URLWithString:playButton.titleLabel.text];
    if (self.avPlay.playing) {
        [self.avPlay stop];
        return;
    }
    AVAudioPlayer *player=[[AVAudioPlayer alloc]initWithContentsOfURL:vUrl error:nil];
    self.avPlay=player;
    [self.avPlay play];
//    NSLog(@"播放录音");
//    NSURL *url=[voiceDictionary objectForKey:@"voiceurl"];
//    NSLog(@"%@",url);
//    //    //2 NSString转换成NSURL
//    //    NSURL * url = [NSURL URLWithString:urlStr];
//    //    NSURL * url = [[NSURL alloc] initWithString:urlStr];
//    if (self.avPlay.playing) {
//        [self.avPlay stop];
//        return;
//    }
//    AVAudioPlayer *player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
//    self.avPlay = player;
//    [self.avPlay play];
}
-(void)playVideo:(id)sender
{
    NSLog(@"点击");
    UIButton *t = (UIButton *)sender;
    if (t.tag==10000) {
        NSLog(@"t.titleLabel.text  %@",t.titleLabel.text);
    }
    NSURL *viUrl=[NSURL URLWithString:t.titleLabel.text];
    NSLog(@"开始播放视频");
    //------------------------------------------------------
    playerViewController=[[MPMoviePlayerViewController alloc]initWithContentURL:viUrl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[playerViewController moviePlayer]];
    playerViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:playerViewController animated:YES];
    MPMoviePlayerController *player = [playerViewController moviePlayer];
    [player play];
    //------------------------------------------------------
//    PlayVideoViewController *playv=[[PlayVideoViewController alloc]init];
//    playv.url=viUrl;
//    [self presentViewController:playv animated:YES completion:nil];
}
//------------------------------------------------------
-(void)playVideoFinished:(NSNotification *)theNotification
//当点击Done按键或者播放完毕时调用此函数
{
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [playerViewController dismissModalViewControllerAnimated:YES];
}
//------------------------------------------------------
//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dict = [self.fmdbmessages objectAtIndex:indexPath.row];
    NSLog(@"-------> %@",self.fmdbmessages);
    NSString *type = [dict objectForKey:@"type"];
    if ([type isEqualToString:@"text"]) {
        NSMutableDictionary *dict  = [self.fmdbmessages objectAtIndex:indexPath.row];
        NSString *msg = [dict objectForKey:@"msg"];
        //NSDictionary *dict = [self.fmdbmessages objectAtIndex:indexPath.row];
        UIFont *font = [UIFont systemFontOfSize:14];
        CGSize size = [msg sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
        return size.height+44;
        
//        NSMutableDictionary *dict  = [self.fmdbmessages objectAtIndex:indexPath.row];
//        NSString *msg = [dict objectForKey:@"msg"];
//        
//        CGSize textSize = {260.0 , 10000.0};
//        CGSize size = [msg sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
//        size.height += padding*2;
//        CGFloat height = size.height < 65 ? 65 : size.height;
//        return height;
    }else if ([type isEqualToString:@"voice"]){
        return 60;
        //录音语音随着音响变大而变大
    }else if ([type isEqualToString:@"picture"]){
        return 120;
    }else if ([type isEqualToString:@"video"]){
        return 150;
    }
//    else if ([type isEqualToString:@"biaoqing"]){
//        return 40;
//    }
    else{
        return 50;
    }
}
-(void)picture:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;//no
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:^{}];
    //在下面还要判断来自相册还是现拍，视频因为只有10秒，还坑爹的马赛克1m所以只能现拍，iOS微信不能上传
}
-(void)video:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray *temp_MediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        picker.mediaTypes = temp_MediaTypes;
        picker.videoMaximumDuration=10.0f;//限制10s
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
        sendText.text= @"";
        [sendText resignFirstResponder];
        //------------------------------------------------------
        NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
        NSLog(@"array:%@",array);
        NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到

        NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
        [dateformat setDateFormat:@"yyyyMMddHHmmss"];
        NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
        
        NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *pictureurl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.jpg", strUrl,[dateformat stringFromDate:[NSDate date]]]];
        
        NSString* pictureurlstring=[pictureurl absoluteString];//NSURL转换成NSString
        
        [self writeToFile:imgData :[NSString stringWithFormat:@"%@/%@.jpg", strUrl,[dateformat stringFromDate:[NSDate date]]]];
        NSLog(@"pictureurlstring %@",pictureurlstring);
        [self addSql:@"a2" andsender:@"a2" andmessade:nil andBigurl:pictureurl andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"picture" andVoicetime:nil andSmallpicture:nil];
        [self ssf];
        [chatView reloadData];
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
        
        NSData *avData = [NSData dataWithContentsOfFile:videoFile];
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
        sendText.text = @"";
        [sendText resignFirstResponder];
        //------------------------------------------------------
        NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
        NSLog(@"array:%@",array);
        NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到
        
        NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
        [dateformat setDateFormat:@"yyyyMMddHHmmss"];
        NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
        NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *videourl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mov", strUrl,[dateformat stringFromDate:[NSDate date]]]];
        NSString* videourlstring=[videourl absoluteString];//NSURL转换成NSString
        [self writeToFile:avData :[NSString stringWithFormat:@"%@/%@.mov", strUrl,[dateformat stringFromDate:[NSDate date]]]];
        NSLog(@"pictureurlstring %@",videourlstring);
        //------------------------------------------------------
        //用系统自带的录制视频，在保存视频的时候，我用以下方法得到了缩略图
        MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:videoURL] ;
        UIImage *thumbnail = [player thumbnailImageAtTime:0.1 timeOption:MPMovieTimeOptionNearestKeyFrame];
        player = nil;
        NSData *videoImage=UIImageJPEGRepresentation(thumbnail, 1.0);
        NSURL *videoimageurl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.jpg", strUrl,[dateformat stringFromDate:[NSDate date]]]];
        [self writeToFile:videoImage :[NSString stringWithFormat:@"%@/%@.jpg", strUrl,[dateformat stringFromDate:[NSDate date]]]];
        //因为时间限制在10秒,所以不需要转换成秒
        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:videourl options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds=CMTimeGetSeconds(audioDuration);
        NSLog(@"播放时间 %f",audioDurationSeconds);
        NSString *videoTime=[NSString stringWithFormat:@"%0.2f",audioDurationSeconds];
        //------------------------------------------------------
        [self addSql:@"a2" andsender:@"a2" andmessade:nil andBigurl:videourl andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"video" andVoicetime:videoTime andSmallpicture:videoimageurl];
        [self ssf];
        [chatView reloadData];//大图
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
    NSString *message =sendText.text;
    NSString *addmessage =sendText.text;
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
        
        sendText.text = @"";
        
        //------------------------------------------------------
        NSArray *array=[self.chatWithUser componentsSeparatedByString:@"@"];//从字符A中分隔成2个元素的数组
        NSLog(@"array:%@",array);
        NSString *nowUser=[array objectAtIndex:0];//a2是登陆者.需要获取后得到
        [self addSql:@"a2" andsender:@"a2" andmessade:addmessage andBigurl:nil andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"text" andVoicetime:nil andSmallpicture:nil];
        //重新刷新tableView
        [self ssf];
        [chatView reloadData];
    }
}//点击键盘，不发送，点击语音需要退出键盘响应//文字发了不退

#pragma mark - 接收到的消息
#pragma mark KKMessageDelegate
-(void)newMessageReceived:(NSDictionary *)messageCotent{
    NSString *asmpString=[[NSString alloc]init];
    
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
        NSURL *voiceurl;
        NSString *voiceString= [textDic objectForKey:@"data"];
        if (!voiceString) {
            NSString *urlString=[textDic objectForKey:@"link"];
            voiceurl=[NSURL URLWithString:urlString];
            //[textDic setObject:string forKey:@"group"];
            //暂时不考虑群组，群组单独吧
        }else{
            NSDateFormatter *dateformat=[[NSDateFormatter alloc]init];
            [dateformat setDateFormat:@"yyyyMMddHHmmss"];
            NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
            NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            voiceurl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.aac", strUrl,[dateformat stringFromDate:[NSDate date]]]];
            voiceDictionary=[[NSMutableDictionary alloc]init];
            [voiceDictionary setObject:voiceurl forKey:@"voiceurl"];
            voiceurlstring=[voiceurl absoluteString];//NSURL转换成NSString
            getvoiceData=[voiceString base64DecodedData];
            [self writeToFile:getvoiceData:[NSString stringWithFormat:@"%@/%@.aac",strUrl,[dateformat stringFromDate:[NSDate date]]]];
            NSLog(@"voiceurlstring %@",voiceurlstring);
        }
        NSString *voiceTime=[textDic objectForKey:@"duration"];
        int vt=[voiceTime intValue];
        [self addSql:@"a2" andsender:senderName andmessade:nil andBigurl:voiceurl andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"voice" andVoicetime:voiceTime andSmallpicture:@"小兔解析地址"];
        
        asmpString=[NSString stringWithFormat:@"%@发来一条语音",senderName];
    }else if ([msg hasPrefix:@"<Text>"]){
        NSLog(@"Text");
        NSString* Textmessage=[textDic objectForKey:@"content"];
        //[textDic setObject:string forKey:@"group"];
        [self addSql:@"a2" andsender:senderName andmessade:Textmessage andBigurl:nil andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"text" andVoicetime:nil andSmallpicture:@"小兔解析地址"];
        
        asmpString=[NSString stringWithFormat:@"%@:%@",senderName,Textmessage];
    }else if ([msg hasPrefix:@"<Picture>"]){
        NSLog(@"Picture");
        NSString *imgString= [textDic objectForKey:@"data"];
        NSURL *pictureurl;
        if (!imgString) {
            NSString *urlString=[textDic objectForKey:@"link"];
            pictureurl=[NSURL URLWithString:urlString];
            //[textDic setObject:string forKey:@"group"];
            //暂时不考虑群组，群组单独吧...小兔暂时不考虑
            //[textDic setObject:string forKey:@"png"];
        }else{
            NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
            [dateformat setDateFormat:@"yyyyMMddHHmmss"];
            NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
            
            NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            pictureurl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.jpg", strUrl,[dateformat stringFromDate:[NSDate date]]]];
            NSString* pictureurlstring=[pictureurl absoluteString];//NSURL转换成NSString
            NSData *imgData=[imgString base64DecodedData];
            [self writeToFile:imgData :[NSString stringWithFormat:@"%@/%@.jpg", strUrl,[dateformat stringFromDate:[NSDate date]]]];
            NSLog(@"pictureurlstring %@",pictureurlstring);
        }
        [self addSql:@"a2" andsender:senderName andmessade:nil andBigurl:pictureurl andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"picture" andVoicetime:nil andSmallpicture:nil];
        
        asmpString=[NSString stringWithFormat:@"%@发来一张图片",senderName];
    }else if ([msg hasPrefix:@"<Video>"]){
        NSLog(@"Video");
        NSString *avString= [textDic objectForKey:@"data"];
        NSURL *videourl;
        if (!avString) {
            NSString *urlString=[textDic objectForKey:@"link"];
            videourl=[NSURL URLWithString:urlString];
            //[textDic setObject:string forKey:@"group"];
            //暂时不考虑群组，群组单独吧...小兔暂时不考虑
            //[textDic setObject:string forKey:@"png"];
        }else{
            NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
            [dateformat setDateFormat:@"yyyyMMddHHmmss"];
            NSLog(@"当前时间%@",[dateformat stringFromDate:[NSDate date]]);
            NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            videourl=[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.mov", strUrl,[dateformat stringFromDate:[NSDate date]]]];
            NSString* videourlstring=[videourl absoluteString];//NSURL转换成NSString
            NSData *avData=[avString base64DecodedData];
            [self writeToFile:avData :[NSString stringWithFormat:@"%@/%@.mov", strUrl,[dateformat stringFromDate:[NSDate date]]]];
            NSLog(@"pictureurlstring %@",videourlstring);
        }
        [self addSql:@"a2" andsender:senderName andmessade:nil andBigurl:videourl andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"video" andVoicetime:nil andSmallpicture:nil];
        
        asmpString=[NSString stringWithFormat:@"%@发来一段视频",senderName];
    }else{
        //文字...表情
        [self addSql:@"a2" andsender:senderName andmessade:msg andBigurl:nil andsendtime:time andisread:0 andReceiver:@"a2" andMessagetype:@"text" andVoicetime:nil andSmallpicture:nil];//if not nowuser no get message
    }
    //------------------------------------------------------
    //每次执行sql和每次写变量一样
    [self ssf];
    [chatView reloadData];
    //------------------------------------------------------
    UILocalNotification *l=[[UILocalNotification alloc]init];
    l.fireDate=[[NSDate alloc]initWithTimeIntervalSinceNow:1];//
    l.alertBody=asmpString;
    //l.applicationIconBadgeNumber=1;
    l.soundName=UILocalNotificationDefaultSoundName;
    //l.soundName=@"lbxxztq.mp3";//铃声没用,可能是模拟器问题
    l.alertAction=@"f";
    //l.alertLaunchImage
    //[[UIApplication sharedApplication]presentLocalNotificationNow:l];//立即通知，这个方法就是立即通知按钮触发的
    [[UIApplication sharedApplication]scheduleLocalNotification:l];//定时通知
    //事件也要做
    //------------------------------------------------------
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
    //每次都执行，所以每次再清空
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
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([currentTagName isEqualToString:@"Content"]) {
        [textDic setObject:string forKey:@"content"];
        NSLog(@"文本内容 %@",[textDic objectForKey:@"content"]);
	}else if ([currentTagName isEqualToString:@"Data"]) {
        [textDic setObject:string forKey:@"data"];
        NSLog(@"data内容 %@",[textDic objectForKey:@"data"]);
	}else if ([currentTagName isEqualToString:@"Group"]){
        [textDic setObject:string forKey:@"group"];
    }else if ([currentTagName isEqualToString:@"Link"]){
        [textDic setObject:string forKey:@"link"];
    }else if ([currentTagName isEqualToString:@"PNG"]){
        [textDic setObject:string forKey:@"png"];
    }else if ([currentTagName isEqualToString:@"Duration"]){
        [textDic setObject:string forKey:@"duration"];
    }
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


#pragma mark
#pragma mark 按下不送开始录音
- (void)btnDown:(id)sender
{
    if ([recorder prepareToRecord]) {
        [recorder record];
    }
}
#pragma mark 松开按钮发送
- (void)btnUp:(id)sender
{
    cTime = recorder.currentTime;
    NSLog(@"%f",cTime);
    NSLog(@"播放2时间%f",recorder.currentTime);
    if (cTime >1) {
        NSLog(@"发出去");
        [recorder stop];
        [self sendVoice];
    }else {
        [recorder deleteRecording];
        [recorder stop];
        UIAlertView *al=[[UIAlertView alloc]initWithTitle:@"发送失败" message:@"时间太短小于1秒" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"重录", nil];
        [al show];//可以换成toast 
    }
}

#pragma mark sender voice
-(void)sendVoice{
    NSData *voiceData = [[NSData alloc] initWithContentsOfURL:urlPlay];
    NSLog(@"voiceData %@",voiceData);
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
    sendText.text = @"";
    [sendText resignFirstResponder];
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
    [self addSql:@"a2" andsender:@"a2" andmessade:nil andBigurl:voiceurl andsendtime:[Statics getCurrentTime] andisread:0 andReceiver:nowUser andMessagetype:@"voice" andVoicetime:@"2" andSmallpicture:nil];
//    VOICETIME=ctime
    [self ssf];
    [chatView reloadData];
}

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
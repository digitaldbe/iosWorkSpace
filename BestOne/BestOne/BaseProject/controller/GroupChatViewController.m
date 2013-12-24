//
//  GroupChatViewController.m
//  BaseProject
//
//  Created by ioschen on 13-12-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "GroupChatViewController.h"
#import "GPeopleViewController.h"
@interface GroupChatViewController ()

@end

@implementation GroupChatViewController

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
    [self CGRectMakeMainView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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
    frame.origin.y = screenHeight- 40;//lxf
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
#pragma mark -创建View
#pragma mark 创建navbar
-(void)CGRectMakeNavBar
{
    UIView *naView=[[UIView alloc]init];
    naView.backgroundColor=[UIColor colorWithRed:(37/255.0) green:(23/255.0) blue:(10/255.0) alpha:1];
    naView.frame=CGRectMake(0, 0, 320, 44);
    [self.view addSubview:naView];
    
    UILabel *zhLabel=[[UILabel alloc]initWithFrame:CGRectMake(140, 4, 100, 40)];
    zhLabel.text=@"群聊的名字";
    zhLabel.font=[UIFont boldSystemFontOfSize:20];//字体需要调整
    zhLabel.backgroundColor=[UIColor clearColor];
    zhLabel.textColor=[UIColor colorWithRed:(225/255.0) green:(242/255.0) blue:(0/255.0) alpha:1];
    [naView addSubview:zhLabel];
    
    UIButton *backbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    backbutton.frame=CGRectMake(20, 15, 18, 18);
    [backbutton setBackgroundImage:[UIImage imageNamed:@"topback_yellow@2x.png"] forState:UIControlStateNormal];
    [backbutton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [naView addSubview:backbutton];
    
    UIButton *peopleListbutton=[UIButton buttonWithType:UIButtonTypeCustom];
    peopleListbutton.frame=CGRectMake(280, 15, 18, 18);
    [peopleListbutton setBackgroundImage:[UIImage imageNamed:@"topgroupchat@2x.png"] forState:UIControlStateNormal];
    [peopleListbutton addTarget:self action:@selector(peopleList) forControlEvents:UIControlEventTouchUpInside];
    [naView addSubview:peopleListbutton];
}
-(void)CGRectMakeMainView
{
    //聊天
    chatView=[[UITableView alloc]initWithFrame:CGRectMake(0, 44, 320, self.view.frame.size.height-88) style:UITableViewStylePlain];
    chatView.backgroundColor=[UIColor colorWithRed:(217/255.0) green:(220/255.0) blue:(219/255.0) alpha:1];
    chatView.separatorStyle=UITableViewCellSeparatorStyleNone;
    chatView.dataSource=self;
    chatView.delegate=self;
    //chatView addGestureRecognizer:<#(UIGestureRecognizer *)#>
    [self.view addSubview:chatView];
    //语音
    typeMessage=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-44, 320, 248)];
    typeMessage.backgroundColor=[UIColor redColor];
    [self.view addSubview:typeMessage];//整体
    
    voiceView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    voiceView.backgroundColor=[UIColor colorWithRed:(89/255.0) green:(86/255.0) blue:(87/255.0) alpha:1];
    [typeMessage addSubview:voiceView];//语音键盘等
    keyboardButton=[UIButton buttonWithType:UIButtonTypeCustom];
    keyboardButton.frame=CGRectMake(0, 0, 44, 44);
    //[keyboardButton setTitle:@"keyb" forState:UIControlStateNormal];
    [keyboardButton setBackgroundImage:[UIImage imageNamed:@"button7type_a.png"] forState:UIControlStateNormal];
    [keyboardButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    keyboardButton.tag=100;
    [voiceView addSubview:keyboardButton];
    UIButton *sayButton=[UIButton buttonWithType:UIButtonTypeCustom];
    sayButton.frame=CGRectMake(88, 0, 232, 44);
    //[sayButton setTitle:@"say" forState:UIControlStateNormal];
    [sayButton setBackgroundImage:[UIImage imageNamed:@"button7holdtotalk_a.png"] forState:UIControlStateNormal];
    [voiceView addSubview:sayButton];
    voiceButton=[UIButton buttonWithType:UIButtonTypeCustom];
    voiceButton.frame=CGRectMake(0, 0, 44, 44);
    //[voiceButton setTitle:@"voice" forState:UIControlStateNormal];
    [voiceButton setBackgroundImage:[UIImage imageNamed:@"button7talk_a.png"] forState:UIControlStateNormal];
    [voiceButton addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    voiceButton.tag=101;
    [voiceView addSubview:voiceButton];
    UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame=CGRectMake(44, 0, 44, 44);
    [addButton setBackgroundImage:[UIImage imageNamed:@"button7addon_a.png"] forState:UIControlStateNormal];
    //[addButton setTitle:@"add" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addShow) forControlEvents:UIControlEventTouchUpInside];
    [voiceView addSubview:addButton];
    sendText=[[UITextField alloc]initWithFrame:CGRectMake(88, 0, 188, 44)];
    sendText.backgroundColor=[UIColor grayColor];
    [sendText addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [voiceView addSubview:sendText];
    sendButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.frame=CGRectMake(276, 0, 44, 44);
    [sendButton setTitle:@"send" forState:UIControlStateNormal];
    [voiceView addSubview:sendButton];
    
    biaoqingView=[[UIView alloc]initWithFrame:CGRectMake(0, 44, 320, 204)];
    biaoqingView.backgroundColor=[UIColor colorWithRed:(37/255.0) green:(23/255.0) blue:(19/255.0) alpha:1];
    [typeMessage addSubview:biaoqingView];//表情
    
    moreView=[[UIView alloc]initWithFrame:CGRectMake(0, 44, 320, 64)];
    moreView.backgroundColor=[UIColor colorWithRed:(37/255.0) green:(23/255.0) blue:(19/255.0) alpha:1];
    [typeMessage addSubview:moreView];//图片视频等
    UIButton *biaoqingButton=[UIButton buttonWithType:UIButtonTypeCustom];
    biaoqingButton.frame=CGRectMake(0, 0, 44, 44);
    [biaoqingButton setBackgroundImage:[UIImage imageNamed:@"button7emotion_a.png"] forState:UIControlStateNormal];
    //[biaoqingButton setTitle:@"love" forState:UIControlStateNormal];
    [biaoqingButton addTarget:self action:@selector(biqoaingShow) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:biaoqingButton];
    UILabel *biaoqingLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 44, 44, 20)];
    biaoqingLabel.text=@"表情";
    [moreView addSubview:biaoqingLabel];
    UIButton *imgButton=[UIButton buttonWithType:UIButtonTypeCustom];
    imgButton.frame=CGRectMake(44, 0, 44, 44);
    [imgButton setBackgroundImage:[UIImage imageNamed:@"button7img_a.png"] forState:UIControlStateNormal];
    [moreView addSubview:imgButton];
    UILabel *imgLabel=[[UILabel alloc]initWithFrame:CGRectMake(44, 44, 44, 20)];
    imgLabel.text=@"图片";
    [moreView addSubview:imgLabel];
    UIButton *videoButton=[UIButton buttonWithType:UIButtonTypeCustom];
    videoButton.frame=CGRectMake(88, 0, 44, 44);
    [videoButton setBackgroundImage:[UIImage imageNamed:@"button7video_a.png"] forState:UIControlStateNormal];
    [moreView addSubview:videoButton];
    UILabel *videoLabel=[[UILabel alloc]initWithFrame:CGRectMake(88, 44, 44, 20)];
    videoLabel.text=@"视频";
    [moreView addSubview:videoLabel];
}
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
#pragma mark
#pragma mark tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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
    
    cell.textLabel.text=@"hello Best One";
    return cell;
}


-(void)back{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)peopleList
{
    GPeopleViewController *gpeople=[[GPeopleViewController alloc]init];
    [self presentViewController:gpeople animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

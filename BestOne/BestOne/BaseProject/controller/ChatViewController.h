//
//  ChatViewController.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKMessageDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface ChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,KKMessageDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate,NSXMLParserDelegate>
{
    FMDatabase *db;
    AVAudioRecorder *recorder;
    NSURL *urlPlay;
    double cTime;//录音时间
    
    //NSMutableArray *messages;
    //CGPoint originCenter;
    
    NSString* currentTagName;
    NSMutableDictionary *textDic;
    
    NSData *getvoiceData;//收到的语音
    NSMutableDictionary *voiceDictionary;
    
    NSMutableDictionary *fmdbdictionary;//linshisavedata
}
@property(nonatomic, retain) NSString *voiceurlstring;
@property (retain, nonatomic) AVAudioPlayer *avPlay;

@property(nonatomic, retain) NSString *chatWithUser;

@property (retain, nonatomic) IBOutlet UITableView *tView;
@property (retain, nonatomic) IBOutlet UITextField *messageTextField;
//@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UIView *sendView;
@property (retain, nonatomic) IBOutlet UIButton *talkButton;
@property (retain, nonatomic) IBOutlet UIButton *keyButton;
@property (retain, nonatomic) IBOutlet UIButton *addButton;
@property (retain, nonatomic) IBOutlet UIButton *recordBtn;//发送语音

- (IBAction)biaoQing:(id)sender;//发送表情
- (IBAction)picture:(id)sender;//发送图片，照片
- (IBAction)video:(id)sender;//发送视频


- (IBAction)sendButton:(id)sender;
//- (IBAction)closeButton:(id)sender;

-(IBAction)btnAction:(id)sender;
-(IBAction)jianopan:(id)sender;

//- (IBAction)playRecordSound:(id)sender;
@end


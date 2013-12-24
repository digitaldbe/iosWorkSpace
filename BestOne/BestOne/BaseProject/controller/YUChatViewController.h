//
//  YUChatViewController.h
//  BestOne
//
//  Created by ioschen on 13-12-11.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKMessageDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>//获取视频时间
#import "UIImage+wiRoundedRectImage.h"
@interface YUChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,KKMessageDelegate,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate,NSXMLParserDelegate,UIScrollViewDelegate>
{
    NSMutableDictionary *emotiondata;
    
    MPMoviePlayerViewController *playerViewController;
    
    UITableView *chatView;
    UIView *typeMessage;//整体
    UIView *voiceView;//语音键盘等
    UIView *moreView;//图片视频等
    UIScrollView *biaoqingView;//表情
    
    NSMutableArray *emotionArray;//存放表情的动态数组
    
    UIButton *voiceButton;
    UIButton *keyboardButton;
    UITextField *sendText;
    UIButton *sendButton;
    
    //------------------------------------------------------
    FMDatabase *db;
    AVAudioRecorder *recorder;
    NSURL *urlPlay;
    double cTime;//录音时间
    
    UIImagePickerController *pickerImage;
    //NSMutableArray *messages;
    //CGPoint originCenter;
    BOOL isShareMore;
    UIImage *uploadImg;
    
    NSString* currentTagName;
    NSMutableDictionary *textDic;
    
    NSData *getvoiceData;//收到的语音
    NSMutableDictionary *voiceDictionary;
    NSMutableDictionary *fmdbdictionary;//linshisavedata
    //------------------------------------------------------
}
@property(nonatomic, retain) NSString *headImageurlstring;
@property(nonatomic, retain) NSString *headImagemeurlstring;
@property(nonatomic, retain) NSString *voiceurlstring;
@property (retain, nonatomic) AVAudioPlayer *avPlay;

@property(nonatomic, retain) NSString *chatWithUser;

@end


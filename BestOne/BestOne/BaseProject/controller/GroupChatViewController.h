//
//  GroupChatViewController.h
//  BaseProject
//
//  Created by ioschen on 13-12-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *chatView;
    NSMutableArray* chatMessage;
    
    UIView *typeMessage;//整体
    UIView *voiceView;//语音键盘等
    UIView *moreView;//图片视频等
    UIView *biaoqingView;//表情
    
    UIButton *voiceButton;
    UIButton *keyboardButton;
    UITextField *sendText;
    UIButton *sendButton;
}
@end

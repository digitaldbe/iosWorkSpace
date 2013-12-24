//
//  VoiceCell.m
//  BaseProject
//
//  Created by ioschen on 13-12-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "VoiceCell.h"

@implementation VoiceCell
@synthesize senderAndTimeLabel;
//@synthesize bgImageView;
@synthesize voicebutton;
@synthesize headImageView;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //日期标签
        senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
        //居中显示
        senderAndTimeLabel.textAlignment = UITextAlignmentCenter;
        senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        //文字颜色
        senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:senderAndTimeLabel];

//        //背景图
//        bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//        [self.contentView addSubview:bgImageView];
        
        voicebutton=[UIButton buttonWithType:UIButtonTypeCustom];
        [voicebutton setBackgroundImage:[UIImage imageNamed:@"chatbox1.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:voicebutton];
        
        headImageView=[[UIImageView alloc] init];
        headImageView.image=[UIImage imageNamed:@"iconchatfriends.png"];
        [self.contentView addSubview:headImageView];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
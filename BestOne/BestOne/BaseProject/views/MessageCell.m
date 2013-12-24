//
//  MessageCell.m
//  BestOne
//
//  Created by ioschen on 13-12-16.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell
@synthesize senderAndTimeLabel;
@synthesize messageContentView;
@synthesize bgImageView;
@synthesize headImageView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
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
        
        //背景图
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:bgImageView];
        
        enum {
            UIDataDetectorTypePhoneNumber   = 1 << 0,          // Phone number detection
            UIDataDetectorTypeLink          = 1 << 1,          // URL detection
#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
            UIDataDetectorTypeAddress       = 1 << 2,          // Street address detection
            UIDataDetectorTypeCalendarEvent = 1 << 3,          // Event detection
#endif
            UIDataDetectorTypeNone          = 0,               // No detection at all
            UIDataDetectorTypeAll           = NSUIntegerMax    // All types
        };
        typedef NSUInteger UIDataDetectorTypes;

        //聊天信息
        messageContentView = [[UITextView alloc] init];
        messageContentView.backgroundColor = [UIColor clearColor];
        //不可编辑
        messageContentView.editable = NO;
        messageContentView.dataDetectorTypes=UIDataDetectorTypeAll;
        messageContentView.scrollEnabled = NO;
        [messageContentView sizeToFit];
        [self.contentView addSubview:messageContentView];
        
        headImageView=[[UIImageView alloc] init];
        headImageView.image=[UIImage imageNamed:@"iconchatfriends.png"];
        [self.contentView addSubview:bgImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
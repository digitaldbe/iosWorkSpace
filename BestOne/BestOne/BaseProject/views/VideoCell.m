//
//  VideoCell.m
//  BestOne
//
//  Created by ioschen on 13-12-13.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell
@synthesize videoButton;
@synthesize headImageView;
@synthesize senderAndTimeLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //日期标签
        senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
        //居中显示
        senderAndTimeLabel.textAlignment = UITextAlignmentCenter;
        senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        //文字颜色
        senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        senderAndTimeLabel.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:senderAndTimeLabel];
        
        videoButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [videoButton setBackgroundColor:[UIColor redColor]];
        [self.contentView addSubview:videoButton];
        
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

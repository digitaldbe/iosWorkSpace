//
//  ImageCell.m
//  BestOne
//
//  Created by ioschen on 13-12-16.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell
//@synthesize imageInfo;
@synthesize headImageView;
@synthesize senderAndTimeLabel;
@synthesize imageurlButton;
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
        
//        imageInfo=[[UIImageView alloc]init];
//        [self.contentView addSubview:imageInfo];
        
        headImageView=[[UIImageView alloc] init];
        headImageView.image=[UIImage imageNamed:@"iconchatfriends.png"];
        [self.contentView addSubview:headImageView];
        
        imageurlButton=[[UIButton alloc]init];
        [self.contentView addSubview:imageurlButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

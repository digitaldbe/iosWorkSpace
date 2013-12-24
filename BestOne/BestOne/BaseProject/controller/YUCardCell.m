//
//  YUCardCell.m
//  BestOne
//
//  Created by ioschen on 13-12-12.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import "YUCardCell.h"

@implementation YUCardCell
@synthesize imageView;
@synthesize namelabel;
@synthesize timelabel;
@synthesize infolabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        imageView=[[UIImageView alloc]init];
        imageView.frame=CGRectMake(10, 10, 60, 60);
        //imageView.image=[UIImage imageNamed:@"iconchatbizfriends.png"];
        [self.contentView addSubview:imageView];
        
        namelabel=[[UILabel alloc]init];
        namelabel.frame=CGRectMake(80, 20, 180, 20);
        //namelabel.text=[recentList objectAtIndex:indexPath.row];
        //namelabel.text=@"朝廷";
        [self.contentView addSubview:namelabel];
        
        infolabel=[[UILabel alloc]init];
        infolabel.frame=CGRectMake(80, 50, 180, 20);
        //infolabel.text=@"最近一条消息内容";
        infolabel.textColor=[UIColor grayColor];
        [self.contentView addSubview:infolabel];
        
        timelabel=[[UILabel alloc]init];
        timelabel.frame=CGRectMake(210, 20, 180, 20);
        //timelabel.text=@"2013.10.23";
        [self.contentView addSubview:timelabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

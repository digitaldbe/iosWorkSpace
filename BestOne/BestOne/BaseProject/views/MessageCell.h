//
//  MessageCell.h
//  BestOne
//
//  Created by ioschen on 13-12-16.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property(nonatomic, retain) UILabel *senderAndTimeLabel;
@property(nonatomic, retain) UITextView *messageContentView;
@property(nonatomic, retain) UIImageView *bgImageView;
@property(nonatomic, retain) UIImageView *headImageView;

@end

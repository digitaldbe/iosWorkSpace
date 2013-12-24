//
//  BuddyViewController.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-3.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKChatDelegate.h"
@interface BuddyViewController : UITableViewController<KKChatDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property(nonatomic, retain) NSString *chatUser;
@end

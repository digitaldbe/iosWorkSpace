//
//  RecentChatViewController.h
//  BaseProject
//
//  Created by ioschen on 13-11-28.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
@interface RecentChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    FMDatabase *db;
    UITableView *recentTable;

    NSMutableDictionary *allrecent;
    NSString *linshiImage;
}
@property(strong,nonatomic)NSMutableArray* recentList;
@property(strong,nonatomic)NSMutableDictionary *touImageDict;

@end

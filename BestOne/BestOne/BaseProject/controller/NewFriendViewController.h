//
//  NewFriendViewController.h
//  BaseProject
//
//  Created by ioschen on 13-12-4.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFriendViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *newTable;
    NSMutableArray* newList;
}

@end

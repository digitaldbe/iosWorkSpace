//
//  SelectGroupViewController.h
//  BaseProject
//
//  Created by ioschen on 13-12-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectGroupViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *groupTable;
    
}
@property(strong,nonatomic)NSMutableArray* groupList;//groupName
@property(strong,nonatomic)NSMutableArray* descriptionArray;//description
@property(strong,nonatomic)NSMutableArray* administratorArray;//administrator

@end

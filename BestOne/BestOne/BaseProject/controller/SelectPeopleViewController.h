//
//  SelectPeopleViewController.h
//  BaseProject
//
//  Created by ioschen on 13-12-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SelectPeopleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    UITableView *peopleTable;
    UIButton *button;//选择群头像
    NSMutableArray *selectArray;
    UIScrollView *scrollView;//滑动按钮view
    UIButton* selectpeopleButton;
    //添加进群view
    UIView *okView;
    UILabel *countLabel;//okview上的进群人数
    NSMutableArray *pngArray;
    UIImageView *lineImageView;//进群头像虚线
}
@property(strong,nonatomic)NSMutableArray* friendsList;
@end
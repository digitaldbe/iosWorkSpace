//
//  YUViewController.h
//  BestOne
//
//  Created by ioschen on 13-12-10.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChUITabBarView.h"
@interface YUViewController : UIViewController<ChUITabBarViewDelegate>{
    ChUITabBarView *_tabBar;//底部tabBarView
}

@property(nonatomic,retain) NSMutableArray* tabBarItems;//底部按钮items信息

@end
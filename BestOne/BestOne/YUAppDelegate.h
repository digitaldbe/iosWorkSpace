//
//  YUAppDelegate.h
//  BestOne
//
//  Created by ioschen on 13-12-10.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPServer.h"
@class YUViewController;

@interface YUAppDelegate : UIResponder <UIApplicationDelegate>
{
    XMPPServer *xmppServer;
    
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
}
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong) XMPPRoster *xmppRoster;

@property(nonatomic,strong) NSMutableArray *allUsers;//在AppDelegate中声明并初始化全局变量
@property (nonatomic,strong) XMPPServer *xmppServer;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) YUViewController *viewController;

@end
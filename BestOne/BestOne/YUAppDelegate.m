//
//  YUAppDelegate.m
//  BestOne
//
//  Created by ioschen on 13-12-10.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import "YUAppDelegate.h"

#import "YUViewController.h"
#import "LoginViewController.h"
#import "Statics.h"
@implementation YUAppDelegate
@synthesize allUsers;
@synthesize xmppServer;

@synthesize xmppStream;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    allUsers=[[NSMutableArray alloc]init];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:USERID];
    NSString *pass = [defaults stringForKey:PASS];
    
    //如果已经登录过
    if (userId && pass) {
        YUViewController *yuview=[[YUViewController alloc]init];
        self.window.rootViewController=yuview;
        self.viewController = [[YUViewController alloc] init];
    }else{
        LoginViewController *loginCtl=[[LoginViewController alloc]init];
        self.window.rootViewController=loginCtl;
    }
    
//    self.viewController = [[YUViewController alloc] initWithNibName:@"YUViewController" bundle:nil];
//    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

//-(void)setupStream
//{
//    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc]init];
//    xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:xmppRosterStorage];
//    [xmppRoster activate:self.xmppStream];
//    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
//}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //[xmppServer disconnect];//断开连接
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    xmppServer = [XMPPServer sharedServer];
//    [xmppServer connect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    xmppServer = [XMPPServer sharedServer];
    [xmppServer connect];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

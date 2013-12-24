//
//  PlayVideoViewController.m
//  BestOne
//
//  Created by ioschen on 13-12-13.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import "PlayVideoViewController.h"

@interface PlayVideoViewController ()

@end

@implementation PlayVideoViewController
@synthesize mpController;
@synthesize url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //暂时这样，待会儿在搞
        
        // Custom initialization
        //创建一个导航栏
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 54, 320, 44)];
        
        //创建一个导航栏集合
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:nil];
        
        //创建一个左边按钮
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"退出"
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(back)];
        
        //创建一个右边按钮
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"share"
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(back)];
        //设置导航栏内容
        [navigationItem setTitle:@"播放"];
        //把导航栏集合添加入导航栏中，设置动画关闭
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        //把左右两个按钮添加入导航栏集合中
        [navigationItem setLeftBarButtonItem:leftButton];
        [navigationItem setRightBarButtonItem:rightButton];
        //把导航栏添加到视图中
        [self.view addSubview:navigationBar];
    }
    return self;
}
-(void)back
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //为了全屏播放，可以隐藏状态栏
    
    mpController=[[MPMoviePlayerViewController alloc]initWithContentURL:url];
    mpController.view.frame=CGRectMake(20, 80, 230, 300);
    //[mpController.view setTransform:CGAffineTransformMakeRotation(90.0f*(M_PI/180.0f))];
    [self.view addSubview:mpController.view];
    //播放结束回掉方法
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(callback:) name:MPMoviePlayerPlaybackDidFinishNotification object:mpController];
    
//    mpController.moviePlayer.fullscreen=YES;//全屏
//    mpController.moviePlayer.scalingMode=MPMovieScalingModeFill;
//    mpController.moviePlayer.controlStyle=MPMovieControlStyleNone;
    [mpController.moviePlayer play];
    
    
//    //属性设置
//    //1.控制器样式
//    moviePlayer.moviewControlMode = MPMovieControlModeDefault;
//    可以使用下列样式：
//    MPMovieControlModeDefault            显示播放/暂停、音量和时间控制
//    MPMovieControlModeVolumeOnly         只显示音量控制
//    MPMovieControlModeHidden             没有控制器
//    //2.屏幕宽高比例
//    moviePlayer.scallingMode = MPMovieScallingModeAspectFit;
//    你可以使用下列宽高比值：
//    MPMovieScallingModeNone            不做任何缩放
//    MPMovieScallingModeAspectFit       适应屏幕大小，保持宽高比
//    MPMovieScallingModeAspectFill      适应屏幕大小，保持宽高比，可裁剪
//    MPMovieScallingModeFill            充满屏幕，不保持宽高比
//    //3.背景色
//    背景色会在电影播放器转入转出时使用，当电影不能充满整个屏幕时，也会用来填充空白区域。默认的背景色是黑色，不过你可以使用 UIColor 对象设置backgroundColor属性，来改变背景色：
//    moviePlayer.backgroundColor = [UIColor redColor];
//    三、播放和停止电影
//    要播放电影请调用play 方法，电影播放控制器会自动将视图切换到电影播放器并开始播放：
//    [ moviePlayer play ];
//    当用户点击Done按钮，或者 stop 方法被调用都会停止
//    [ moviePlayer stop ];
//    当电影停止播放后会自动切回播放前应用程序所在的视图。
//    四、通知
//    你的程序可以配置电影播放器在何时候发送通知，包括结束加载内容、技术播放、改变宽高比等。电影播放器会将事件发送到 Cocoa 的通知中心，你可以对其进行配置，指定将这些事件转发到你的应用程序的一个对象。要接收这些通知，需要使用 NSNotificationCenter 类，为电影播放器添加一个观察者(observer):
//    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
//    [ notificationCenter addObserver:self selector:@selector(moviePlayerPreloadFinish:) name:MPMoviePlayerContentPreloadDidFinishNotification object:moviePlayer ];
//    通知会发到你指定的委托类和目标方法。通知参数让你可以知道是哪个事件触发了委托方法：
//    源码 打印 ？
//    -(void)moviePlayerPreloadDidFinish:(NSNotification*)notification{
//        //添加你的处理代码
//    }
//    你会观察到以下通知：
//    MPMoviePlayerContentPreloadDidFinishNotification
//    当电影播放器结束对内容的预加载后发出。因为内容可以在仅加载了一部分的情况下播放，所以这个通知可能在已经播放后才发出。
//    MPMoviePlayerScallingModeDidChangedNotification
//    当用户改变了电影的缩放模式后发出。用户可以点触缩放图标，在全屏播放和窗口播放之间切换。  
//    MPMoviePlayerPlaybackDidFinishNotification   
//    当电影播放完毕或者用户按下了Done按钮后发出
}
-(void)callback:(NSNotification*)notification
{
    MPMoviePlayerController *video=[notification object];//也可以直接使用mpcontroller
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:video];//通知中心注销自己
    
    [video stop];
//    [self dismissModalViewControllerAnimated:YES];
    
//    video=nil;
}
//#pragma mark 设置横向播放
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    return (toInterfaceOrientation==UIInterfaceOrientationLandscapeRight);
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

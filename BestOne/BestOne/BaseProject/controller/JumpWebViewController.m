//
//  JumpWebViewController.m
//  BestOne
//
//  Created by ioschen on 13-12-13.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import "JumpWebViewController.h"

@interface JumpWebViewController ()

@end

@implementation JumpWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //UITextView的dataDetectorTypes属性可完成类似功能
    //此属性可以设定使电话号码、网址、电子邮件和符合格式的日期等文字变为链接文字。
    //电话号码点击后拨出电话，网址点击后会用Safari打开，电子邮件会用mail打开，而符合格式的日期会弹出一个ActionSheet，有创建事件，在Calendar中显示，和拷贝三个选项。
    enum {
        UIDataDetectorTypePhoneNumber   = 1 << 0,          // Phone number detection
        UIDataDetectorTypeLink          = 1 << 1,          // URL detection
#if __IPHONE_4_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
        UIDataDetectorTypeAddress       = 1 << 2,          // Street address detection
        UIDataDetectorTypeCalendarEvent = 1 << 3,          // Event detection
#endif
        UIDataDetectorTypeNone          = 0,               // No detection at all
        UIDataDetectorTypeAll           = NSUIntegerMax    // All types
    };
    typedef NSUInteger UIDataDetectorTypes;
    
    //以上是UIKit框架中，UIDataDetectors.h文件内关于UIDataDetectorTypes的定义。由定义可以看出，我们可以使用|的关系来指定自己想要的链接化文字的方式。
    
    
    //测试代码：
    UITextView *mtextview = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    mtextview.backgroundColor = [UIColor grayColor];
    mtextview.dataDetectorTypes = UIDataDetectorTypeAll;
    mtextview.editable = NO;//必须的）
    
    mtextview.text =@"11211";
    [self.view addSubview:mtextview];
    //电话号码邮箱html ok其他暂时待定
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

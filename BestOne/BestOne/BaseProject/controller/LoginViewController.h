//
//  LoginViewController.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-2.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *userTextField;
@property (retain, nonatomic) IBOutlet UITextField *passTextField;
- (IBAction)LoginButton:(id)sender;
- (IBAction)closeButton:(id)sender;

@end

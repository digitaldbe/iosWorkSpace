//
//  PlayVideoViewController.h
//  BestOne
//
//  Created by ioschen on 13-12-13.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface PlayVideoViewController : UIViewController
{
    MPMoviePlayerViewController *mpController;
}
@property(nonatomic,retain)MPMoviePlayerViewController *mpController;
@property(nonatomic,retain)NSURL *url;

@end

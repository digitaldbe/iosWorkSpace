//
//  UIImage+wiRoundedRectImage.h
//  BestOne
//
//  Created by ioschen on 13-12-20.
//  Copyright (c) 2013年 ioschen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (wiRoundedRectImage)
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r;
@end
#import <UIKit/UIKit.h>
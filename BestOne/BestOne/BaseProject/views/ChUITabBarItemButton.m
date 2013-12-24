//
//  ChUITabBarItemButton.m
//  WeiBo
//
//  Created by ch on 13-6-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "ChUITabBarItemButton.h"
#import "ChTabBarItem.h"

@implementation ChUITabBarItemButton

#pragma mark 根据item对象的属性初始化按钮
- (id)initWithFrame:(CGRect)frame  item:(ChTabBarItem *)item
{
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenHighlighted = NO;
        //button定制
        /*以下两行的顺序不能互换，否则出文字重复的情况 */
         self.titleLabel.font=[UIFont systemFontOfSize:[UIFont smallSystemFontSize]];//字体
        [self setTitle:item.title forState:UIControlStateNormal];//标题
        
        [self setImage:[UIImage imageNamed:item.normalImage] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:item.highlightedImage] forState:UIControlStateHighlighted];//高亮
        [self setImage:[UIImage imageNamed:item.highlightedImage] forState:UIControlStateSelected];//选中时高亮
    }
    return self;
}

#pragma mark 对按钮中的标题的定制
-(CGRect)titleRectForContentRect:(CGRect)contentRect{//contentRect指的是按钮的Rect
    CGRect rect = [super titleRectForContentRect:contentRect];
    rect.origin.x = contentRect.size.width * 0.5 - rect.size.width *0.5;//文字居中
    rect.origin.y = self.imageView.frame.size.height - 4;//文字高度:图片高度加上4
    return rect;
}

#pragma mark 对按钮中的图片的定制
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGRect rect = [super imageRectForContentRect:contentRect];
    rect.origin.x = contentRect.size.width * 0.5 - rect.size.width *0.5;//图片居中
    rect.origin.y = 0;//图片置顶显示
    return rect;
}

@end

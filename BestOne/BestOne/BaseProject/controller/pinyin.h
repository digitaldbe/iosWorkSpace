//
//  pinyin.h
//  BaseProject
//
//  Created by ioschen on 13-12-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

//#ifndef BaseProject_pinyin_h
//#define BaseProject_pinyin_h
//
//
//
//#endif

/*
 * // Example
 *
 * #import "pinyin.h"
 *
 * NSString *hanyu = @"中国共产党万岁！";
 * for (int i = 0; i < [hanyu length]; i++)
 * {
 *     printf("%c", pinyinFirstLetter([hanyu characterAtIndex:i]));
 * }
 *
 */
char pinyinFirstLetter(unsigned short hanzi);
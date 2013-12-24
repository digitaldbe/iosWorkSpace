//
//  NameIndex.m
//  BaseProject
//
//  Created by ioschen on 13-12-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "NameIndex.h"
#import "pinyin.h"
@implementation NameIndex
@synthesize _firstName, _lastName;
@synthesize _sectionNum, _originIndex;

-(NSString *) getFirstName {
    if ([_firstName canBeConvertedToEncoding: NSASCIIStringEncoding]) {//如果是英文
        return _firstName;
    }
    else { //如果是非英文
        return [NSString stringWithFormat:@"%c",pinyinFirstLetter([_firstName characterAtIndex:0])];
    }
    
}
-(NSString *) getLastName {
    if ([_lastName canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        return _lastName;
    }
    else {
        return [NSString stringWithFormat:@"%c",pinyinFirstLetter([_lastName characterAtIndex:0])];
    }
    
}
@end

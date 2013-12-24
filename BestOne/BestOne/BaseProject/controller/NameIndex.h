//
//  NameIndex.h
//  BaseProject
//
//  Created by ioschen on 13-12-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NameIndex : NSObject
{
    NSString *_lastName;
    NSString *_firstName;
    NSInteger _sectionNum;
    NSInteger _originIndex;
}
@property (nonatomic, retain) NSString *_lastName;
@property (nonatomic, retain) NSString *_firstName;
@property (nonatomic) NSInteger _sectionNum;
@property (nonatomic) NSInteger _originIndex;
- (NSString *) getFirstName;
- (NSString *) getLastName;
@end

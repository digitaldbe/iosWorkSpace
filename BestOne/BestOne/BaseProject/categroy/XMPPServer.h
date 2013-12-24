//
//  XMPPServer.h
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "KKChatDelegate.h"
#import "KKMessageDelegate.h"

@protocol XMPPServerDelegate <NSObject>

-(void)setupStream;
-(void)getOnline;
-(void)getOffline;

@end

@interface XMPPServer : NSObject<XMPPServerDelegate,XMPPRosterDelegate>{
    XMPPStream *xmppStream;
    
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
	XMPPRosterCoreDataStorage *xmppRosterStorage;
    
    XMPPvCardCoreDataStorage *xmppvCardStorage;
	XMPPvCardTempModule *xmppvCardTempModule;
	XMPPvCardAvatarModule *xmppvCardAvatarModule;
    
    XMPPCapabilities *xmppCapabilities;
	XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    NSString *password;
    BOOL isOpen;
}

@property (nonatomic, retain, readonly) XMPPStream *xmppStream;
@property (nonatomic, retain, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, retain, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, retain, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, retain, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, retain, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, retain, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, retain, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property (nonatomic, retain)  id<KKChatDelegate>       chatDelegate;
@property (nonatomic, retain)  id<KKMessageDelegate>    messageDelegate;

+(XMPPServer *)sharedServer;

-(BOOL)connect;

-(void)disconnect;


@end

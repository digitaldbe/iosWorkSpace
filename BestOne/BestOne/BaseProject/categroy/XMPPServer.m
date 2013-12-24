//
//  XMPPServer.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-5.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "XMPPServer.h"
#import "XMPPPresence.h"
#import "XMPPJID.h"
#import "Statics.h"
//#import "CHAppDelegate.h"

static XMPPServer *singleton = nil;

@implementation XMPPServer

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize chatDelegate;
@synthesize messageDelegate;

#pragma mark - singleton
+(XMPPServer *)sharedServer{
    @synchronized(self){
        if (singleton == nil) {
            singleton = [[self alloc] init];
        }
    }
    return singleton;
    
}

+(id)allocWithZone:(NSZone *)zone{
    
    @synchronized(self){
        if (singleton == nil) {
            singleton = [super allocWithZone:zone];
            return singleton;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

-(id)retain{
    return singleton;
}

-(oneway void)release{
}

+(id)release{
    return nil;
}

-(id)autorelease{
    return singleton;
}

-(void)dealloc{
     [self teardownStream];
    [super dealloc];
}


#pragma mark - private
-(void)setupStream{
    // NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
	
	xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
	
	xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[xmppReconnect         activate:xmppStream];
	[xmppRoster            activate:xmppStream];
	[xmppvCardTempModule   activate:xmppStream];
	[xmppvCardAvatarModule activate:xmppStream];
	[xmppCapabilities      activate:xmppStream];
    
	// Add ourself as a delegate to anything we may be interested in
    
	[xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
	[xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
	// Optional:
	//
	// Replace me with the proper domain and port.
	// The example below is setup for a typical google talk account.
	//
	// If you don't supply a hostName, then it will be automatically resolved using the JID (below).
	// For example, if you supply a JID like 'user@quack.com/rsrc'
	// then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
	//
	// If you don't specify a hostPort, then the default (5222) will be used.
	
//    [xmppStream setHostName:@"talk.google.com"];
//    [xmppStream setHostName:@"localhost"];
//    [xmppStream setHostPort:5222];
}

- (void)teardownStream
{
	[xmppStream removeDelegate:self];
	[xmppRoster removeDelegate:self];
	
	[xmppReconnect         deactivate];
	[xmppRoster            deactivate];
	[xmppvCardTempModule   deactivate];
	[xmppvCardAvatarModule deactivate];
	[xmppCapabilities      deactivate];
	
	[xmppStream disconnect];
	
	xmppStream = nil;
	xmppReconnect = nil;
    xmppRoster = nil;
	xmppRosterStorage = nil;
	xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
	xmppvCardAvatarModule = nil;
	xmppCapabilities = nil;
	xmppCapabilitiesStorage = nil;
}

-(void)getOnline{
    //发送在线状态
    XMPPPresence *presence = [XMPPPresence presence];
    [xmppStream sendElement:presence];
}

-(void)getOffline{
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

-(BOOL)connect{
    [self setupStream];
    //从本地取得用户名，密码和服务器地址
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults stringForKey:USERID];
    NSString *pass = [defaults stringForKey:PASS];
    NSString *server = [defaults stringForKey:SERVER];
    
    server = OpenFireUrl;
    password = pass;

    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    if (userId <= 0) {
        return NO;
    }
    //设置用户：user1@chtekimacbook-pro.local格式的用户名
    [xmppStream setMyJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",userId,OpenFireHostName]]];
    //设置服务器
    [xmppStream setHostName:server];
    //连接服务器
    NSError *error = nil;
    
    //    if ( ![xmppStream connect:&error]) {
    if (![xmppStream connectWithTimeout:10 error:&error]) {//新版本的xmpp
        NSLog(@"cant connect %@", server);
        return NO;
    }
    
    return YES;
}

//断开服务器连接
-(void)disconnect{
    [self getOffline];
    [xmppStream disconnect];
}

#pragma mark - XMPPStream delegate  
//连接服务器
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    isOpen = YES;
    NSError *error = nil;
    //验证密码
    [xmppStream authenticateWithPassword:password error:&error];
}

//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    //上线
    [self getOnline];
}

/**
 * These methods are called after their respective XML elements are received on the stream.
 *
 * In the case of an IQ, the delegate method should return YES if it has or will respond to the given IQ.
 * If the IQ is of type 'get' or 'set', and no delegates respond to the IQ,
 * then xmpp stream will automatically send an error response.
 *
 * Concerning thread-safety, delegates shouldn't modify the given elements.
 * As documented in NSXML / KissXML, elements are read-access thread-safe, but write-access thread-unsafe.
 * If you have need to modify an element for any reason,
 * you should copy the element first, and then modify and use the copy.
 *
 */

/*
 
 名册

 <iq xmlns="jabber:client" type="result" to="user2@chtekimacbook-pro.local/80f94d95">
     <query xmlns="jabber:iq:roster">
         <item jid="user6" name="" ask="subscribe" subscription="from"/>
         <item jid="user3@chtekimacbook-pro.local" name="bb" subscription="both">
            <group>好友</group><group>user2的群组1</group>
         </item>
         <item jid="user7" name="" ask="subscribe" subscription="from"/>
         <item jid="user7@chtekimacbook-pro.local" name="" subscription="both">
            <group>好友</group><group>user2的群组1</group>
         </item>
         <item jid="user1" name="" ask="subscribe" subscription="from"/>
     </query>
 </iq>
 */

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    NSString *userId = [[sender myJID] user];//当前用户
//    NSLog(@"didReceiveIQ--iq is:%@",iq.XMLString);
    if ([@"result" isEqualToString:iq.type]) {
        NSXMLElement *query = iq.childElement;
        if ([@"query" isEqualToString:query.name]) {
            NSArray *items = [query children];
            for (NSXMLElement *item in items) {
                //订阅签署状态
                NSString *subscription = [item attributeStringValueForName:@"subscription"];
                
                if ([subscription isEqualToString:@"both"]) {
                    NSString *jid = [item attributeStringValueForName:@"jid"];
                    XMPPJID *xmppJID = [XMPPJID jidWithString:jid];
                    
                    //群组：
                    NSArray *groups = [item elementsForName:@"group"];
                    for (NSXMLElement *groupElement in groups) {
                        NSString *groupName = groupElement.stringValue;
                        
//                        CHAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//                        [appDelegate.allUsers addObject:jid];
//                        NSLog(@"所有用户%@",appDelegate.allUsers);
                        NSLog(@"didReceiveIQ----xmppJID:%@ , in group:%@",jid,groupName);
                    //[[XMPPServer xmppRoster] addUser:xmppJID withNickname:@""];
                    }
                }
                
                else if ([subscription isEqualToString:@"from"]){
                    
                }
                
                else if ([subscription isEqualToString:@"to"]){
                    
                }
            }
        }
    }
    return YES;
}

/*
 收到消息
 
 <message
     to='romeo@example.net'
     from='juliet@example.com/balcony'
     type='chat'
     xml:lang='en'>
     <body>Wherefore art thou, Romeo?</body>
 </message>
 
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    //-----------------------程序运行在前台，消息正常显示-------------------------------
    if ([[UIApplication sharedApplication]applicationState]==UIApplicationStateActive) {
        NSLog(@"ok");
    }else{
        NSLog(@"如果程序在后台运行，收到消息以通知类型来显示");
        UILocalNotification *localNotification=[[UILocalNotification alloc]init];
        localNotification.alertAction=@"ok";
        localNotification.alertBody=[NSString stringWithFormat:@"From: %@\n\n %@",@"test",@"this is a test message"];
        localNotification.soundName=UILocalNotificationDefaultSoundName;
        localNotification.applicationIconBadgeNumber=1;
        [[UIApplication sharedApplication]presentLocalNotificationNow:localNotification];
    }
    //------------------------------------------------------
    NSLog(@"shuchu%@",message);
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (msg !=nil) {
        [dict setObject:msg forKey:@"msg"];
        [dict setObject:from forKey:@"sender"];
        //消息接收到的时间
        [dict setObject:[Statics getCurrentTime] forKey:@"time"];
        
        //消息委托
        [messageDelegate newMessageReceived:dict];
        
        NSLog(@"收到来自%@消息：%@",from,msg);
    }
}

/*
 
 收到好友状态
<presence xmlns="jabber:client" 
    from="user3@chtekimacbook-pro.local/ch&#x7684;MacBook Pro" 
    to="user2@chtekimacbook-pro.local/7b55e6b">
    <priority>0</priority>
    <c xmlns="http://jabber.org/protocol/caps" node="http://www.apple.com/ichat/caps" ver="900" ext="ice recauth rdserver maudio audio rdclient mvideo auxvideo rdmuxing avcap avavail video"/>
     <x xmlns="http://jabber.org/protocol/tune"/>
     <x xmlns="vcard-temp:x:update">
        <photo>E10C520E5AE956E659A0DBC5C7F48E12DF9BE6EB</photo>
     </x>
 </presence>
 */
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    
    NSString *presenceType = [presence type]; //取得好友状态
    
    NSString *userId = [[sender myJID] user];//当前用户
    
    NSString *presenceFromUser = [[presence from] user];//在线用户
    NSLog(@"didReceivePresence---- presenceType:%@,用户:%@",presenceType,presenceFromUser);
    
    if (![presenceFromUser isEqualToString:userId]) {
        //对收到的用户的在线状态的判断在线状态
        
        //在线用户
        if ([presenceType isEqualToString:@"available"]) {
            NSString *buddy = [[NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName] retain];
            [chatDelegate newBuddyOnline:buddy];//用户列表委托
        }
        
        //用户下线
        else if ([presenceType isEqualToString:@"unavailable"]) {
            [chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, OpenFireHostName]];//用户列表委托
        }
        
        //这里再次加好友:如果请求的用户返回的是同意添加
        else if ([presenceType isEqualToString:@"subscribed"]) {
            XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",[presence from]]];
            [[XMPPServer xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        }
        
        //用户拒绝添加好友
        else if ([presenceType isEqualToString:@"unsubscribed"]) {
            //TODO
        }
    }
}

#pragma mark - XMPPRoster delegate
/**
 * Sent when a presence subscription request is received.
 * That is, another user has added you to their roster,
 * and is requesting permission to receive presence broadcasts that you send.
 *
 * The entire presence packet is provided for proper extensibility.
 * You can use [presence from] to get the JID of the user who sent the request.
 *
 * The methods acceptPresenceSubscriptionRequestFrom: and rejectPresenceSubscriptionRequestFrom: can
 * be used to respond to the request.
 *
 *  好友添加请求
 */
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    //好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]];
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    
    NSLog(@"didReceivePresenceSubscriptionRequest----presenceType:%@,用户：%@,presence:%@",presenceType,presenceFromUser,presence);

    
    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
    [[XMPPServer xmppRoster]  acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    
    /*
     user1向登录账号user2请求加为好友：
     
     presenceType:subscribe
     presence2:<presence xmlns="jabber:client" to="user2@chtekimacbook-pro.local" type="subscribe" from="user1@chtekimacbook-pro.local"/>  
     sender2:<XMPPRoster: 0x7c41450>
     
     登录账号user2发起user1好友请求，user5
     presenceType:subscribe
     presence2:<presence xmlns="jabber:client" type="subscribe" to="user2@chtekimacbook-pro.local" from="user1@chtekimacbook-pro.local"/>  
     sender2:<XMPPRoster: 0x14ad2fb0>
     */
}

/**
 * Sent when a Roster Push is received as specified in Section 2.1.6 of RFC 6121.
 *  
 * 添加好友、好友确认、删除好友
    
 //请求添加user6@chtekimacbook-pro.local 为好友
 <iq xmlns="jabber:client" type="set" id="880-334" to="user2@chtekimacbook-pro.local/f3e9c656">
    <query xmlns="jabber:iq:roster">
        <item jid="user6@chtekimacbook-pro.local" ask="subscribe" subscription="none"/>
    </query>
 </iq>

 //用户6确认后：
 <iq xmlns="jabber:client" type="set" id="880-334" to="user2@chtekimacbook-pro.local/662d302c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="subscribe" subscription="none"/></query></iq>
 
 //删除用户6：？？？
 <iq xmlns="jabber:client" type="set" id="592-372" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="from"/></query></iq>
  
 <iq xmlns="jabber:client" type="set" id="954-374" to="user2@chtekimacbook-pro.local/c8f2ab68"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" ask="unsubscribe" subscription="none"/></query></iq>

 <iq xmlns="jabber:client" type="set" id="965-376" to="user2@chtekimacbook-pro.local/e799ef0c"><query xmlns="jabber:iq:roster"><item jid="user6@chtekimacbook-pro.local" subscription="remove"/></query></iq>
  */
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterPush:(XMPPIQ *)iq{
    
    NSLog(@"didReceiveRosterPush:(XMPPIQ *)iq is :%@",iq.XMLString);
}

/**
 * Sent when the initial roster is received.
 *
 */
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender{
    NSLog(@"xmppRosterDidBeginPopulating");
}

/**
 * Sent when the initial roster has been populated into storage.
 *
 */
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    NSLog(@"xmppRosterDidEndPopulating");
}

/**
 * Sent when the roster recieves a roster item.
 *
 * Example:
 *
 * <item jid='romeo@example.net' name='Romeo' subscription='both'>
 *   <group>Friends</group>
 * </item>
 *
 */
- (void)xmppRoster:(XMPPRoster *)sender didRecieveRosterItem:(NSXMLElement *)item{
    
//    NSString *jid = [item attributeStringValueForName:@"jid"];
//    NSString *name = [item attributeStringValueForName:@"name"];
//    NSString *subscription = [item attributeStringValueForName:@"subscription"];
    
//    DDXMLNode *node = [item childAtIndex:0];
//    node
//    NSXMLElement *groupElement = [item elementForName:@"group"];
//    NSString *group = [groupElement attributeStringValueForName:@"group"];
    
//    NSLog(@"didRecieveRosterItem:  jid=%@,name=%@,subscription=%@,group=%@",jid,name,subscription);
    
}

@end

//
//  XMPPHelper.m
//  BaseProject
//
//  Created by Huan Cho on 13-8-6.
//  Copyright (c) 2013年 ch. All rights reserved.
//

#import "XMPPHelper.h"

@implementation XMPPHelper

/*
 获取名册
 
     <iq type="get"
     　　from="xiaoming@example.com"
     　　to="example.com"
     　　id="1234567">
     　　<query xmlns="jabber:iq:roster"/>
     <iq />
     
     type 属性，说明了该 iq 的类型为 get，与 HTTP 类似，向服务器端请求信息
     from 属性，消息来源，这里是你的 JID
     to 属性，消息目标，这里是服务器域名
     id 属性，标记该请求 ID，当服务器处理完毕请求 get 类型的 iq 后，响应的 result 类型 iq 的 ID 与 请求 iq 的 ID 相同
     <query xmlns="jabber:iq:roster"/> 子标签，说明了客户端需要查询 roster

*/
+(void)queryRoster{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    XMPPJID *myJID = [XMPPServer xmppStream].myJID;
    [iq addAttributeWithName:@"from" stringValue:myJID.description];
    [iq addAttributeWithName:@"to" stringValue:myJID.domain];
    [iq addAttributeWithName:@"id" stringValue:@""];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:queryElement];
    NSLog(@"111组装后的xml:%@",iq.stringValue);
    [[XMPPServer xmppStream] sendElement:iq];
}


//获取头像
+(UIImage *)xmppUserPhotoForJID:(XMPPJID *)jid
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.

    NSData *photoData = [[[XMPPServer sharedServer] xmppvCardAvatarModule] photoDataForJID:jid];
    return [UIImage imageWithData:photoData];
}
@end

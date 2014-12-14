//
//  NGGameNetManager.h
//  NetGame
//
//  Created by 杨朋亮 on 9/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NGGameNetProtocol <NSObject>

-(void)stopMatchmaking;
-(void)startMatchmaking;
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state;
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID;

@end


@interface NGGameNetManager : NSObject <MCBrowserViewControllerDelegate, MCAdvertiserAssistantDelegate, MCSessionDelegate>

@property (readwrite, nonatomic, strong) MCSession *session;
@property (readwrite, nonatomic, strong) MCAdvertiserAssistant *assistant;
@property (nonatomic,weak)  id<NGGameNetProtocol> delegate;
@property (nonatomic) bool isClient;

+(NGGameNetManager*)instance;
-(void)loadNet;

@end

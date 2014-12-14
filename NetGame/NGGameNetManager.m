//
//  NGGameNetManager.m
//  NetGame
//
//  Created by 杨朋亮 on 9/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "NGGameNetManager.h"



@implementation NGGameNetManager


+(NGGameNetManager*)instance {
    static NGGameNetManager *key = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!key) {
            key = [[NGGameNetManager alloc] init];
        }
    });
    return key;
}

-(void)loadNet{
    
    UIDevice *device = [UIDevice currentDevice];
    MCPeerID *peer = [[MCPeerID alloc] initWithDisplayName:device.name];
    [NGGameNetManager instance].session = [[MCSession alloc] initWithPeer:peer];
    [NGGameNetManager instance].session.delegate = self;
    [NGGameNetManager instance].assistant = [[MCAdvertiserAssistant alloc] initWithServiceType:ServiceType
                                                                                 discoveryInfo:nil
                                                                                       session:[NGGameNetManager instance].session];
    [NGGameNetManager instance].assistant.delegate = self;
    
}

#pragma mark - MCAdvertiserAssistantDelegate

- (void)advertiserAssitantWillPresentInvitation:(MCAdvertiserAssistant *)advertiserAssistant{
    self.isClient = YES;
}


// An invitation was dismissed from screen
- (void)advertiserAssistantDidDismissInvitation:(MCAdvertiserAssistant *)advertiserAssistant{
    
}

#pragma mark - MCBrowserViewControllerDelegate

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    if (self.delegate&& [self.delegate respondsToSelector:@selector(stopMatchmaking)]) {
        [self.delegate stopMatchmaking];
    }
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    if (self.delegate&& [self.delegate respondsToSelector:@selector(stopMatchmaking)]) {
        [self.delegate stopMatchmaking];
    }
}

#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if (self.delegate && [self.delegate respondsToSelector:@selector(session:peer:didChangeState:)]) {
        [self.delegate session:session peer:peerID didChangeState:state];
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    if (self.delegate && [self.delegate respondsToSelector:@selector(session:didReceiveData:fromPeer:)]) {
        [self.delegate session:session didReceiveData:data fromPeer:peerID];
    }
}

#pragma mark - MCSessionDelegate no-ops
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {}

@end

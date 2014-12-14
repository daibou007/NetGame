//
//  NGLoginViewController.m
//  NetGame
//
//  Created by 杨朋亮 on 9/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "NGLoginViewController.h"
#import "XHBGomokuGameSencesViewController.h"


@implementation NGLoginViewController

- (void)viewDidLoad {
    
     [NGGameNetManager instance].delegate = self;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
   
    [self startMatchmaking];
}



#pragma mark - MCSessionDelegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    if (state == MCSessionStateConnected) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showInfoWithStatus:@"连接成功！！！" maskType:SVProgressHUDMaskTypeBlack];
             [self stopMatchmaking];
        });
    } else if (state == MCSessionStateNotConnected) {
        [self startMatchmaking];
    }
}

- (void)startMatchmaking {
    if ([NGGameNetManager instance].session.connectedPeers.count == 0) {
        [[NGGameNetManager instance].assistant start];
        
        MCBrowserViewController *browser = [[MCBrowserViewController alloc] initWithServiceType:ServiceType
                                                                                        session:[NGGameNetManager instance].session];
        browser.delegate = [NGGameNetManager instance];
        [self presentViewController:browser animated:YES completion:nil];
    }
}

- (void)stopMatchmaking {
    [[NGGameNetManager instance].assistant stop];
    [self dismissViewControllerAnimated:YES completion:^{
        XHBGomokuGameSencesViewController *viewCtrl = [[XHBGomokuGameSencesViewController alloc] initWithNibName:@"XHBGomoGameSencesViewController" bundle:nil];
        [NGGameNetManager instance].delegate = viewCtrl;
        
        [self presentViewController:viewCtrl animated:YES completion:nil];
    }];
}


@end
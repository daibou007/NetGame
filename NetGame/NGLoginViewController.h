//
//  NGLoginViewController.h
//  NetGame
//
//  Created by 杨朋亮 on 9/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NGLoginViewController : UIViewController <NGGameNetProtocol>

@property (weak, nonatomic) IBOutlet UILabel *peerLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;


@end

//
//  NGGameStep.m
//  NetGame
//
//  Created by 杨朋亮 on 11/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "NGGameStep.h"

@implementation NGGameStep


-(id)init{
    self = [super init];
    if (self) {
        self.dataType = GAME_STATE_MOVE_STEP;
    }
    return self;
}

-(void) setProperties:(NSDictionary*)data{
    [super setProperties:data];
    self.type = data[@"tap"];
    self.tapLine = data[@"tapLine"];
    self.tapRow = data[@"tapRow"];
}

- (NSMutableDictionary*) getProperties{
    NSMutableDictionary* dic = [super getProperties];
    [dic setObject:self.type forKey:@"type"];
    [dic setObject:self.tapRow forKey:@"tapRow"];
    [dic setObject:self.tapLine forKey:@"tapLine"];
    return dic;
    
}

@end

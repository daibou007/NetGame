//
//  NGGameChoosePole.m
//  NetGame
//
//  Created by 杨朋亮 on 11/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "NGGameChoosePole.h"

@implementation NGGameChoosePole

-(id)init{
    self = [super init];
    if (self) {
        self.dataType = GAME_DATA_TYPE_CHOOSE_POLE;
    }
    return self;
}

-(void) setProperties:(NSDictionary*)data{
    [super setProperties:data];
    self.poleState = [((NSNumber*)data[@"poleState"]) longValue];
}

- (NSMutableDictionary*) getProperties{
    NSMutableDictionary* dic = [super getProperties];
    [dic setObject:[[NSNumber alloc] initWithLong:self.poleState] forKey:@"poleState"];
    return dic;
    
}

@end

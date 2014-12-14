//
//  NGGameReStart.m
//  NetGame
//
//  Created by 杨朋亮 on 14/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "NGGameReStart.h"

@implementation NGGameReStart
-(id)init{
    self = [super init];
    if (self) {
        self.dataType = GAME_DATA_TYPE_RESTART;
    }
    return self;
}

-(void) setProperties:(NSDictionary*)data{
    [super setProperties:data];
    self.choice = [((NSNumber*)data[@"choice"]) longValue];
}

- (NSMutableDictionary*) getProperties{
    NSMutableDictionary* dic = [super getProperties];
    [dic setValue:[[NSNumber alloc] initWithLong:self.choice] forKeyPath:@"choice"];
    return dic;
    
}
@end

//
//  NGGameOver.m
//  NetGame
//
//  Created by 杨朋亮 on 14/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "NGGameOver.h"

@implementation NGGameOver
-(id)init{
    self = [super init];
    if (self) {
        self.dataType = GAME_DATA_TYPE_GAME_OVER;
    }
    return self;
}

-(void) setProperties:(NSDictionary*)data{
    [super setProperties:data];
    self.successId = data[@"sucessId"];
    self.isSucess = [((NSNumber*)data[@"isSucess"]) boolValue];
}

- (NSMutableDictionary*) getProperties{
    NSMutableDictionary* dic = [super getProperties];
    [dic setValue:self.successId forKeyPath:@"successId"];
    [dic setValue:[[NSNumber alloc] initWithBool:self.isSucess] forKeyPath:@"isSucess"];
    return dic;
    
}
@end

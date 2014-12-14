//
//  GameData.m
//  NetGame
//
//  Created by 杨朋亮 on 10/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "GameData.h"

@implementation GameData



-(NSData*) toNSData{
    
    NSError* error;
    
    NSDictionary *dic = [self getProperties];
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    return jsonData;
}

-(void) fromNSData:(NSData*)nsdata{
    
    NSError* error;
    NSDictionary* data = [NSJSONSerialization
                          JSONObjectWithData:nsdata
                                     options:kNilOptions
                                       error:&error];
    self.netData = data;
    [self setProperties:data];
}


- (void) setProperties:(NSDictionary*)data{
    self.dataType = [((NSNumber*)data[@"dataType"]) longValue];
}


- (NSMutableDictionary*) getProperties{
     NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:[[NSNumber alloc] initWithInteger:self.dataType] forKey:@"dataType"];
    return dic;
}

@end

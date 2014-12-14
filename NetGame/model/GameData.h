//
//  GameData.h
//  NetGame
//
//  Created by 杨朋亮 on 10/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject


@property (nonatomic) GAME_DATA_TYPE dataType;
@property (nonatomic,strong)NSDictionary *netData;


-(NSData*) toNSData;
-(void) fromNSData:(NSData*)json;

/**
 *  赋值属性
 *
 *  @param data  json data
 */
-(void) setProperties:(NSDictionary*)data;
/**
 *  打包属性
 *
 *  @return NSDictionary
 */
- (NSMutableDictionary*) getProperties;

@end

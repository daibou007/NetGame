//
//  NGGameStep.h
//  NetGame
//
//  Created by 杨朋亮 on 11/12/14.
//  Copyright (c) 2014年 daozhu. All rights reserved.
//

#import "GameData.h"

@interface NGGameStep : GameData

@property (nonatomic,strong)NSNumber *type;
@property (nonatomic,strong)NSNumber *tapRow;
@property (nonatomic,strong)NSNumber *tapLine;

-(void) setProperties:(NSDictionary*)data;
- (NSMutableDictionary*) getProperties;

@end

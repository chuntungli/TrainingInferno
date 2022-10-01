//
//  User.h
//  Reflex
//
//  Created by Dan on 13年6月4日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameCenterManager.h"

@interface User : NSObject <GameCenterManagerDelegate>

+ (User *)SharedUser;
- (NSArray *)planeArray;
- (NSString *)selectedPlane;

@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, assign) float anchorPoint;
@property (nonatomic, assign) int selectedPlaneIndex;
@property (nonatomic, assign) double playTime;
@property (nonatomic, assign) double bestScore;

@end

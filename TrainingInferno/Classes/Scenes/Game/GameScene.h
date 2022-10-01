//
//  GameScene.h
//  Reflex
//
//  Created by Dan on 13年5月26日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import "CCScene.h"

@class Plane, BackgroundLayer, GameLayer, GameUILayer;

typedef enum {
    GameStateStart,
    GameStatePause,
    GameStateOver,
} GameState;

typedef enum {
    GameModeNormal,
    GameModeTrace,
    GameModeHighSpeed,
    GameModeLowSpeed,
} GameMode;

@interface GameScene : CCScene

@property (nonatomic, retain) Plane *plane;

@property (nonatomic, readonly) BackgroundLayer *backgroundLayer;
@property (nonatomic, readonly) GameLayer *gameLayer;
@property (nonatomic, readonly) GameUILayer *gameUILayer;

@property (nonatomic, assign) double playTime;
@property (nonatomic, assign) double greatRate;
@property (nonatomic, assign) int maxFireBall;

@property (nonatomic, assign) int normalBall;
@property (nonatomic, assign) int tracingBall;
@property (nonatomic, assign) int highSpeedBall;
@property (nonatomic, assign) int lowSpeedBall;

@property (nonatomic, assign) GameMode gameMode;

@property (nonatomic, readonly) GameState gameState;


+ (GameScene *)sharedScene;

- (void)gameStart;
- (void)gamePause;
- (void)gameContinue;
- (void)gameOver;

- (void)closeRangerUpdated:(int)closeRanger;

@end

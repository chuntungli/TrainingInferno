//
//  GameUILayer.h
//  Reflex
//
//  Created by Dan on 13年5月26日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import "CCLayer.h"

#import "GameScene.h"

#import "cocos2d.h"

@interface GameUILayer : CCLayer

@property (nonatomic, assign) GameScene *gameScene;

- (void)gameStart;
- (void)gamePause;
- (void)gameContinue;
- (void)gameOver;

- (void)gameModeDidChange:(GameMode)gameMode;
- (void)closeRangerUpdated:(int)closeRanger;

@end

//
//  GameLayer.h
//  Reflex
//
//  Created by Dan on 13年4月19日.
//  Copyright 2013年 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "GameScene.h"
#import "Plane.h"

@interface GameLayer : CCLayer {
    
}

@property (nonatomic, retain) Plane *plane;
@property (nonatomic, assign) GameScene *gameScene;

- (void)gameStart;
- (void)gamePause;
- (void)gameContinue;
- (void)gameOver;

@end

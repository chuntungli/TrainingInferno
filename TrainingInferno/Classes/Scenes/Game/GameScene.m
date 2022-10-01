//
//  GameScene.m
//  Reflex
//
//  Created by Dan on 13年5月26日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import "GameScene.h"

#import "User.h"

#import "Plane.h"
#import "BackgroundLayer.h"
#import "GameLayer.h"
#import "GameUILayer.h"

#define BackgroundLayerTag @"BackgroundLayerTag"
#define GameLayerTag @"GameLayerTag"
#define GameUILayerTag @"GameUILayerTag"

#define kDefaultMaxFireBall 30

@implementation GameScene {
    CGSize _screenSize;
    
    BackgroundLayer  *_backgroundLayer;
    GameLayer *_gameLayer;
    GameUILayer *_gameUILayer;
    
}

@synthesize plane = _plane;
@synthesize gameState = _gameState;
@synthesize playTime = _playTime, greatRate = _greatRate, maxFireBall = _maxFireBall;
@synthesize normalBall = _normalBall, tracingBall = _tracingBall, highSpeedBall = _highSpeedBall, lowSpeedBall = _lowSpeedBall;

static GameScene *_sharedGameScene;

+ (GameScene *)sharedScene {
    NSAssert(_sharedGameScene != nil, @"GameScene not available!");
    return _sharedGameScene;
}

- (id)init {
    if (self = [super init]) {
//        [[GAI sharedInstance].defaultTracker sendView: @"Game"];
        
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1];
        
        _sharedGameScene = self;
        
        _maxFireBall = kDefaultMaxFireBall;
        
        _screenSize = [[CCDirector sharedDirector] winSize];
        
        NSString *currentPlaneName = [[User SharedUser] selectedPlane];
        
        // Load frame cache
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: [NSString stringWithFormat: @"%@.plist", currentPlaneName]];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"explosion.plist"];
        
        _backgroundLayer = [[BackgroundLayer node] retain];
        [self addChild: _backgroundLayer z:0 tag:BackgroundLayerTag];
        
        _gameLayer = [[GameLayer node] retain];
        _gameLayer.gameScene = self;
        [self addChild: _gameLayer z:1 tag:GameLayerTag];
        
        _plane = [[Plane alloc] initWithName:currentPlaneName parent: _gameLayer];
        [_gameLayer setPlane: _plane];
        
        _gameUILayer = [[GameUILayer node] retain];
        _gameUILayer.gameScene = self;
        [self addChild: _gameUILayer z:2 tag:GameUILayerTag];
    }
    return self;
}

- (void)dealloc {
    [_backgroundLayer removeFromParent], [_backgroundLayer release], _backgroundLayer = nil;
    [_gameLayer removeFromParent], [_gameLayer release], _gameLayer = nil;
    [_plane release], _plane = nil;
    [_gameUILayer removeFromParent], [_gameUILayer release], _gameUILayer = nil;
    
    _sharedGameScene = nil;
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    [super dealloc];
}

- (void)setGameMode:(GameMode)gameMode {
    _gameMode = gameMode;
    [_gameUILayer gameModeDidChange: _gameMode];
}

- (void)onEnter {
    [super onEnter];
    [self gameStart];
}

- (void)setPlane:(Plane *)plane {
    [_plane release], _plane = nil;
    
    _plane = [plane retain];
    [_gameLayer setPlane: _plane];
}

- (void)gameStart {
    _gameState = GameStateStart;
    _gameMode = GameModeNormal;
    
    _playTime = _greatRate = _normalBall = _tracingBall = _highSpeedBall = _lowSpeedBall = 0;
    _maxFireBall = kDefaultMaxFireBall;
    
    [_backgroundLayer start];
    [_gameLayer gameStart];
    [_gameUILayer gameStart];
    
//    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"game_flow" withAction:@"game_start" withLabel:nil withValue:nil];
}

- (void)gamePause {
    _gameState = GameStatePause;
    
    [self pauseSchedulerAndActions];
    [_backgroundLayer stop];
    [_gameLayer gamePause];
    [_gameUILayer gamePause];
}

- (void)gameContinue {
    _gameState = GameStateStart;
    
    [self resumeSchedulerAndActions];
    [_backgroundLayer start];
    [_gameLayer gameContinue];
    [_gameUILayer gameContinue];
}

- (void)gameOver {
//    [[GAI sharedInstance].defaultTracker send:@"game_log" params:[NSDictionary dictionaryWithObject:[NSNumber numberWithDouble: _playTime] forKey: @"play_time"]];
//    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"game_flow" withAction:@"game_over" withLabel:nil withValue:nil];
    
    _gameState = GameStateOver;
    
    [self unschedule:@selector(levelUp)];
    
    [_backgroundLayer stop];
    [_gameLayer gameOver];
    [_gameUILayer gameOver];

    [[User SharedUser] setPlayTime: _playTime];
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 0.3];
    [[SimpleAudioEngine sharedEngine] playEffect: @"death.wav"];
}

- (void)closeRangerUpdated:(int)closeRanger {
    [_gameUILayer closeRangerUpdated:closeRanger];
    
    [[SimpleAudioEngine sharedEngine] playEffect: @"dodge.mp3"];
}

@end

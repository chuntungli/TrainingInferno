//
//  GameUILayer.m
//  Reflex
//
//  Created by Dan on 13年5月26日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import "GameUILayer.h"

#import "GameScene.h"

#import "ScoreLayer.h"

@implementation GameUILayer {
    CGSize _screenSize;
    
    CCLabelTTF *_greatLabel;
    CCLabelTTF *_gameModeLabel;
    CCLabelTTF *_pauseLabel;
}

- (id)init {
    if (self = [super init]) {
        _screenSize = [[CCDirector sharedDirector] winSize];
        
        _greatLabel = [[CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12] retain];
        _greatLabel.anchorPoint = ccp(0, 1);
        _greatLabel.position = ccp(5, _screenSize.height - 5);
        [self addChild:_greatLabel];
        
        _pauseLabel = [[CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize: 30] retain];
        _pauseLabel.position = ccp(_screenSize.width/2, _screenSize.height/2);
        [self addChild: _pauseLabel];
        
        _gameModeLabel = [[CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:16] retain];
        _gameModeLabel.position = ccp(_screenSize.width - 50, _screenSize.height - 20);
        [self addChild: _gameModeLabel];
        
        [self setTouchEnabled: YES];
    }
    return self;
}

- (void)dealloc {
    [_greatLabel removeFromParent], [_greatLabel release], _greatLabel = nil;
    [_gameModeLabel removeFromParent], [_gameModeLabel release], _gameModeLabel = nil;
    [_pauseLabel removeFromParent], [_pauseLabel release], _pauseLabel = nil;
    
    [super dealloc];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    switch ([GameScene sharedScene].gameState) {
        case GameStateStart:
            [[GameScene sharedScene] gamePause];
            break;
        case GameStateOver:
            [[CCDirector sharedDirector] replaceScene:[ScoreLayer scene]];
            break;
        case GameStatePause:
            [[GameScene sharedScene] gameContinue];
            break;
    }
}

- (void)gameStart {
    _pauseLabel.string = @"";
}

- (void)gamePause {
    _pauseLabel.string = @"暫停";
}

- (void)gameContinue {
    _pauseLabel.string = @"";
}

- (void)gameOver {
    _pauseLabel.string = @"";
    
    CCLabelTTF *gameOverLabel, *timeLabel, *maxFireBallLabel, *dodgeRateLabel;
    
    gameOverLabel = [CCLabelTTF labelWithString:@"你已經死了" fontName:@"Arial" fontSize:60];
    gameOverLabel.position = ccp(_screenSize.width/2, _screenSize.height - 80);
    [self addChild: gameOverLabel];
    
    /*
    timeLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"生存時間: %.2f秒", [_gameScene playTime]] fontName:@"Arial" fontSize:20];
    timeLabel.position = ccp(_screenSize.width/2, _screenSize.height/2 - 10);
    [self addChild: timeLabel];
    
    maxFireBallLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"發數: %d發", [_gameScene maxFireBall]] fontName:@"Arial" fontSize:20];
    maxFireBallLabel.position = ccp(_screenSize.width/2, _screenSize.height/2 - 50);
    [self addChild: maxFireBallLabel];
    
    dodgeRateLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"絕妙度: %.2f%%", [_gameScene greatRate]] fontName:@"Arial" fontSize:20];
    dodgeRateLabel.position = ccp(_screenSize.width/2, _screenSize.height/2 - 90);
    [self addChild: dodgeRateLabel];
    */
    
    NSString *scoreString = [NSString stringWithFormat:@"生存時間: %.2f秒\n發數: %d發\n絕妙度: %.2f%%", _gameScene.playTime, _gameScene.maxFireBall, _gameScene.greatRate];
    CCLabelTTF *scoreLabel;
    scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"Arial" fontSize:20];
    scoreLabel.anchorPoint = ccp(0.5, 1);
    scoreLabel.position = ccp(_screenSize.width/2, _screenSize.height /2 + 30);
    [self addChild: scoreLabel];
    
    NSMutableString *ballString = [[NSMutableString alloc] init];
    [ballString appendFormat: @"普通彈: %d發\n", _gameScene.normalBall];
    if (_gameScene.tracingBall > 0)
        [ballString appendFormat: @"追蹤彈: %d發\n", _gameScene.tracingBall];
    if (_gameScene.highSpeedBall > 0)
        [ballString appendFormat: @"高速彈: %d發\n", _gameScene.highSpeedBall];
    if (_gameScene.lowSpeedBall > 0)
        [ballString appendFormat: @"低速彈: %d發\n", _gameScene.lowSpeedBall];
    CCLabelTTF *ballLabel = [CCLabelTTF labelWithString:ballString fontName:@"Arial" fontSize:12 dimensions:CGSizeZero hAlignment:UITextAlignmentLeft lineBreakMode:UILineBreakModeWordWrap];
    ballLabel.anchorPoint = ccp(0.5, 1);
    ballLabel.position = ccp(_screenSize.width/2, _screenSize.height /2 - 60);
    [self addChild: ballLabel];
}

- (void)gameModeDidChange:(GameMode)gameMode {
    switch (gameMode) {
        case GameModeTrace:
            _gameModeLabel.string = @"追踪彈投下";
            break;
        case GameModeHighSpeed:
            _gameModeLabel.string = @"高速彈投下";
            break;
        case GameModeLowSpeed:
            _gameModeLabel.string = @"低速彈投下";
            break;
        default:
            _gameModeLabel.string = @"";
            break;
    }
}

- (void)closeRangerUpdated:(int)closeRanger {
    if (closeRanger >= 5) {
        _greatLabel.string = @"超絕妙!!!!";
        _gameScene.greatRate += 3;
    } else if (closeRanger >= 4) {
        _greatLabel.string = @"絕妙!!";
        _gameScene.greatRate += 1;
    } else {
        _greatLabel.string = @"妙";
        _gameScene.greatRate += 0.25;
    }
    
    [self unschedule:@selector(_dismissGreatLabel)];
    [self scheduleOnce:@selector(_dismissGreatLabel) delay:1.2];
}

- (void)_dismissGreatLabel {
    _greatLabel.string = @"";
}

@end

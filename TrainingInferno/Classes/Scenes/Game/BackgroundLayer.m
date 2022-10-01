//
//  Background.m
//  Reflex
//
//  Created by Dan on 13年5月24日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import "BackgroundLayer.h"

#import "cocos2d.h"

@implementation BackgroundLayer {
    CCSprite *_backgroundLayerSlow_1, *_backgroundLayerSlow_2;
    CCSprite *_backgroundLayerNormal_1, *_backgroundLayerNormal_2;
    CCSprite *_backgroundLayerFast_1, *_backgroundLayerFast_2;
    
    CGSize _screenSize;
}

- (id)init {
    if (self = [super init]) {
        _screenSize = [[CCDirector sharedDirector] winSize];
        
        float centerX = _screenSize.width / 2;
        _backgroundLayerSlow_1 = [CCSprite spriteWithFile:@"background_slow.png"];
        _backgroundLayerSlow_1.position = ccp(centerX, _screenSize.height * 0.5);
        [self addChild: _backgroundLayerSlow_1];
        _backgroundLayerSlow_2 = [CCSprite spriteWithFile:@"background_slow.png"];
        _backgroundLayerSlow_2.position = ccp(centerX, _screenSize.height * 1.5);
        [self addChild: _backgroundLayerSlow_2];
        
        _backgroundLayerNormal_1 = [CCSprite spriteWithFile:@"background_normal.png"];
        _backgroundLayerNormal_1.position = ccp(centerX, _screenSize.height * 0.5);
        [self addChild: _backgroundLayerNormal_1];
        _backgroundLayerNormal_2 = [CCSprite spriteWithFile:@"background_normal.png"];
        _backgroundLayerNormal_2.position = ccp(centerX, _screenSize.height * 1.5);
        [self addChild: _backgroundLayerNormal_2];
        
        _backgroundLayerFast_1 = [CCSprite spriteWithFile:@"background_fast.png"];
        _backgroundLayerFast_1.position = ccp(centerX, _screenSize.height * 0.5);
        [self addChild: _backgroundLayerFast_1];
        _backgroundLayerFast_2 = [CCSprite spriteWithFile:@"background_fast.png"];
        _backgroundLayerFast_2.position = ccp(centerX, _screenSize.height * 1.5);
        [self addChild: _backgroundLayerFast_2];
    }
    return self;
}

- (void)start {
    [self schedule:@selector(_updateSlowBackground) interval: 0.1];
    [self schedule:@selector(_updateNormalBackground) interval: 0.5];
    [self schedule:@selector(_updateFastBackground) interval: 0.025];
}

- (void)stop {
    [self unschedule:@selector(_updateSlowBackground)];
    [self unschedule:@selector(_updateNormalBackground)];
    [self unschedule:@selector(_updateFastBackground)];
}

- (void)_updateBackgroundSprite:(CCSprite *)backgroundSprite {
    float centerX = _screenSize.width / 2;
    backgroundSprite.position = ccp(centerX, backgroundSprite.position.y - 1);
    if (backgroundSprite.position.y < -0.5 * _screenSize.height)
        backgroundSprite.position = ccp(centerX, 1.5 * _screenSize.height);
}

- (void)_updateSlowBackground {
    [self _updateBackgroundSprite:_backgroundLayerSlow_1];
    [self _updateBackgroundSprite:_backgroundLayerSlow_2];
}

- (void)_updateNormalBackground {
    [self _updateBackgroundSprite:_backgroundLayerNormal_1];
    [self _updateBackgroundSprite:_backgroundLayerNormal_2];
}

- (void)_updateFastBackground {
    [self _updateBackgroundSprite:_backgroundLayerFast_1];
    [self _updateBackgroundSprite:_backgroundLayerFast_2];
}

@end

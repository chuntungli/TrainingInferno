//
//  Plane.m
//  Reflex
//
//  Created by Dan on 13年5月24日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import "Plane.h"

#import "User.h"

typedef enum {
    PlaneStateNone,
    PlaneStateNormal,
    PlaneStateLeft,
    PlaneStateRight,
    PlaneStateDestroied,
} PlaneState;

@implementation Plane {
    float _maxVelocity;
    float _maxBackwardVelocity;
    float _planeAnimDelay;
    float _sensitivity;
    float _deceleration;
    
    NSString *_planeName;
    
    PlaneState _planeState;
}

@synthesize space = _space;
@synthesize sprite = _sprite;
@synthesize planeVelocity = _planeVelocity;

- (id)init {
    if (self = [super init]) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        _space = CGRectMake(0, 0, screenSize.width, screenSize.height);
        
        _planeState = PlaneStateNone;
        
        _maxVelocity = _maxBackwardVelocity = _planeAnimDelay = _sensitivity = 0;
    }
    return self;
}

- (id)initWithName:(NSString *)name parent:(CCNode *)parent {
    if (self = [self init]) {
        _planeName = [name retain];
        _sprite = [[CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat:@"%@_1.png", _planeName]] retain];
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@Properties", _planeName] ofType:@"plist"];
        NSDictionary *planeInfo = [[NSDictionary alloc] initWithContentsOfFile: plistPath];
        _maxVelocity = [[planeInfo objectForKey: @"MaxVelocity"] floatValue];
        _maxBackwardVelocity = [[planeInfo objectForKey: @"MaxBackwardVelocity"] floatValue];
        _planeAnimDelay = [[planeInfo objectForKey: @"PlaneAnimDelay"] floatValue];
        _sensitivity = [[planeInfo objectForKey: @"Sensitivity"] floatValue];
        _deceleration = [[planeInfo objectForKey: @"Deceleration"] floatValue];
        
        [parent addChild: _sprite];
        [self _normal];
    }
    return self;
}

- (void)dealloc {
    [_sprite removeFromParent], [_sprite release], _sprite = nil;
    
    [super dealloc];
}

- (void)setSpace:(CGRect)space {
    _space = space;
    _planeState = PlaneStateNone;
    [self restore];
}

- (void)didAccelerate:(UIAcceleration *)acceleration {
    double x = acceleration.x;
    double z = acceleration.z;
    
    double tempSum = fabs(x) + fabs(z);
    x /= tempSum;
    z /= tempSum;
    
    double anchorPoint = [User SharedUser].anchorPoint;
    double delta;
    if (z < 0) {
        if (x + anchorPoint >= 1) {
            delta = 1 - ((x + anchorPoint) - 1);
        } else {
            delta = x + anchorPoint;
        }
    } else {
        if (x - anchorPoint <= -1) {
            delta = -1.0f - (1.0f + x) + anchorPoint;
        } else {
            delta = x - anchorPoint;
        }
    }
    
    _planeVelocity.x = _planeVelocity.x * _deceleration + (-acceleration.y) * _sensitivity;
    _planeVelocity.y = _planeVelocity.y * _deceleration + delta * _sensitivity;
    
    _planeVelocity.x = MAX(MIN(_planeVelocity.x, _maxVelocity), -_maxVelocity);
    _planeVelocity.y = MAX(MIN(_planeVelocity.y, _maxVelocity), -_maxBackwardVelocity);
    
    double maxSpeed = _maxVelocity * 1.41421356;
    tempSum = fabs(_planeVelocity.x) + fabs(_planeVelocity.y);
    if (tempSum > maxSpeed) {
        _planeVelocity.x = (_planeVelocity.x / tempSum) * maxSpeed;
        _planeVelocity.y = (_planeVelocity.y / tempSum) * maxSpeed;
    }
}

- (void)update:(ccTime)delta {
    CGPoint pos = _sprite.position;
    
    pos.x += _planeVelocity.x;
    pos.y += _planeVelocity.y;
    
    CGSize imageHalved = CGSizeMake(_sprite.boundingBox.size.width * 0.5f, _sprite.boundingBox.size.height * 0.5f);
    
    float leftBorderLimit = CGRectGetMinX(_space) + imageHalved.width;
    float rightBorderLimit = CGRectGetMaxX(_space) - imageHalved.width;
    float topBorderLimit = CGRectGetMaxY(_space) - imageHalved.height;
    float bottomBorderLimit = CGRectGetMinY(_space) + imageHalved.height;
    
    if (pos.x < leftBorderLimit || pos.x > rightBorderLimit) {
        _planeVelocity.x = 0;
    }
    pos.x = MAX(MIN(pos.x, rightBorderLimit), leftBorderLimit);
    
    if (pos.y < bottomBorderLimit || pos.y > topBorderLimit) {
        _planeVelocity.y = 0;
    }
    pos.y = MAX(MIN(pos.y, topBorderLimit), bottomBorderLimit);
    
    _sprite.position = pos;
    
    if (_planeVelocity.x < -0.5) {
        [self _turnLeft];
    } else if (_planeVelocity.x > 0.5) {
        [self _turnRight];
    } else {
        [self _normal];
    }
}

- (void)_normal {
    if (_planeState == PlaneStateNormal)
        return;
    
    _planeState = PlaneStateNormal;
    
    [_sprite stopAllActions];
    
    NSMutableArray *frames = [NSMutableArray array];
    for (int i=1; i<=2; i++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_%d.png", _planeName, i]];
        [frames addObject:frame];
    }
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:_planeAnimDelay];
    [_sprite runAction: [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: animation]]];
}

- (void)_turnLeft {
    if (_planeState == PlaneStateLeft)
        return;
    
    _planeState = PlaneStateLeft;
    
    [_sprite stopAllActions];
    
    NSMutableArray *frames = [NSMutableArray array];
    for (int i=3; i<=4; i++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_%d.png", _planeName, i]];
        [frames addObject:frame];
    }
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:_planeAnimDelay];
    [_sprite runAction: [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: animation]]];
}

- (void)_turnRight {
    if (_planeState == PlaneStateRight)
        return;
    
    _planeState = PlaneStateRight;
    
    [_sprite stopAllActions];
    
    NSMutableArray *frames = [NSMutableArray array];
    for (int i=5; i<=6; i++) {
        CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_%d.png", _planeName, i]];
        [frames addObject:frame];
    }
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:frames delay:_planeAnimDelay];
    [_sprite runAction: [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation: animation]]];
}

- (void)restore {
    [_sprite stopAllActions];
    
    _sprite.position = ccp(CGRectGetMidX(_space), CGRectGetMidY(_space));
    [self _normal];
}

- (void)destroied {
    if (_planeState == PlaneStateDestroied)
        return;
    _planeState = PlaneStateDestroied;
    
    [_sprite stopAllActions];
    
    NSMutableArray *explosionFrames = [NSMutableArray array];
    for (int i=1; i<=9; i++) {
        [explosionFrames addObject: [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"explosion%d.png", i]]];
    }
    CCAnimation *explosionAnim = [CCAnimation animationWithSpriteFrames:explosionFrames delay:0.04f];
    CCAnimate *animate = [[CCAnimate alloc] initWithAnimation: explosionAnim];
    [_sprite runAction: animate];
    [animate release];
}

@end

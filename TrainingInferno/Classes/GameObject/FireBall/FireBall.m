//
//  FireBall.m
//  Reflex
//
//  Created by Dan on 13年4月28日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import "FireBall.h"

#define kDefaultSpeed 1.5
#define kDefaultHighSpeed 2
#define kDefaultLowSpeed 1
#define kDefaultVariance 25

#define kMaxTurningDelta 0.3

@implementation FireBall {
    FireBallType _fireBallType;
    
    CGSize _screenSize;
    
    BOOL _displayed;
}

@synthesize shouldDestroy = _shouldDestroy;
@synthesize sprite = _sprite;

@synthesize speed = _speed;
@synthesize variance = _variance;
@synthesize direction = _direction;

- (id)init {
    if (self = [super init]) {
        _screenSize = [[CCDirector sharedDirector] winSize];
        _shouldDestroy = NO;
        
        _fireBallType = FireBallTypeNormal;
        _speed = kDefaultSpeed;
        _variance = kDefaultVariance;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        int randomX, randomY;
        int startFrom = rand() % 6;
        switch (startFrom) {
            case 0: // Left
                randomX = -5;
                randomY = (rand() % ((int)screenSize.height + 10)) - 5;
                break;
            case 1: // Top
            case 2:
                randomX = (rand() % ((int)screenSize.width + 10)) - 5;
                randomY = screenSize.height + 5;
                break;
            case 3: // Right
                randomX = screenSize.width + 5;
                randomY = (rand() % ((int)screenSize.height + 10)) - 5;
                break;
            case 4: // Bottom
            case 5:
                randomX = (rand() % ((int)screenSize.width + 10)) - 5;
                randomY = -5;
                break;
        }
        
        _sprite = [[CCSprite spriteWithFile: [NSString stringWithFormat:@"ball_%d.png", _fireBallType]] retain];
        _sprite.position = CGPointMake(randomX, randomY);
    }
    return self;
}

- (id)initWithParent:(CCNode *)parent targetPoint:(CGPoint)targetPoint fireBallType:(FireBallType)fireBallType {
    if (self = [self init]) {
        _fireBallType = fireBallType;
        
        if (fireBallType == FireBallTypeHighSpeed)
            _speed = kDefaultHighSpeed;
        else if (fireBallType == FireBallTypeLowSpeed)
            _speed = kDefaultLowSpeed;
        
        CGPoint currentPosition = _sprite.position;
        [_sprite removeFromParent], [_sprite release], _sprite = nil;
        _sprite = [[CCSprite spriteWithFile: [NSString stringWithFormat:@"ball_%d.png", _fireBallType]] retain];
        _sprite.position = currentPosition;
        [parent addChild: _sprite];
        
        // Direct to target
        double degree = [self _pointToDegree: targetPoint];
        
        if (rand()%2 == 0)
            degree += ((float)rand() / RAND_MAX) * _variance;
        else
            degree -= ((float)rand() / RAND_MAX) * _variance;
        
        double deltaX = sin(degree * M_PI / 180);
        double deltaY = cos(degree * M_PI / 180);
        
        double tempSum = fabs(deltaX) + fabs(deltaY);
        deltaX /= tempSum;
        deltaY /= tempSum;
        
        _direction = GLKVector2Make(deltaX, deltaY);
    }
    return self;
}

- (void)dealloc {
    [_sprite removeFromParent], [_sprite release], _sprite = nil;
    
    [super dealloc];
}

- (void)update:(ccTime)delta targetPoint:(CGPoint)targetPoint {
    
    if (_fireBallType == FireBallTypeTrace) {
        int degreeToTarget = [self _pointToDegree:targetPoint];
        GLKVector2 newVector = [self _degreeToVector: degreeToTarget];
        
        double allowedOffset = kMaxTurningDelta * delta;
        double offsetX = newVector.x - _direction.x;
        if (offsetX > allowedOffset) {
            offsetX = allowedOffset;
        } else if (offsetX < allowedOffset) {
            offsetX = -allowedOffset;
        }
        
        double offsetY = newVector.y - _direction.y;
        if (offsetY > allowedOffset) {
            offsetY = allowedOffset;
        } else if (offsetY < allowedOffset) {
            offsetY = -allowedOffset;
        }
        
        double newX = _direction.x + offsetX;
        double newY = _direction.y + offsetY;
        double tempTotal = fabs(newX) + fabs(newY);
        newX /= tempTotal;
        newY /= tempTotal;
        
        _direction = GLKVector2Make(newX, newY);
    }
    
    _sprite.position = CGPointMake(_sprite.position.x + (_direction.x * _speed), _sprite.position.y + (_direction.y * _speed));
    
    CGRect screenBounce = CGRectMake(0, 0, _screenSize.width, _screenSize.height);
    
    if (!_displayed && CGRectContainsPoint(screenBounce, _sprite.position)) {
        _displayed = YES;
    }
    
    if (_displayed && !CGRectContainsPoint(screenBounce , _sprite.position)) {
        _shouldDestroy = YES;
    }
}

- (int)_pointToDegree:(CGPoint)pointTo {
    CGPoint pointFrom = _sprite.position;
    double degree;
    
    if (pointTo.x == pointFrom.x) {
        degree = (pointTo.y > pointFrom.y) ? 0 : 180;
    } else if (pointTo.y == pointFrom.y) {
        degree = (pointTo.x > pointFrom.x) ? 90 : 0;
    } else {
        double slope = (pointFrom.y - pointTo.y) / (pointFrom.x - pointTo.x);
        degree = atan(slope) * 180 / M_PI;
        
        if (pointTo.x > pointFrom.x && pointTo.y < pointFrom.y) {
            degree = 90 + fabs(degree);
        } else if (pointTo.x < pointFrom.x && pointTo.y < pointFrom.y) {
            degree = 270 - degree;
        } else if (pointTo.x < pointFrom.x && pointTo.y > pointFrom.y) {
            degree = 270 + fabs(degree);
        } else if (pointTo.x > pointFrom.x && pointTo.y > pointFrom.y) {
            degree = 90 - degree;
        }
    }
    
    return degree;
}

- (GLKVector2)_degreeToVector:(int)degree {
    double deltaX = sin(degree * M_PI / 180);
    double deltaY = cos(degree * M_PI / 180);
    
    double tempSum = fabs(deltaX) + fabs(deltaY);
    deltaX /= tempSum;
    deltaY /= tempSum;
    
    return GLKVector2Make(deltaX, deltaY);
}

@end

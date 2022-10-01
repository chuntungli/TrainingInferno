//
//  GameLayer.m
//  Reflex
//
//  Created by Dan on 13年4月19日.
//  Copyright 2013年 Dan. All rights reserved.
//

#import "GameLayer.h"

#import "GameScene.h"
#import "FireBall.h"

#define kDefaultMaxChangeModeDelay 20
#define kDefaultMaxModeDuration 20
#define kDefaultMinModeDuration 8

#define kDefaultFireBallDelay 2
#define kDefaultFireBallDelayIncrement 0.5

@implementation GameLayer {
    CGSize _screenSize;
    
    NSMutableArray *_fireBallList;
    
    double _fireBallDelay;
    
    // Collision detection
    int _lastCloseRangeCount;
    CCRenderTexture *_texture;
}

@synthesize gameScene = _gameScene;
@synthesize plane = _plane;

- (id) init {
    if (self = [super init]) {
        _screenSize = [[CCDirector sharedDirector] winSize];
        
        _fireBallList = [[NSMutableArray alloc] init];
        
        _texture = [[CCRenderTexture renderTextureWithWidth:_screenSize.width height:_screenSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888] retain];
        
        [self setAccelerometerEnabled: YES];
    }
    return self;
}

- (void)dealloc {
    [_fireBallList removeAllObjects], [_fireBallList release], _fireBallList = nil;
    [_texture release], _texture = nil;
    
    [super dealloc];
}

- (void)levelUp {
    _gameScene.maxFireBall++;
    
    _fireBallDelay += kDefaultFireBallDelayIncrement;
    //[self scheduleOnce:@selector(levelUp) delay:_fireBallDelay];
}

- (void)changeMode {
    int randomMode = rand() % 3 + 1;
    _gameScene.gameMode = randomMode;
    
    int randomDuration = rand() % (kDefaultMaxModeDuration - kDefaultMinModeDuration) + kDefaultMinModeDuration;
    [self scheduleOnce:@selector(normalMode) delay:randomDuration];
}

- (void)normalMode {
    _gameScene.gameMode = GameModeNormal;
    
    [self scheduleOnce:@selector(changeMode) delay:rand() % kDefaultMaxChangeModeDelay];
}

- (void)gameStart {
    [_fireBallList removeAllObjects];
    
    _fireBallDelay = kDefaultFireBallDelay;
    
    _plane.sprite.position = ccp(_screenSize.width/2, _screenSize.height/2);
    
    [self unscheduleUpdate];
    [self scheduleUpdate];
    
    //[self scheduleOnce:@selector(levelUp) delay:_fireBallDelay];
    [self schedule:@selector(levelUp) interval:3 repeat:999 delay:0];

    [self normalMode];
}

- (void)gamePause {
    [self pauseSchedulerAndActions];
}

- (void)gameContinue {
    [self resumeSchedulerAndActions];
}

- (void)gameOver {
    [_plane destroied];
    [self unscheduleUpdate];
    [self unscheduleAllSelectors];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    [_plane didAccelerate: acceleration];
}

- (void)update:(ccTime)delta {
    _gameScene.playTime += delta;
    [self generateFireBall];
    
    [_plane update:delta];
    
    for (int i=[_fireBallList count]-1; i>= 0; i--) {
        FireBall *fireBall = [_fireBallList objectAtIndex: i];
        if (fireBall.shouldDestroy) {
            [_fireBallList removeObjectAtIndex: i];
        } else {
            [fireBall update:delta targetPoint: _plane.sprite.position];
        }
    }
    
    if ([GameScene sharedScene].gameState == GameStateStart) {
        if ([self collisionDetection]) {
            [[GameScene sharedScene] gameOver];
        }
    }
}

- (void)generateFireBall {
    int maxFireBall = [GameScene sharedScene].maxFireBall;
    
    FireBallType fireBallType;
    switch ([_gameScene gameMode]) {
        case GameModeTrace:
            fireBallType = FireBallTypeTrace;
            break;
        case GameModeHighSpeed:
            fireBallType = FireBallTypeHighSpeed;
            break;
        case GameModeLowSpeed:
            fireBallType = FireBallTypeLowSpeed;
            break;
        default:
            fireBallType = FireBallTypeNormal;
            break;
    }
    
    for (int i=0; i< (maxFireBall - _fireBallList.count); i++) {
        FireBall *fireBall = [[FireBall alloc] initWithParent:self targetPoint:_plane.sprite.position fireBallType: fireBallType];
        [_fireBallList addObject: fireBall];
        [fireBall release];
        
        switch (fireBallType) {
            case FireBallTypeTrace:
                _gameScene.tracingBall++;
                break;
            case FireBallTypeHighSpeed:
                _gameScene.highSpeedBall++;
                break;
            case FireBallTypeLowSpeed:
                _gameScene.lowSpeedBall++;
                break;
            default:
                _gameScene.normalBall++;
                break;
        }
    }
}

// Collision Detection
- (BOOL)collisionDetection {
    
    CGPoint planePos = _plane.sprite.position;
    CGRect planeRect = _plane.sprite.boundingBox;
    
    int closeRangeCount = 0;
    float threshold = ((planeRect.size.width + planeRect.size.height) / 2) + 3;
    
    for (FireBall *fireBall in _fireBallList) {
        CGRect fireBallRect = fireBall.sprite.boundingBox;
        if (CGRectIntersectsRect(planeRect, fireBallRect)) {
            if ([self isCollisionBetweenSpriteA:_plane.sprite spriteB:fireBall.sprite pixelPerfect:YES])
                return YES;
        }
        
        // Close Range Detection
        CGPoint fireBallPos = fireBall.sprite.position;
        double distance = sqrt(pow(fireBallPos.y - planePos.y, 2) + pow(fireBallPos.x - planePos.x, 2));
        if (distance <= threshold)
            closeRangeCount++;
    }
    
    if (closeRangeCount >= 3 && closeRangeCount > _lastCloseRangeCount) {
        _lastCloseRangeCount = closeRangeCount;
    }
    
    if (closeRangeCount < 3 && _lastCloseRangeCount >= 3) {
        [[GameScene sharedScene] closeRangerUpdated: _lastCloseRangeCount];
        _lastCloseRangeCount = 0;
    }
    
    return NO;
}

-(BOOL) isCollisionBetweenSpriteA:(CCSprite*)spr1 spriteB:(CCSprite*)spr2 pixelPerfect:(BOOL)pp
{
    BOOL isCollision = NO;
    CGRect intersection = CGRectIntersection([spr1 boundingBox], [spr2 boundingBox]);
    
    // Look for simple bounding box collision
    
    if (!CGRectIsEmpty(intersection))
    {
        // Subtract map offset from positions
        
        CGPoint screenMapPosition = self.position;
        screenMapPosition.x = -(screenMapPosition.x);
        screenMapPosition.y = -(screenMapPosition.y);
        
        CGPoint spr1OldPosition = spr1.position;
        CGPoint spr2OldPosition = spr2.position;
        
        spr1.position = ccp(spr1.position.x - screenMapPosition.x, spr1.position.y - screenMapPosition.y);
        spr2.position = ccp(spr2.position.x - screenMapPosition.x, spr2.position.y - screenMapPosition.y);
        
        // Update intersection to updated sprite positions
        
        intersection = CGRectIntersection([spr1 boundingBox], [spr2 boundingBox]);
        
        // If we're not checking for pixel perfect collisions, return true
        
        if (!pp) {return YES;}
        
        // Get intersection info
        
        unsigned int x = intersection.origin.x;
        unsigned int y = intersection.origin.y;
        unsigned int w = intersection.size.width;
        unsigned int h = intersection.size.height;
        
        // Create a clear sprite
        
        CCSprite *clearSprite = [[CCSprite alloc] init];
        [clearSprite setColor:(ccColor3B) {0,0,0}];
        [clearSprite setTextureRect:CGRectMake(0,0,w,h)];
        [clearSprite setAnchorPoint:ccp(0.f,0.f)];
        [clearSprite setPosition:ccp(x,y)];
        
        // Multiply x, y, width, height by CC_CONTENT_SCALE_FACTOR() to work with retina screens
        
        x *=  CC_CONTENT_SCALE_FACTOR();
        y *=  CC_CONTENT_SCALE_FACTOR();
        w *=  CC_CONTENT_SCALE_FACTOR();
        h *=  CC_CONTENT_SCALE_FACTOR();
        
        // Start of render texture operations
        
        [_texture begin];
        
        // Render clearSprite to erase intersection area
        
        [clearSprite visit];
        
        // Render both sprites: first one in RED and second one in GREEN
        
        glColorMask(1, 0, 0, 1);
        if([spr1.parent isKindOfClass:[CCSpriteBatchNode class]]) {
            CCSpriteBatchNode* spr1BatchNode = (CCSpriteBatchNode*) spr1.parent;
            [spr1BatchNode visitSprite:spr1];
        }
        else
            [spr1 visit];
        
        glColorMask(0, 1, 0, 1);
        if([spr2.parent isKindOfClass:[CCSpriteBatchNode class]]) {
            CCSpriteBatchNode* spr2BatchNode = (CCSpriteBatchNode*) spr2.parent;
            [spr2BatchNode visitSprite:spr2];
        }
        else
            [spr2 visit];
        
        // Reset color mask back to normal
        
        glColorMask(1, 1, 1, 1);
        
        // Calculate number of pixels to read
        
        unsigned int numPixels = w * h;
        
        // Get color values of intersection area
        
        ccColor4B *buffer = malloc( sizeof(ccColor4B) * numPixels );
        glReadPixels(x, y, w, h, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
        
        // End of render texture operations
        
        [_texture end];
        
        // Read buffer
        
        unsigned int step = 1;
        for(unsigned int i=0; i<numPixels; i+=step)
        {
            ccColor4B color = buffer[i];
            
            if (color.r > 0 && color.g > 0)
            {
                isCollision = YES;
                break;
            }
        }
        
        // Restore old sprite positions
        
        spr1.position = spr1OldPosition;
        spr2.position = spr2OldPosition;
        
        // Free buffer memory
        
        free(buffer);
    }
    
    return isCollision;
}

@end

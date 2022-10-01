//
//  FireBall.h
//  Reflex
//
//  Created by Dan on 13年4月28日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "cocos2d.h"

typedef enum {
    FireBallTypeNormal,
    FireBallTypeTrace,
    FireBallTypeHighSpeed,
    FireBallTypeLowSpeed,
} FireBallType;

@interface FireBall : NSObject {

}

@property (nonatomic, readonly) CCSprite *sprite;
@property (nonatomic, readonly) BOOL shouldDestroy;

@property (nonatomic, readonly) float speed;
@property (nonatomic, readonly) float variance;
@property (nonatomic, readonly) GLKVector2 direction;

- (id)initWithParent:(CCNode *)parent targetPoint:(CGPoint)targetPoint fireBallType:(FireBallType)fireBallType;

- (void)update:(ccTime)delta targetPoint:(CGPoint)targetPoint;

@end

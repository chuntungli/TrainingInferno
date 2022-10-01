//
//  Plane.h
//  Reflex
//
//  Created by Dan on 13年5月24日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "cocos2d.h"

@interface Plane : NSObject

- (id)initWithName:(NSString *)name parent:(CCNode *)parent;

- (void)didAccelerate:(UIAcceleration *)acceleration;
- (void)update:(ccTime)delta;

- (void)restore;
- (void)destroied;

@property (nonatomic, assign) CGRect space;
@property (nonatomic, readonly) CGPoint planeVelocity;
@property (nonatomic, readonly) CCSprite *sprite;

@end

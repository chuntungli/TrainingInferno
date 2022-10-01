//
//  MainLayer.m
//  Reflex
//
//  Created by Dan on 13年4月19日.
//  Copyright 2013年 Dan. All rights reserved.
//

#import "MainScene.h"
#import "MainLayer.h"
#import "BackgroundLayer.h"

@implementation MainScene

- (id)init {
    if (self = [super init]) {
//        [[GAI sharedInstance].defaultTracker sendView: @"Main"];
        
        BackgroundLayer *backgroundLayer = [BackgroundLayer node];
        [self addChild: backgroundLayer];
        [self addChild: [MainLayer node]];
        
        [backgroundLayer start];
    }
    return self;
}

@end

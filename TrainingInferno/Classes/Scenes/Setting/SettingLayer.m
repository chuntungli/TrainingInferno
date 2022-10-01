//
//  SettingLayer.m
//  Reflex
//
//  Created by Dan on 13年5月30日.
//  Copyright 2013年 Dan. All rights reserved.
//

#import "SettingLayer.h"

#import "CCControlExtension.h"

#import "MainScene.h"

#import "Plane.h"
#import "User.h"

@implementation SettingLayer {
    CGSize _screenSize;
    
    CCLabelTTF *_anchroPointLabel;
    CCControlSlider *_slider;
    
    Plane *_testingPlane;
}

+(CCScene *)scene {
	CCScene *scene = [CCScene node];
	SettingLayer *layer = [SettingLayer node];
	[scene addChild: layer];
	
	return scene;
}

- (id)init {
    if (self = [super init]) {
//        [[GAI sharedInstance].defaultTracker sendView: @"Setting"];
        
        _screenSize = [[CCDirector sharedDirector] winSize];
        
        CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
        background.position = ccp(_screenSize.width/2, _screenSize.height/2);
        [self addChild: background];
        
        CCMenuItem *homeButton = [CCMenuItemImage itemWithNormalImage:@"buttonHome.png" selectedImage:@"buttonHomeSelected.png" target:self selector:@selector(_goToMain)];
        homeButton.anchorPoint = ccp(0, 1);
        homeButton.position = ccp(0, 0);
        CCMenu *menu = [CCMenu menuWithItems:homeButton, nil];
        menu.position = ccp(0, _screenSize.height);
        [self addChild: menu];
        
        NSMutableArray *planeArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[[User SharedUser].planeArray count]; i++) {
            NSString *planeName = [[User SharedUser].planeArray objectAtIndex: i];
            
            CCMenuItem *menuItem = [CCMenuItemImage itemWithNormalImage:[NSString stringWithFormat: @"%@Preview.png", planeName] selectedImage:nil disabledImage:nil block:^(id sender) {
                [[SimpleAudioEngine sharedEngine] playEffect: @"selected.wav"];
                
                [User SharedUser].selectedPlaneIndex = i;
                [self reloadTestingPlane];
            }];
            [planeArray addObject: menuItem];
        }
        menu = [CCMenu menuWithArray: planeArray];
        menu.position = ccp(_screenSize.width/2, _screenSize.height - 50);
        [menu alignItemsHorizontally];
        [self addChild: menu];
        [planeArray removeAllObjects], [planeArray release];
        
        _slider = [[CCControlSlider sliderWithBackgroundFile:@"sliderTrack.png" progressFile:@"sliderProgress.png" thumbFile:@"sliderThumb.png"] retain];
        _slider.maximumValue = 1;
        _slider.minimumValue = 0;
        _slider.value = [User SharedUser].anchorPoint;
        [_slider addTarget:self action:@selector(valueChanged:) forControlEvents:CCControlEventValueChanged];
        _slider.position = ccp(_screenSize.width/2, _screenSize.height - 100);
        [self addChild: _slider];
        
        CCSprite *leftLabel = [CCSprite spriteWithFile:@"sliderLabelLeft.png"];
        leftLabel.position = ccp(CGRectGetMinX(_slider.boundingBox) - 20, CGRectGetMidY(_slider.boundingBox));
        [self addChild: leftLabel];
        
        CCSprite *rightLabel = [CCSprite spriteWithFile:@"sliderLabelRight.png"];
        rightLabel.position = ccp(CGRectGetMaxX(_slider.boundingBox) + 20, CGRectGetMidY(_slider.boundingBox));
        [self addChild: rightLabel];
        
        [self setAccelerometerEnabled: YES];
        [self scheduleUpdate];
        
        [self reloadTestingPlane];
    }
    return self;
}

- (void)reloadTestingPlane {
    [_testingPlane release], _testingPlane = nil;
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    NSString *selectedPlane = [User SharedUser].selectedPlane;
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: [NSString stringWithFormat:@"%@.plist", selectedPlane]];
    
    _testingPlane = [[Plane alloc] initWithName:selectedPlane parent:self];
    _testingPlane.space = CGRectMake(100, 30, _screenSize.width - 200, 130);
}

- (void)update:(ccTime)delta {
    [_testingPlane update: delta];
}

- (void)dealloc {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    [_anchroPointLabel removeFromParent], [_anchroPointLabel release], _anchroPointLabel = nil;
    [_slider removeFromParent], [_slider release], _slider = nil;
    [_testingPlane release], _testingPlane = nil;
    
    [super dealloc];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    [_testingPlane didAccelerate: acceleration];
}

- (void)valueChanged:(CCControlSlider *)sender {
    [User SharedUser].anchorPoint = sender.value;
}

- (void)_goToMain {
    [[SimpleAudioEngine sharedEngine] playEffect: @"selected.wav"];
    MainScene *mainScene = [[MainScene alloc] init];
    [[CCDirector sharedDirector] replaceScene: mainScene];
    [mainScene release];
}

@end

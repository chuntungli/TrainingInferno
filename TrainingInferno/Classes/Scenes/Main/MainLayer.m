//
//  MainLayer.m
//  Reflex
//
//  Created by Dan on 13年6月5日.
//  Copyright 2013年 Dan. All rights reserved.
//

#import "AppDelegate.h"
#import "MainLayer.h"

#import "SettingLayer.h"
#import "LeaderboardLayer.h"
#import "GameScene.h"

#import "User.h"

@implementation MainLayer

- (id)init {
    if (self = [super init]) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Game Center buttons
        CCMenuItem *gcLeaderboardItem = [CCMenuItemImage itemWithNormalImage:@"gcLeaderboardIcon.png" selectedImage:@"gcLeaderboardIcon.png" target:self selector:@selector(_goToGCLeaderboard)];
        CCMenuItem *gcAchievementItem = [CCMenuItemImage itemWithNormalImage:@"gcAchievementIcon.png" selectedImage:@"gcAchievementIcon.png" target:self selector:@selector(_goToGCAchievement)];
        gcLeaderboardItem.anchorPoint = gcAchievementItem.anchorPoint = ccp(1, 1);
        
        CCMenu *menu = [CCMenu menuWithItems: gcAchievementItem, gcLeaderboardItem, nil];
        menu.anchorPoint = ccp(1, 1);
        [menu alignItemsHorizontally];
        menu.position = ccp(size.width - 30, size.height - 10);
        [self addChild: menu];
        
        CCSprite *titleSprite = [CCSprite spriteWithFile:@"title.png"];
        titleSprite.position = ccp(size.width/2, size.height - 100);
        [self addChild: titleSprite];
        
        CCSprite *beginLabel = [CCLabelTTF labelWithString:@"點擊開始" fontName:@"Arial" fontSize:18];
        beginLabel.position = ccp(size.width/2, 70);
        [self addChild: beginLabel];
        
        CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:0.75 opacity:80];
        CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:0.75 opacity:255];
        CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction: pulseSequence];
        [beginLabel runAction: repeat];
        
        CCMenuItem *settingItem = [CCMenuItemImage itemWithNormalImage:@"settingIcon.png" selectedImage:@"settingIcon.png" target:self selector:@selector(_goToSetting)];
        
        CCMenuItem *leaderboardItem = [CCMenuItemImage itemWithNormalImage:@"leaderboardIcon.png" selectedImage:@"leaderboardIcon.png" target:self selector:@selector(_goToLeaderboard)];
        
        settingItem.anchorPoint = leaderboardItem.anchorPoint = ccp(0, 0);
        menu = [CCMenu menuWithItems:settingItem, leaderboardItem, nil];
        [menu alignItemsHorizontally];
        menu.position = ccp(25, 0);
        [self addChild: menu];
        
        CCLabelTTF *bestScoreLabel = [CCLabelTTF labelWithString: [NSString stringWithFormat:@"最佳成績: %.2f秒", [User SharedUser].bestScore] fontName:@"Arial" fontSize:14];
        bestScoreLabel.anchorPoint = ccp(1, 0);
        bestScoreLabel.position = ccp(size.width - 10, 10);
        [self addChild: bestScoreLabel];
        
        self.touchEnabled = YES;
    }
    return self;
}

- (void)_goToGCLeaderboard {
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:leaderboardViewController animated:YES];
    
    [leaderboardViewController release];
}

- (void)_goToGCAchievement {
    GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
    achivementViewController.achievementDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    
    [[app navController] presentModalViewController:achivementViewController animated:YES];
    
    [achivementViewController release];
}

- (void)_goToSetting {
    [[SimpleAudioEngine sharedEngine] playEffect: @"selected.wav"];
    [[CCDirector sharedDirector] replaceScene: [SettingLayer scene]];
}

- (void)_goToLeaderboard {
    [[SimpleAudioEngine sharedEngine] playEffect: @"selected.wav"];
    [[CCDirector sharedDirector] replaceScene: [LeaderboardLayer scene]];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    GameScene *gameScene = [[GameScene alloc] init];
    [[CCDirector sharedDirector] replaceScene: gameScene];
    [gameScene release];
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end

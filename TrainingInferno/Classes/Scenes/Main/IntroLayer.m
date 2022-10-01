//
//  IntroLayer.m
//  Reflex
//
//  Created by Dan on 13年4月19日.
//  Copyright Dan 2013年. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"

#import "MainScene.h"

#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer {
    CCLabelTTF *_warningLabel;
    CCLabelTTF *_discramerLabel;
    CCLabelTTF *_thanksLabel;
    CCSprite *_iconSprite;
    
    CCLabelTTF *_noticeLabel;
}

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(id) init
{
	if( (self=[super init])) {

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        _warningLabel = [[CCLabelTTF labelWithString:@"警告!" fontName:@"Arial" fontSize:30] retain];
        _warningLabel.color = ccc3(255, 0, 0);
        _warningLabel.position = ccp(size.width/2, size.height - 60);
        [self addChild: _warningLabel];
        
		_discramerLabel = [[CCLabelTTF labelWithString:@"若您進行遊戲時產生下列任一症狀：暈眩、視覺異常、眼睛或肌肉痙攣、意識喪失、迷惘、非自主運動或抽搐，請立即停止遊戲並諮詢醫師，確保一切正常後方可重新進行遊戲。" fontName:@"Arial" fontSize:18 dimensions:CGSizeMake(size.width - 40, 80) hAlignment:UITextAlignmentLeft] retain];
        _discramerLabel.position = ccp(size.width/2, size.height - 130);
        [self addChild: _discramerLabel];
        
        _thanksLabel = [[CCLabelTTF labelWithString:@"特別嗚謝" fontName:@"Arial" fontSize:14] retain];
        [_thanksLabel setAnchorPoint: ccp(0, 0)];
        _thanksLabel.position = ccp (200, 30);
        [self addChild: _thanksLabel];
        
        _iconSprite = [[CCSprite spriteWithFile: @"praticeIcon.png"] retain];
        _iconSprite.position = ccp (280, 40);
        [self addChild: _iconSprite];
        
        _noticeLabel = [[CCLabelTTF labelWithString:@"長時間遊戲可能導致你的智商下降，建議每小時溫習十五分鍾。" fontName:@"Arial" fontSize: 15] retain];
        _noticeLabel.position = ccp(size.width/2, 85);
        [self addChild: _noticeLabel];
	}
	
	return self;
}

- (void)dealloc {
    [_warningLabel removeFromParent], [_warningLabel release], _warningLabel = nil;
    [_discramerLabel removeFromParent], [_discramerLabel release], _discramerLabel = nil;
    [_thanksLabel removeFromParent], [_thanksLabel release], _thanksLabel = nil;
    [_iconSprite removeFromParent], [_iconSprite release], _iconSprite = nil;
    [_noticeLabel removeFromParent], [_noticeLabel release], _noticeLabel = nil;
    
    [super dealloc];
}

-(void) onEnter {
	[super onEnter];
    
    [self scheduleOnce:@selector(_changeScene) delay:2];
}

- (void)_changeScene {
    MainScene *mainScene = [[MainScene alloc] init];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene: mainScene]];
    [mainScene release];
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 0.3];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"backgroundMusic.mp3"];
}

@end

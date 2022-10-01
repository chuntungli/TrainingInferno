//
//  ScoreLayer.m
//  Reflex
//
//  Created by Dan on 13年5月26日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

//#import <FacebookSDK/FacebookSDK.h>

#import "ScoreLayer.h"

#import "MainScene.h"

#import "User.h"

static NSString * const titleArray[] = {
    @"恥", @"卡關達", @"沒丁の巨人", @"野比大雄", @"長谷川泰三",
    @"廢柴綱", @"撒旦先生", @"烏索普", @"志村新八", @"代玩達",
    @"亞古獸", @"龜仙人", @"剪刀人", @"比比鳥", @"像膠人",
    @"高登仔", @"真．絞肉十三世", @"比卡超", @"空氣人", @"笛子魔童",
    @"神樂", @"奇行種", @"洛克人", @"艾倫達", @"土方十四郎",
    @"鋼鐵加魯魯", @"達人", @"斯摩格", @"卡卡西", @"阿帕查",
    @"杜拉格斯", @"蔥星人", @"大家都唾棄的星際王", @"洛克人X", @"炎帝",
    @"筋肉人", @"ZERO", @"菲利", @"神人", @"雲雀恭彌",
    @"古拿比加", @"救世主飛雲", @"基路亞", @"小雲", @"膠膠膠膠膠膠膠佳架",
    @"超夢夢", @"黑鐵我間", @"坂田銀時", @"奧米加獸", @"火拳艾斯"
    @"斯路", @"千石伊織", @"石田雨龍", @"玄野計", @"界王神",
    @"叮噹", @"孫悟飯", @"羅羅亞·索隆", @"魔人布歐", @"黑崎一護",
    @"漩渦鳴門", @"黑鐵陣介", @"比達", @"宇智波佐助", @"蒙奇．D．路飛",
    @"孫悟空", @"拳四郎"
};

static float const timeArray[] = {
    0.8f, 1.2f, 1.8f, 2.2f, 3.5f,
    4.3f, 5.0f, 6.8f, 7.5f, 8.0f,
    9.0f, 11.0f, 12.0f, 13.0f, 14.0f,
    15.0f, 16.0f, 17.0f, 18.0f, 19.0f,
    20.0f, 21.0f, 22.0f, 25.0f, 26.0f,
    28.0f, 30.0f, 32.0f, 33.0f, 35.0f,
    36.0f, 37.0f, 39.0f, 40.0f, 42.0f,
    43.0f, 45.0f, 47.0f, 50.0f, 52.0f,
    54.0f, 56.0f, 58.0f, 60.0f, 64.0f,
    65.0f, 66.0f, 67.0f, 68.0f, 70.0f,
    72.0f, 73.0f, 75.0f, 77.0f, 80.0f,
    82.5f, 84.0f, 85.0f, 86.0f, 87.0f,
    88.0f, 90.0f, 92.0f, 94.0f, 96.0f,
    99.0f, 100.0f,
};

@implementation ScoreLayer {
    double _playTime;
    
    CCLabelTTF *_titleLabel;
    
    ADBannerView *_iAdView;
    BOOL _AdBannerLoaded;
}

+(CCScene *)scene {
	CCScene *scene = [CCScene node];
	ScoreLayer *layer = [ScoreLayer node];
	[scene addChild: layer];
	
	return scene;
}

- (id)init {
    if (self = [super init]) {
//        [[GAI sharedInstance].defaultTracker sendView: @"Score"];
        
        _AdBannerLoaded = NO;
        
        _iAdView = [[ADBannerView alloc] initWithFrame: CGRectZero];
        _iAdView.delegate = self;
        _iAdView.requiredContentSizeIdentifiers = [NSSet setWithObject: ADBannerContentSizeIdentifierLandscape];
        _iAdView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
        [_iAdView setFrame: CGRectOffset(_iAdView.frame, 0, -CGRectGetHeight(_iAdView.frame))];
        [[[CCDirector sharedDirector] view] addSubview:_iAdView];
        
        _playTime = [User SharedUser].playTime;
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        int grade = [self _getGrade: _playTime];
        [[User SharedUser].gameCenterManager submitAchievement:[NSString stringWithFormat:@"title_%d", grade] percentComplete:100];
        
        NSString *title = [self _getTitle: grade];
        int fontSize = [self _getFontSize: title];
        
        _titleLabel = [[CCLabelTTF labelWithString:title fontName:@"Arial" fontSize:fontSize] retain];
        _titleLabel.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild: _titleLabel];
        
        CCMenuItem *shareItem = [CCMenuItemImage itemWithNormalImage:@"shareButton.png" selectedImage:@"shareButtonSelected.png" target:self selector:@selector(_shareOnFB)];
        shareItem.anchorPoint = ccp(1, 0);
        shareItem.position = ccp(screenSize.width - 15, 15);
        CCMenu *menu = [CCMenu menuWithItems:shareItem, nil];
        menu.position = CGPointZero;
        [self addChild: menu];
        
        [self setTouchEnabled: YES];
    }
    return self;
}

- (void)dealloc {
    [_iAdView setDelegate: nil], [_iAdView removeFromSuperview], [_iAdView release], _iAdView = nil;
    [_titleLabel removeFromParent], [_titleLabel release], _titleLabel = nil;
    [super dealloc];
}

- (int)_getFontSize:(NSString *)string {
    if (string.length < 8)
        return 140 - (string.length * 10);
    else
        return 50;
}

- (NSString *)_getTitle:(int)grade {
    int sizeOfTitle = (sizeof(titleArray) / sizeof(id));
    if (grade < sizeOfTitle)
        return titleArray[grade];
    return titleArray[sizeOfTitle - 1];
}

- (int)_getGrade:(double)playTime {
    int sizeOfTimeArray = (sizeof(timeArray) / sizeof(float));
    for (int i=0; i<sizeOfTimeArray; i++) {
        if (playTime < timeArray[i]) {
            return i;
        }
    }
    return sizeOfTimeArray;
}

- (void)_goToMainScene {
    MainScene *mainScene = [[MainScene alloc] init];
    [[CCDirector sharedDirector] replaceScene: mainScene];
    [mainScene release];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_AdBannerLoaded) {
        UITouch* touch = [touches anyObject];
        CGPoint location = [touch locationInView: [touch view]];
        if (!CGRectContainsPoint(_iAdView.frame, location)) {
            [self _goToMainScene];
        }
    } else {
        [self _goToMainScene];
    }
}

- (void)_shareOnFB {
//    NSString *linkURL = @"http://www.itunes.com/TrainingInferno";
//    NSString *pictureURL = @"http://www4.picturepush.com/photo/a/13306557/640/13306557.png";
//    
//    FBShareDialogParams *shareParams = [[FBShareDialogParams alloc] init];
//    shareParams.link = [NSURL URLWithString: linkURL];
//    shareParams.name = @"我已經在特訓中死了！";
//    shareParams.caption = @"看我撐多久了";
//    shareParams.picture = [NSURL URLWithString: pictureURL];
//    shareParams.description = [NSString stringWithFormat: @"我在特訓Inferno中撐了%.2f耶！", _playTime];
//    
//    if ([FBDialogs canPresentShareDialogWithParams: shareParams]) {
//        [FBDialogs presentShareDialogWithParams:shareParams clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//            if (error) {
//                NSLog(@"Error : %@", error.description);
//                [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"FB_share" withAction:@"share_failed" withLabel:error.description withValue:nil];
//            } else if (results[@"completionGesture"] && [results[@"completionGesture"] isEqualToString:@"cancel"]) {
//                [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"FB_share" withAction:@"share_canceled" withLabel:nil withValue:nil];
//            } else {
//                [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"FB_share" withAction:@"share_successed" withLabel:nil withValue:nil];
//            }
//        }];
//    } else {
//        NSDictionary *params = @{
//                                 @"name" : shareParams.name,
//                                 @"caption" : shareParams.caption,
//                                 @"description" : shareParams.description,
//                                 @"picture" : pictureURL,
//                                 @"link" : linkURL
//                                 };
//        
//        [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//            if (error) {
//                NSLog(@"Error : %@", error.description);
//                [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"FB_share" withAction:@"share_failed" withLabel:error.description withValue:nil];
//            } else {
//                if (result == FBWebDialogResultDialogNotCompleted) {
//                    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"FB_share" withAction:@"share_canceled" withLabel:nil withValue:nil];
//                } else {
//                    [[GAI sharedInstance].defaultTracker sendEventWithCategory:@"FB_share" withAction:@"share_successed" withLabel:nil withValue:nil];
//                }
//            }
//        }];
//    }
}

- (void)adViewDidUpdate {
    if (_iAdView.isBannerLoaded) {
        if (!_AdBannerLoaded) {
            _AdBannerLoaded = YES;
            [UIView animateWithDuration:0.3 animations:^{
                [_iAdView setFrame: CGRectOffset(_iAdView.frame, 0, CGRectGetHeight(_iAdView.frame))];
            }];
        }
    } else {
        if (_AdBannerLoaded) {
            _AdBannerLoaded = NO;
            [UIView animateWithDuration:0.3 animations:^{
                [_iAdView setFrame: CGRectOffset(_iAdView.frame, 0, -CGRectGetHeight(_iAdView.frame))];
            }];
        }
    }
}

#pragma mark ADBannerViewDelegate
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [self adViewDidUpdate];
#ifdef DEBUG
    if (error)
        NSLog(@"Load ad failed: %@", error);
#endif
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [self adViewDidUpdate];
#ifdef DEBUG
    NSLog(@"Ad Did Load");
#endif
}

@end

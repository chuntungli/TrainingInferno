//
//  User.m
//  Reflex
//
//  Created by Dan on 13年6月4日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import "User.h"

#define kBestScoreKey @"UserBestScore"
#define kUserPlanesKey @"UserPlanes"
#define kUserNameKey @"UserName"
#define kSelectedPlaneKey @"UserSelectedPlane"
#define kAnchorPointKey @"UserAnchorPoint"

@interface User () <UIAlertViewDelegate> {
    NSMutableArray *_planeArray;
    NSUserDefaults *_userDefault;
    
    NSString *_playerName;
}

@end

@implementation User

@synthesize gameCenterManager = _gameCenterManager;
@synthesize anchorPoint = _anchorPoint, playTime = _playTime, bestScore = _bestScore;
@synthesize selectedPlaneIndex = _selectedPlaneIndex;

static User *_sharedUser;

+ (User *)SharedUser {
    @synchronized(_sharedUser) {
        if (_sharedUser == nil) {
            _sharedUser = [[User alloc] init];
        }
    }
    return _sharedUser;
}

- (id)init {
    if (self = [super init]) {
        _userDefault = [NSUserDefaults standardUserDefaults];
        
        // Check GameCenter
        if ([GameCenterManager isGameCenterAvailable]) {
            _gameCenterManager = [[GameCenterManager alloc] init];
            [_gameCenterManager setDelegate:self];
            [_gameCenterManager authenticateLocalUser];
        } else {
#ifdef DEBUG
            NSLog(@"Device does not support GameCenter");
#endif
        }
        
        _planeArray = [[NSMutableArray alloc] init];
        [_planeArray addObjectsFromArray: [[_userDefault objectForKey: kUserPlanesKey] componentsSeparatedByString:@","]];
        if (_planeArray.count == 0)
            [self addPlane:@"NormalPlane"];
        
        _selectedPlaneIndex = [[_userDefault objectForKey: kSelectedPlaneKey] intValue];
        
        NSNumber *anchorPoint = [_userDefault objectForKey: kAnchorPointKey];
        if (anchorPoint == nil)
            _anchorPoint = 0.3;
        else
            _anchorPoint = [anchorPoint floatValue];
        
        _playerName = [[_userDefault objectForKey: kUserNameKey] retain];
        _bestScore = [[_userDefault objectForKey: kBestScoreKey] doubleValue];
    }
    return self;
}

- (void)dealloc {
    [_planeArray removeAllObjects], [_planeArray release];
    [_playerName release];
    
    [super dealloc];
}

- (void)setSelectedPlaneIndex:(int)selectedPlaneIndex {
    _selectedPlaneIndex = selectedPlaneIndex;
    
    [_userDefault setObject:[NSNumber numberWithFloat: _selectedPlaneIndex] forKey:kSelectedPlaneKey];
    [_userDefault synchronize];
}

- (void)addPlane:(NSString *)planeName {
    if (![_planeArray containsObject: planeName]) {
        [_planeArray addObject: planeName];
        [_userDefault setObject: [_planeArray componentsJoinedByString: @","] forKey:kUserPlanesKey];
        [_userDefault synchronize];
    }
}

- (void)setAnchorPoint:(float)anchorPoint {
    _anchorPoint = anchorPoint;
    [_userDefault setObject:[NSNumber numberWithFloat: _anchorPoint] forKey:kAnchorPointKey];
    [_userDefault synchronize];
}

- (NSArray *)planeArray {
    return _planeArray;
}

- (NSString *)selectedPlane {
    return [_planeArray objectAtIndex: _selectedPlaneIndex];
}

- (void)setPlayTime:(double)playTime {
    _playTime = playTime;
    [self setBestScore: _playTime];
    if ([GameCenterManager isGameCenterAvailable]) {
        [_gameCenterManager reportScore:playTime*100.0f forCategory:@"leaderboard_01"];
    }
}

- (void)setBestScore:(double)bestScore {
    if (bestScore > _bestScore) {
        if ([GameCenterManager isGameCenterAvailable]) {
            if (bestScore > 30 && ![_planeArray containsObject: @"AssaultPlane-"]) {
                [self addPlane: @"AssaultPlane"];
                [_gameCenterManager submitAchievement:@"achievement_02" percentComplete: 100];
                
                [[[[UIAlertView alloc] initWithTitle:@"新機體獲得" message:@"恭喜你！獲得衝鋒機體！\n你可以到主頁>設定更換新機體" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles: nil] autorelease] show];
            }
            if (bestScore > 20 && ![_planeArray containsObject: @"AdvancedPlane"]) {
                [self addPlane: @"AdvancedPlane"];
                [_gameCenterManager submitAchievement:@"achievement_01" percentComplete: 100];
                
                [[[[UIAlertView alloc] initWithTitle:@"新機體獲得" message:@"恭喜你！獲得進階機體！\n你可以到主頁>設定更換新機體" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles: nil] autorelease] show];
            }
        }
        
        _bestScore = bestScore;
        [_userDefault setObject:[NSNumber numberWithDouble: _bestScore] forKey:kBestScoreKey];
        [_userDefault synchronize];
        
        [self _displayHighScoreAlert];
    }
}

- (void)_displayHighScoreAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"刷新紀錄" message:@"真是個勇者，劉明吧" delegate:self cancelButtonTitle:@"確定" otherButtonTitles: nil];
    [alertView setAlertViewStyle: UIAlertViewStylePlainTextInput];
    [alertView show];
    [alertView release];
}

#pragma mark UIAlertViewDelegate
- (void)didPresentAlertView:(UIAlertView *)alertView {
    [[alertView textFieldAtIndex: 0] setText: _playerName];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *tempString = [[alertView textFieldAtIndex:0] text];
    NSString *playerName = [tempString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    if (playerName.length > 0) {
        [_playerName release], _playerName = nil;
        _playerName = [playerName retain];
        [_userDefault setObject:_playerName forKey:kUserNameKey];
        [_userDefault synchronize];
        
//        PFObject *gameScore = [PFObject objectWithClassName: @"GameScore"];
//        [gameScore setObject:[NSNumber numberWithDouble:_bestScore] forKey:@"score"];
//        [gameScore setObject:_playerName forKey:@"playerName"];
//        [gameScore setObject:[_planeArray objectAtIndex: _selectedPlaneIndex] forKey:@"plane"];
//        [gameScore setObject:[NSNumber numberWithDouble:_anchorPoint] forKey:@"anchorPoint"];
//        [gameScore saveInBackground];
    } else {
        [self _displayHighScoreAlert];
    }
}

#pragma mark GameCenterManagerDelegate

- (void)processGameCenterAuth:(NSError *)error {
#ifdef DEBUG
    if (error) {
        NSLog(@"Game center auth fail: %@", error);
    } else {
        NSLog(@"Game center auth successful.");
    }
#endif
}

- (void)scoreReported:(NSError *)error {
#ifdef DEBUG
    if (error) {
        NSLog(@"Score report fail: %@", error);
    } else {
        NSLog(@"Score report successful.");
    }
#endif
}

- (void)achievementSubmitted:(GKAchievement *)ach error:(NSError *)error {
#ifdef DEBUG
    if (error) {
        NSLog(@"Achievement report fail: %@", error);
    } else {
        NSLog(@"Score report successful.");
    }
#endif
}

- (void)mappedPlayerIDToPlayer:(GKPlayer *)player error:(NSError *)error {
#ifdef DEBUG
    if (error) {
        NSLog(@"Mapping player fail: %@", error);
    } else {
        NSLog(@"Mapping player successful.");
    }
#endif
}

@end

//
//  LeaderboardLayer.m
//  TrainingInferno
//
//  Created by Dan on 13年6月27日.
//  Copyright 2013年 Dan. All rights reserved.
//

#import "LeaderboardLayer.h"

#import "MainScene.h"

@interface LeaderboardLayer () <UITableViewDataSource, UITableViewDelegate> {
    CGSize _screenSize;
    
    NSArray *_top100Record;
    
    UITableView *_recordTableView;
}

@end

@implementation LeaderboardLayer

+(CCScene *)scene {
	CCScene *scene = [CCScene node];
	LeaderboardLayer *layer = [LeaderboardLayer node];
	[scene addChild: layer];
	
	return scene;
}

- (id)init {
    if (self = [super init]) {
        _screenSize = [[CCDirector sharedDirector] winSize];
        
        _top100Record = [[NSMutableArray alloc] init];
        
        CCSprite *background = [CCSprite spriteWithFile: @"background.png"];
        background.position = ccp(_screenSize.width/2, _screenSize.height/2);
        [self addChild: background];
        
        CCMenuItem *homeButton = [CCMenuItemImage itemWithNormalImage:@"buttonHome.png" selectedImage:@"buttonHomeSelected.png" target:self selector:@selector(_goToMain)];
        homeButton.anchorPoint = ccp(0, 1);
        homeButton.position = ccp(0, 0);
        CCMenu *menu = [CCMenu menuWithItems:homeButton, nil];
        menu.position = ccp(0, _screenSize.height);
        [self addChild: menu];
        
//        PFQuery *query = [PFQuery queryWithClassName: @"GameScore"];
//        [query addDescendingOrder: @"score"];
//        query.limit = 100;
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            _top100Record = [objects retain];
//            if (_recordTableView != nil)
//                [_recordTableView reloadData];
//        }];
        
        _recordTableView = [[UITableView alloc] init];
        _recordTableView.showsHorizontalScrollIndicator = _recordTableView.showsVerticalScrollIndicator = NO;
        _recordTableView.backgroundColor = [UIColor clearColor];
        _recordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _recordTableView.frame = CGRectMake((_screenSize.width - 280) / 2, 0, 280, _screenSize.height);
        _recordTableView.dataSource = self;
        _recordTableView.delegate = self;
        [[[CCDirector sharedDirector] view] addSubview: _recordTableView];
    }
    return self;
}

- (void)dealloc {
    [_recordTableView setDelegate: nil], [_recordTableView setDataSource: nil], [_recordTableView removeFromSuperview], [_recordTableView release], _recordTableView = nil;
    
    [_top100Record release];
    
    [super dealloc];
}

- (void)_goToMain {
    [[SimpleAudioEngine sharedEngine] playEffect: @"selected.wav"];
    MainScene *mainScene = [[MainScene alloc] init];
    [[CCDirector sharedDirector] replaceScene: mainScene];
    [mainScene release];
}

#pragma mark UITableViewDelegate
- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return 85;
    return 0;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return [[[UIImageView alloc] initWithImage: [UIImage imageNamed:@"top100Image.png"]] autorelease];
    return [[UIView alloc] initWithFrame: CGRectZero];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const CellIdentifier = @"recordCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
    }
    
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor blackColor];
    } else {
        cell.contentView.backgroundColor = [UIColor darkGrayColor];
    }
    
    // Provide contents
//    PFObject *record = (PFObject *)[_top100Record objectAtIndex: indexPath.row];
//    [cell.textLabel setText: [NSString stringWithFormat: @"%d. %@", indexPath.row+1, [record objectForKey:@"playerName"]]];
//    [cell.detailTextLabel setText: [NSString stringWithFormat: @"%.2f秒", [[record objectForKey:@"score"] doubleValue]]];
    
    return cell;
}

#pragma mark UITableViewDataSource
- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 0;
    return [_top100Record count];
}

@end

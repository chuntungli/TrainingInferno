//
//  Record.h
//  TrainingInferno
//
//  Created by Dan on 13年6月18日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Record : NSObject <NSCoding>

- (NSComparisonResult)compare:(Record *)compareTo;

@property (nonatomic, retain) NSDate *recordDate;
@property (nonatomic, retain) NSString *recordName;
@property (nonatomic, assign) double playTime;

@property (nonatomic, assign) int normalBall;
@property (nonatomic, assign) int tracingBall;
@property (nonatomic, assign) int highSpeedBall;
@property (nonatomic, assign) int lowSpeedBall;

@end

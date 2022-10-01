//
//  Record.m
//  TrainingInferno
//
//  Created by Dan on 13年6月18日.
//  Copyright (c) 2013年 Dan. All rights reserved.
//

#import "Record.h"

#define RecordDateKey @"record_date_key"
#define RecordNameKey @"record_name_key"
#define RecordPlayTimeKey @"record_play_time_key"

#define RecordNormalBallKey @"record_normal_ball_key"
#define RecordTracingBallKey @"record_tracing_ball_key"
#define RecordHighSpeedBallKey @"record_high_speed_ball_key"
#define RecordLowSpeedBallKey @"record_low_speed_ball_key"

@implementation Record

@synthesize recordDate = _recordDate, recordName = _recordName, playTime = _playTime;
@synthesize normalBall = _normalBall, tracingBall = _tracingBall, highSpeedBall = _highSpeedBall, lowSpeedBall = _lowSpeedBall;

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.recordDate = [coder decodeObjectForKey: RecordDateKey];
        self.recordName = [coder decodeObjectForKey: RecordNameKey];
        self.playTime = [coder decodeDoubleForKey: RecordPlayTimeKey];
        
        self.normalBall = [coder decodeIntForKey: RecordNormalBallKey];
        self.tracingBall = [coder decodeIntForKey: RecordTracingBallKey];
        self.highSpeedBall = [coder decodeIntForKey: RecordHighSpeedBallKey];
        self.lowSpeedBall = [coder decodeIntForKey: RecordLowSpeedBallKey];
    }
    return self;
}

- (void)dealloc {
    [_recordDate release], _recordDate = nil;
    [_recordName release], _recordName = nil;
    
    [super dealloc];
}

- (NSComparisonResult)compare:(Record *)compareTo {
    if (_playTime > compareTo.playTime)
        return (NSComparisonResult)NSOrderedAscending;
    else if (_playTime < compareTo.playTime)
        return (NSComparisonResult)NSOrderedDescending;
    return (NSComparisonResult)NSOrderedSame;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.recordDate forKey:RecordDateKey];
    [coder encodeObject:self.recordName forKey:RecordDateKey];
    [coder encodeDouble:self.playTime forKey:RecordPlayTimeKey];
    
    [coder encodeInt:self.normalBall forKey:RecordNormalBallKey];
    [coder encodeInt:self.tracingBall forKey:RecordTracingBallKey];
    [coder encodeInt:self.highSpeedBall forKey:RecordHighSpeedBallKey];
    [coder encodeInt:self.lowSpeedBall forKey:RecordLowSpeedBallKey];
}

@end

//
//  Timer.h
//  Wallpapery
//
//  Created by Mauro on 26/10/23.
//  Copyright (c) 2023 Skyglow. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Timer : NSObject


@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) void (^wallpaperChangeCallback)(void);
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, readonly) BOOL isTimerRunning;
@property (nonatomic, strong) NSTextField *timeTextField;
@property (nonatomic) BOOL hasSentNotification;
@property (nonatomic) NSTimeInterval defaultTimeInterval;


- (void)startAutomaticWallpaperChangeWithCallbackForInterval:(NSTimeInterval)interval;
- (void)stopAutomaticWallpaperChange;
- (void)updateTimeLeft;

@end

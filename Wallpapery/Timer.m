//
//  Timer.m
//  Wallpapery
//
//  Created by Mauro on 26/10/23.
//  Copyright (c) 2023 Skyglow. All rights reserved.
//

#import "Timer.h"
#import "AppDelegate.h"

@interface Timer ()

@property (strong, nonatomic) NSTimer *wallpaperTimer;
@property (copy, nonatomic) void (^callback)(void);
@property (nonatomic) NSTimeInterval timeLeft;


@end

@implementation Timer
@synthesize isTimerRunning = _isTimerRunning;

- (BOOL)isTimerRunning {
    return self.wallpaperTimer != nil;
}

- (void)startAutomaticWallpaperChangeWithCallbackForInterval:(NSTimeInterval)interval {
    self.timeInterval = interval * 60.0; // Store the interval. Convert minutes to seconds.
    self.timeLeft = self.timeInterval;
    
    if (self.wallpaperTimer) {
        [self.wallpaperTimer invalidate];
        self.wallpaperTimer = nil;
    }
    
    // Create a new timer without automatically adding it to the run loop.
    self.wallpaperTimer = [NSTimer timerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(handleTimerTick:)
                                                userInfo:nil
                                                 repeats:YES];
    
    // Add the timer to the run loop in common modes.
    [[NSRunLoop currentRunLoop] addTimer:self.wallpaperTimer forMode:NSRunLoopCommonModes];
}

- (void)handleTimerTick:(NSTimer *)timer {
    
    self.timeLeft -= 5.0; // Decrease the time left by 5 seconds
    
    // Log the time left
    NSLog(@"Time left: %f seconds", self.timeLeft);
    
    // Update the UI with the time left
    [self updateTimeLeft];
    
    // If timer reaches 0, change wallpaper and restart timer
    if (self.timeLeft <= 0) {
        // Get AppDelegate instance
        AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        
        // Call the setRandomWallpaper method from AppDelegate
        [appDelegate setRandomWallpaper];
        
        // Restart the timer by invalidating the current one and recalling this method
        [timer invalidate];
        self.wallpaperTimer = nil;
        [self startAutomaticWallpaperChangeWithCallbackForInterval:self.timeInterval];
    }
}


- (void)stopAutomaticWallpaperChange {
    [self.wallpaperTimer invalidate];
    self.wallpaperTimer = nil;
}


- (void)handleWallpaperChange {
    NSLog(@"hay cacaca");
}


- (void)updateTimeLeft {
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    // Ensure UI updates are done on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.timeLeft <= 0) {
            [appDelegate.timeTextField setStringValue:@"Wallpaper should have changed!"];
        } else {
            NSInteger totalMinutesLeft = (NSInteger)(self.timeLeft / 60);  // Convert time to minutes
            NSInteger hours = totalMinutesLeft / 60;
            NSInteger minutes = totalMinutesLeft % 60;
            
            if (hours > 0) {
                [appDelegate.timeTextField setStringValue:[NSString stringWithFormat:@"Updates in %ldh:%ld", (long)hours, (long)minutes]];
            } else {
                [appDelegate.timeTextField setStringValue:[NSString stringWithFormat:@"Updates in %ldm", (long)minutes]];
            }
            
            NSLog(@"Updating UI with time left");
        }
    });
}


@end


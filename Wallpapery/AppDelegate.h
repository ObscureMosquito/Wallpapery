//
//  AppDelegate.h
//  Wallpapery
//
//  Created by Mauro on 15/10/23.
//  Copyright (c) 2023 Skyglow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Settings.h"
#import "Timer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSPopover *popover;
@property (strong, nonatomic) NSMenu *menu;
@property (nonatomic, strong) NSArray *wallpapersArray; // to hold the array of wallpapers fetched from Unsplash
@property (nonatomic, strong) NSString *currentRawURL;  // to store the URL of the currently displayed "small" wallpaper
@property (strong, nonatomic) NSDictionary *currentWallpaperData;
@property (weak) IBOutlet NSWindow *settingsWindow;
@property (strong, nonatomic) Settings *settingsController;
@property (weak, nonatomic) IBOutlet NSTextField *clientIdTextField;
@property (weak, nonatomic) IBOutlet NSPopUpButton *modeSelector;
@property (strong, nonatomic) Timer *wallpaperTimerManager;
@property (weak) IBOutlet NSSlider *refreshTimeSlider;
@property (weak) IBOutlet NSTextField *sliderValueLabel;


- (IBAction)modeChangedAction:(id)sender;
- (IBAction)setClientIdAction:(id)sender;
- (IBAction)showSettingsWindow:(id)sender;
- (IBAction)doneButtonAction:(id)sender;
- (void)setRandomWallpaper;
- (void)statusItemClicked;


@end

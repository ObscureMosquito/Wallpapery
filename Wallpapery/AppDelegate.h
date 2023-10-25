//
//  AppDelegate.h
//  Wallpapery
//
//  Created by Mauro on 15/10/23.
//  Copyright (c) 2023 Skyglow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSPopover *popover;
@property (strong, nonatomic) NSMenu *menu;
@property (nonatomic, strong) NSArray *wallpapersArray; // to hold the array of wallpapers fetched from Unsplash
@property (nonatomic, strong) NSString *currentRawURL;  // to store the URL of the currently displayed "small" wallpaper
@property (strong, nonatomic) NSDictionary *currentWallpaperData;


- (void)statusItemClicked;

@end

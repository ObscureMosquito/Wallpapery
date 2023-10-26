//
//  SettingsController.m
//  Wallpapery
//
//  Created by Mauro on 26/10/23.
//  Copyright (c) 2023 Skyglow. All rights reserved.
//

#import "Settings.h"
#import "AppDelegate.h"

@implementation Settings

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Assign the action to the button
    [self.doneButton setTarget:self];
    [self.doneButton setAction:@selector(doneButtonClicked:)];
}


- (void)saveClientId:(NSString *)clientId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:clientId forKey:@"UnsplashClientId"];
    [defaults synchronize];
}

- (IBAction)doneButtonClicked:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate.settingsWindow orderOut:nil];
}

@end

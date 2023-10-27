//
//  SettingsController.h
//  Wallpapery
//
//  Created by Mauro on 26/10/23.
//  Copyright (c) 2023 Skyglow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Settings : NSObject

@property (weak, nonatomic) IBOutlet NSButton *doneButton;

- (IBAction)doneButtonClicked:(id)sender;
- (void)saveClientId:(NSString *)clientId;


@end

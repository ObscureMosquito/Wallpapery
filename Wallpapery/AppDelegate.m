//
//  AppDelegate.m
//  Wallpapery
//
//  Created by Mauro on 15/10/23.
//  Copyright (c) 2023 Skyglow. All rights reserved.
//

#import "AppDelegate.h"
#import "Settings.h"
#import "Timer.h"

@interface NSMenu (secret)

- (void) _setHasPadding: (BOOL) pad onEdge: (int) whatEdge;

@end

@interface AppDelegate ()

@property (nonatomic, strong) NSTextField *locationTextField;
@property (nonatomic, strong) NSTextField *nameTextField;
@property (strong) NSImageView *imageViewPlaceholder;

- (void)fetchAndDisplayImageFromURL:(NSURL *)url;


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:27];
    
    // Get the original image
    NSImage *statusItemImage = [NSImage imageNamed:@"status_icon.png"];
    
    // Resize the image to fit the menu bar
    NSSize newSize = NSMakeSize(37, 36); // menu bar items are typically around 20x20
    NSImage *resizedImage = [[NSImage alloc] initWithSize:newSize];
    
    [resizedImage lockFocus];
    [statusItemImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
                       fromRect:NSZeroRect
                      operation:NSCompositeCopy
                       fraction:1.0];
    [resizedImage unlockFocus];
    
    self.statusItem.image = resizedImage;
    
    [self.statusItem setTarget:self];
    [self.statusItem setAction:@selector(statusItemClicked)];
    [self.statusItem setHighlightMode:YES];
    
    [self fetchWallpaperData];
    
    // Create the menu
    self.menu = [[NSMenu alloc] init];
    
    // Create a custom NSView for our menu
    NSView *customView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 295, 310)];
    customView.layer.backgroundColor = CGColorGetConstantColor(kCGColorClear);
    customView.wantsLayer = YES;
    NSImage *backgroundImage = [NSImage imageNamed:@"backround2.png"];
    customView.layer.contents = backgroundImage;
    customView.layer.contentsGravity = kCAGravityResizeAspectFill; // This line ensures the image fills the entire view.
    
    // Private method that removes top and bottom padding
    if ([self.menu respondsToSelector: @selector(_setHasPadding:onEdge:)]) {
        [self.menu _setHasPadding: NO onEdge: 1];
        [self.menu _setHasPadding: NO onEdge: 3];
    }

    
    // Add large image view placeholder for current wallpaper
    self.imageViewPlaceholder = [[NSImageView alloc] initWithFrame:NSMakeRect(49, 159, 197, 124)];
    self.imageViewPlaceholder.wantsLayer = YES;
    self.imageViewPlaceholder.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.imageViewPlaceholder.imageScaling = NSImageScaleAxesIndependently;
    NSImage *currentWallpaperImage = [[NSImage alloc] initWithContentsOfURL:[self currentWallpaperURL]];
    self.imageViewPlaceholder.image = currentWallpaperImage;


    [customView addSubview:self.imageViewPlaceholder];
    
    NSImage *originalFrameImage = [NSImage imageNamed:@"frame.png"];

    // Create a new image with the desired size (for example, 300 width and 475 height)
    NSImage *resizedFrameImage = [[NSImage alloc] initWithSize:NSMakeSize(275, 165)]; // Adjust width as needed

    [resizedFrameImage lockFocus];
    [originalFrameImage drawInRect:NSMakeRect(0, 0, resizedFrameImage.size.width, resizedFrameImage.size.height)
                          fromRect:NSZeroRect
                         operation:NSCompositeSourceOver
                          fraction:1.0];
    [resizedFrameImage unlockFocus];

    // Create the imageView for the frame using the resized image
    NSImageView *frameImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 135, 275, 170)];
    frameImageView.image = resizedFrameImage;
    frameImageView.wantsLayer = YES;

    // Create and set the shadow for the imageView
    NSShadow *frameShadow = [[NSShadow alloc] init];
    frameShadow.shadowColor = [NSColor blackColor];  // You can change this to any color you want
    frameShadow.shadowOffset = NSMakeSize(0, -4.0);  // This will determine the direction and distance of the shadow
    frameShadow.shadowBlurRadius = 5.0;  // This will determine how soft the shadow edges will be

    frameImageView.shadow = frameShadow;

    // Add the frame imageView to the customView
    [customView addSubview:frameImageView];

    // Add "Set as Wallpaper" button below the label
    NSButton *setWallpaperButton = [[NSButton alloc] initWithFrame:NSMakeRect(217, 68, 60, 60)]; // Adjust the frame to 40x40
    
    // Ensure the button doesn't have a title overlaying the image
    [setWallpaperButton setTitle:@""];
    
    // Load the image
    NSImage *buttonImage = [NSImage imageNamed:@"set_button.png"];
    [buttonImage setSize:NSMakeSize(79, 79)];
    
    [setWallpaperButton setImage:buttonImage];
    [setWallpaperButton setImagePosition:NSImageOnly];
    [setWallpaperButton setBordered:NO];
    [setWallpaperButton setButtonType:NSMomentaryChangeButton];
    
    [setWallpaperButton setTarget:self];
    [setWallpaperButton setAction:@selector(setWallpaperButtonClicked:)];
    
    
    [customView addSubview:setWallpaperButton];

    
    // Create "Next Wallpaper" button
    NSButton *nextWallpaperButton = [[NSButton alloc] initWithFrame:NSMakeRect(218, 3, 60, 60)];
    
    // Load the image
    NSImage *nextButtonImage = [NSImage imageNamed:@"next_button.png"];
    [nextButtonImage setSize:NSMakeSize(79, 79)]; // Set the image size to 40x40
    
    [nextWallpaperButton setImage:nextButtonImage];
    [nextWallpaperButton setImagePosition:NSImageOnly]; // Ensure only the image is displayed without any text
    
    [nextWallpaperButton setBordered:NO]; // Remove the border to make it look more like an image button
    [nextWallpaperButton setButtonType:NSMomentaryChangeButton]; // Momentary change button type
    
    [nextWallpaperButton setTarget:self];
    [nextWallpaperButton setAction:@selector(displayRandomWallpaper:)];
    
    
    [customView addSubview:nextWallpaperButton];
    
    // Create "Next Wallpaper" button
    NSButton *quitButton = [[NSButton alloc] initWithFrame:NSMakeRect(167, 40, 48, 48)];
    
    // Load the image
    NSImage *quitButtonImage = [NSImage imageNamed:@"quit_button.png"];
    [quitButtonImage setSize:NSMakeSize(49, 49)]; // Set the image size to 40x40
    
    [quitButton setImage:quitButtonImage];
    [quitButton setImagePosition:NSImageOnly]; // Ensure only the image is displayed without any text
    
    [quitButton setBordered:NO]; // Remove the border to make it look more like an image button
    [quitButton setButtonType:NSMomentaryChangeButton]; // Momentary change button type
    
    [quitButton setTarget:NSApp];  // Set target to the application object
    [quitButton setAction:@selector(terminate:)];  // Set action to terminate the application
    
    [customView addSubview:quitButton];
    
    NSButton *refreshButton = [[NSButton alloc] initWithFrame:NSMakeRect(165, 85, 52, 52)];
    
    // Load the image
    NSImage *refreshButtonImage = [NSImage imageNamed:@"refresh_button.png"];
    [refreshButtonImage setSize:NSMakeSize(53, 53)]; // Set the image size to 40x40
    
    [refreshButton setImage:refreshButtonImage];
    [refreshButton setImagePosition:NSImageOnly]; // Ensure only the image is displayed without any text
    
    [refreshButton setBordered:NO]; // Remove the border to make it look more like an image button
    [refreshButton setButtonType:NSMomentaryChangeButton]; // Momentary change button type
    
    [refreshButton setTarget:self];
    [refreshButton setAction:@selector(refreshWallpapers:)];
    
    [customView addSubview:refreshButton];

    NSButton *settingsButton = [[NSButton alloc] initWithFrame:NSMakeRect(173, 5, 36, 36)];
    
    // Load the image
    NSImage *settingsButtonImage = [NSImage imageNamed:@"settings_button.png"];
    [settingsButtonImage setSize:NSMakeSize(36, 36)];
    
    // Create a new image of the same size to draw the shadowed version
    NSImage *imageWithShadow = [[NSImage alloc] initWithSize:[settingsButtonImage size]];
    [imageWithShadow lockFocus];
    
    // Create and set the custom shadow
    NSShadow *customShadow = [[NSShadow alloc] init];
    [customShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:1]]; // semi-transparent black
    [customShadow setShadowOffset:NSMakeSize(0, -6)]; // Adjust as needed
    [customShadow setShadowBlurRadius:3]; // Adjust as needed
    [customShadow set];
    
    // Draw the original image
    [settingsButtonImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    [imageWithShadow unlockFocus];

    
    [settingsButton setImage:settingsButtonImage];
    [settingsButton setImagePosition:NSImageOnly]; // Ensure only the image is displayed without any text
    
    [settingsButton setBordered:NO]; // Remove the border to make it look more like an image button
    [settingsButton setButtonType:NSMomentaryChangeButton]; // Momentary change button type
    
    [settingsButton setTarget:self];
    [settingsButton setAction:@selector(showSettingsWindow:)];


    
    [customView addSubview:settingsButton];
    
    NSMenuItem *viewMenuItem = [[NSMenuItem alloc] init];
    [viewMenuItem setView:customView];
    [self.menu addItem:viewMenuItem];
    
    NSImageView *plaqueImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(-38, -17, 240, 155)];
    
    // Create and configure the shadow
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor blackColor]];  // Shadow color
    [shadow setShadowOffset:NSMakeSize(0, -10)];  // 0 for x-axis and -10 for y-axis to make it appear at the bottom
    [shadow setShadowBlurRadius:5.0];             // Adjust as needed
    
    // Apply the shadow to the image view
    [plaqueImageView setWantsLayer:YES];          // Necessary for shadow
    [plaqueImageView setShadow:shadow];
    
    [plaqueImageView setImage:[NSImage imageNamed:@"sign.png"]];
    plaqueImageView.imageScaling = NSImageScaleAxesIndependently; // This will stretch the image
    [customView addSubview:plaqueImageView];



    //Font
    NSFont *customFont = [NSFont fontWithName:@"American Typewriter" size:14];

    
    //Location
    
    self.locationTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(29, 56, 100, 20)]; // Adjust the frame so it fits inside the plaque
    [self.locationTextField setStringValue:@""];
    [self.locationTextField setFont:customFont];
    [self.locationTextField setBordered:NO];
    [self.locationTextField setBackgroundColor:[NSColor clearColor]];
    [self.locationTextField setEditable:NO];
    [self.locationTextField setSelectable:NO];
    [customView addSubview:self.locationTextField];
    
    //Author Name
    
    self.nameTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(29, 37, 100, 20)];
    [self.nameTextField setStringValue:@""];
    [self.nameTextField setFont:customFont];
    [self.nameTextField setBordered:NO];
    [self.nameTextField setBackgroundColor:[NSColor clearColor]];
    [self.nameTextField setEditable:NO];
    [self.nameTextField setSelectable:NO];
    [customView addSubview:self.nameTextField];
    
    //Time till update
    
    self.timeTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(29, 19, 125, 20)];
    [self.timeTextField setStringValue:@""];
    [self.timeTextField setFont:customFont];
    [self.timeTextField setTextColor:[NSColor blackColor]];
    [self.timeTextField setBordered:NO];
    [self.timeTextField setBackgroundColor:[NSColor clearColor]];
    [self.timeTextField setEditable:NO];
    [self.timeTextField setSelectable:NO];
    [customView addSubview:self.timeTextField];
    [self.timeTextField setNeedsDisplay:YES];
    [self.timeTextField.superview setNeedsLayout:YES];
    NSFont *currentFont = [self.timeTextField font];
    NSFont *smallerFont = [NSFont fontWithName:[currentFont fontName] size:12];
    [self.timeTextField setFont:smallerFont];

    
    self.settingsController = [[Settings alloc] init];
    self.wallpaperTimerManager = [[Timer alloc] init];
    
    NSString *savedMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"modePreference"];
    if ([savedMode isEqualToString:@"Automatic"]) {
        double savedSliderValue = [[NSUserDefaults standardUserDefaults] doubleForKey:@"sliderValue"];
        if(savedSliderValue == 0) {
            savedSliderValue = 60; // Default value
        }
        
        [self.wallpaperTimerManager startAutomaticWallpaperChangeWithCallbackForInterval:savedSliderValue];
        
        
    }

}


- (void)statusItemClicked {
    [self.statusItem popUpStatusItemMenu:self.menu];
}


- (IBAction)showSettingsWindow:(id)sender {
    [self.settingsWindow center];
    [self.settingsWindow setLevel:NSFloatingWindowLevel];
    [self.settingsWindow makeKeyAndOrderFront:self];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self setupInterface];
}

- (IBAction)setClientIdAction:(id)sender {
    [self.settingsController saveClientId:self.clientIdTextField.stringValue];
}

- (IBAction)doneButtonAction:(id)sender {
    [self.settingsController doneButtonClicked:sender];
}

- (IBAction)modeChangedAction:(id)sender {
    NSString *selectedMode = self.modeSelector.selectedItem.title;

    [[NSUserDefaults standardUserDefaults] setObject:selectedMode forKey:@"modePreference"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Saved mode: %@", selectedMode);
    
    if ([selectedMode isEqualToString:@"Automatic"]) {
        // Get the slider's value and convert it to seconds
        NSTimeInterval selectedInterval = self.refreshTimeSlider.doubleValue;
        [self.wallpaperTimerManager startAutomaticWallpaperChangeWithCallbackForInterval:selectedInterval];
    } else {
        [self.wallpaperTimerManager stopAutomaticWallpaperChange];
    }
}



- (IBAction)sliderValueChanged:(NSSlider *)slider {
    // Get the slider's value in minutes
    double minutesValue = [slider doubleValue];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"savedTimeLeft"];
    [defaults synchronize];
    
    // Calculate hours and minutes for display
    NSInteger hours = (NSInteger)minutesValue / 60;
    NSInteger minutes = (NSInteger)minutesValue % 60;
    
    NSString *formattedTime;
    if (hours > 0) {
        formattedTime = [NSString stringWithFormat:@"%ldh:%ldm", (long)hours, (long)minutes];
    } else {
        formattedTime = [NSString stringWithFormat:@"%ldm", (long)minutes];
    }
    
    // Update the label with the formatted time value
    self.sliderValueLabel.stringValue = formattedTime;
    
    // Save the slider's value to UserDefaults
    [[NSUserDefaults standardUserDefaults] setDouble:minutesValue forKey:@"sliderValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.wallpaperTimerManager updateTimeLeft];
    
    NSString *selectedMode = [[NSUserDefaults standardUserDefaults] objectForKey:@"modePreference"];
    if ([selectedMode isEqualToString:@"Automatic"]) {
        // Check if the timer is currently running
        if (self.wallpaperTimerManager.isTimerRunning) {
            // Stop the current timer if it's running
            [self.wallpaperTimerManager stopAutomaticWallpaperChange];
            
            // Restart the timer with the new interval
            [self.wallpaperTimerManager startAutomaticWallpaperChangeWithCallbackForInterval:minutesValue];
        }
    }
}


- (void)setupInterface {
    // Get the saved slider value, defaulting to a default value (e.g., 5) if not found
    double savedSliderValue = [[NSUserDefaults standardUserDefaults] doubleForKey:@"sliderValue"];
    if(savedSliderValue == 0) {
        savedSliderValue = 60; // Default value
    }
    
    // Set the slider's value
    [self.refreshTimeSlider setDoubleValue:savedSliderValue];
    
    // Calculate hours and minutes for display
    NSInteger hours = (NSInteger)savedSliderValue / 60;
    NSInteger minutes = (NSInteger)savedSliderValue % 60;
    
    NSString *formattedTime;
    if (hours > 0) {
        formattedTime = [NSString stringWithFormat:@"%ldh:%ldm", (long)hours, (long)minutes];
    } else {
        formattedTime = [NSString stringWithFormat:@"%ldm", (long)minutes];
    }
    
    // Update the label with the formatted time value
    self.sliderValueLabel.stringValue = formattedTime;
    
    // Fetch saved clientId and set it to the clientIdTextField
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *clientId = [defaults objectForKey:@"UnsplashClientId"];
    if (!clientId || [clientId length] == 0) {
        clientId = @"Client id...";
    }
    
    NSLog(@"Retrieved clientId: %@", clientId);
    
    [self.clientIdTextField setStringValue:clientId];
    
    // Set the mode based on saved preference
    NSString *savedMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"modePreference"];
    if (savedMode) {
        [self.modeSelector selectItemWithTitle:savedMode];
    }
}


- (void)setRandomWallpaper {
    // Step 1: Pick a random wallpaper
    if (!self.wallpapersArray || self.wallpapersArray.count == 0) {
        NSLog(@"Wallpapers array is empty or not initialized.");
        return;
    }
    
    NSDictionary *randomWallpaper = self.wallpapersArray[arc4random_uniform((uint32_t)self.wallpapersArray.count)];
    
    // Step 2: Get its URL
    NSString *rawURLString = randomWallpaper[@"urls"][@"raw"];
    if (!rawURLString) {
        NSLog(@"Failed to retrieve raw URL string from selected wallpaper.");
        return;
    }
    NSURL *rawURL = [NSURL URLWithString:rawURLString];
    
    // Step 3-5: Download, save locally, and set as desktop background
    // Using the logic from `setNewWallpaper` function
    
    NSString *appSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *wallpaperyDir = [appSupportDir stringByAppendingPathComponent:@"Wallpapery"];
    NSString *currentWallpaperNameFilePath = [wallpaperyDir stringByAppendingPathComponent:@"currentWallpaperName.txt"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:currentWallpaperNameFilePath]) {
        NSString *previousWallpaperName = [NSString stringWithContentsOfFile:currentWallpaperNameFilePath encoding:NSUTF8StringEncoding error:nil];
        if (previousWallpaperName) {
            NSString *previousWallpaperPath = [wallpaperyDir stringByAppendingPathComponent:previousWallpaperName];
            [[NSFileManager defaultManager] removeItemAtPath:previousWallpaperPath error:nil];
        }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:wallpaperyDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:wallpaperyDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *randomWallpaperName = [NSString stringWithFormat:@"wallpaper_%lu.jpg", (unsigned long)arc4random_uniform(UINT32_MAX)];
    [randomWallpaperName writeToFile:currentWallpaperNameFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSURL *randomWallpaperURL = [NSURL fileURLWithPath:[wallpaperyDir stringByAppendingPathComponent:randomWallpaperName]];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:rawURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            [data writeToURL:randomWallpaperURL atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setDesktopImageWithLocalURL:randomWallpaperURL];
            });
        }
    }] resume];
}


- (void)setNewWallpaper {
    NSURL *newWallpaperURL = [self newWallpaperURL];
    
    // Define the path to Wallpapery directory and the file to hold the name of the current wallpaper
    NSString *appSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *wallpaperyDir = [appSupportDir stringByAppendingPathComponent:@"Wallpapery"];
    NSString *currentWallpaperNameFilePath = [wallpaperyDir stringByAppendingPathComponent:@"currentWallpaperName.txt"];
    
    // Check if there's a previous wallpaper saved and delete it
    if ([[NSFileManager defaultManager] fileExistsAtPath:currentWallpaperNameFilePath]) {
        NSString *previousWallpaperName = [NSString stringWithContentsOfFile:currentWallpaperNameFilePath encoding:NSUTF8StringEncoding error:nil];
        if (previousWallpaperName) {
            NSString *previousWallpaperPath = [wallpaperyDir stringByAppendingPathComponent:previousWallpaperName];
            [[NSFileManager defaultManager] removeItemAtPath:previousWallpaperPath error:nil];
        }
    }
    
    // If no new wallpaper URL, show an alert and return
    if (!newWallpaperURL || ![self clientIdIsSet]) {
        [self showMissingClientIdAlert];
        return;
    }
    
    if ([newWallpaperURL isFileURL]) {
        [self setDesktopImageWithLocalURL:newWallpaperURL];
    } else {
        // Ensure the Wallpapery directory in Application Support exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:wallpaperyDir]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:wallpaperyDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // Generate a random name for the wallpaper and save its name
        NSString *randomWallpaperName = [NSString stringWithFormat:@"wallpaper_%lu.jpg", (unsigned long)arc4random_uniform(UINT32_MAX)];
        [randomWallpaperName writeToFile:currentWallpaperNameFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        NSURL *randomWallpaperURL = [NSURL fileURLWithPath:[wallpaperyDir stringByAppendingPathComponent:randomWallpaperName]];
        
        // Download the image
        [[[NSURLSession sharedSession] dataTaskWithURL:newWallpaperURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data) {
                // Save the downloaded image to the Wallpapery folder with the random name
                [data writeToURL:randomWallpaperURL atomically:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setDesktopImageWithLocalURL:randomWallpaperURL];
                });
            }
        }] resume];
    }
}

- (BOOL)clientIdIsSet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *clientId = [defaults objectForKey:@"UnsplashClientId"];
    return clientId && clientId.length > 0;
}

- (void)setDesktopImageWithLocalURL:(NSURL *)localURL {
    NSError *error;
    [[NSWorkspace sharedWorkspace] setDesktopImageURL:localURL forScreen:[NSScreen mainScreen] options:nil error:&error];
    
    if (error) {
        NSLog(@"Failed to set new wallpaper: %@", error);
    } else {
        [self.imageViewPlaceholder setImage:[[NSImage alloc] initWithContentsOfURL:localURL]];
    }
}


- (NSURL *)newWallpaperURL {
    if (self.currentWallpaperData) {
        NSString *rawURLString = self.currentWallpaperData[@"urls"][@"raw"];
        return [NSURL URLWithString:rawURLString];
    }
    return nil;  // No current data available
}

-(void)refreshWallpapers:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *wallpaperyDirectory = [[paths firstObject] stringByAppendingPathComponent:@"Wallpapery"];
    NSString *filePath = [wallpaperyDirectory stringByAppendingPathComponent:@"WallpaperyData.json"];
    NSLog(@"Refresh Initiated");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
        [self fetchWallpaperData];
    }
}


- (NSString *)getCurrentWallpaperPathUsingAppleScript {
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"tell app \"finder\" to get POSIX path of (desktop picture as alias)"];
    NSAppleEventDescriptor *descriptor = [script executeAndReturnError:nil];
    return [descriptor stringValue];
}


- (NSURL *)currentWallpaperURL {
    NSString *path = [self getCurrentWallpaperPathUsingAppleScript];
    if (!path) {
        NSLog(@"Could not retrieve current wallpaper path.");
        return nil;
    }
    return [NSURL fileURLWithPath:path];
}


- (void)setWallpaperButtonClicked:(id)sender {
    NSLog(@"Set Wallpaper button clicked.");
    [self setNewWallpaper];
}


- (void)fetchWallpaperData {
    // Path to save data in Application Support inside Wallpapery folder
    NSString *appSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *wallpaperyDir = [appSupportDir stringByAppendingPathComponent:@"Wallpapery"];
    NSString *dataFilePath = [wallpaperyDir stringByAppendingPathComponent:@"WallpaperyData.json"];
    NSString *dateFilePath = [wallpaperyDir stringByAppendingPathComponent:@"WallpaperyDataDate.txt"];
    
    // Check if Wallpapery directory exists, if not create it
    if (![[NSFileManager defaultManager] fileExistsAtPath:wallpaperyDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:wallpaperyDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // Try loading from Application Support first
    NSData *cachedData = [NSData dataWithContentsOfFile:dataFilePath];
    NSDate *cachedDate = [NSDate dateWithTimeIntervalSince1970:[[NSString stringWithContentsOfFile:dateFilePath encoding:NSUTF8StringEncoding error:nil] doubleValue]];
    
    if (cachedData && cachedDate) {
        NSDate *currentDate = [NSDate date];
        NSTimeInterval timeSinceCache = [currentDate timeIntervalSinceDate:cachedDate];
        
        if (timeSinceCache < (5 * 24 * 60 * 60)) {  // 5 days in seconds
            NSError *jsonError;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:cachedData options:kNilOptions error:&jsonError];
            if (!jsonError) {
                self.wallpapersArray = [json mutableCopy];
                NSLog(@"Using cached data");
                return;
            }
        }
    }
    
    // Retrieve client-id from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *clientId = [defaults stringForKey:@"UnsplashClientId"];
    
    if (clientId.length == 0) {
        // Show an alert if the client-id is blank
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Missing API Key"];
        [alert setInformativeText:@"You must enter your Unsplash API Key in settings, Wallpapery will not work without this."];
        [alert addButtonWithTitle:@"Fix"];
        
        NSModalResponse response = [alert runModal];
        
        if (response == NSAlertFirstButtonReturn) {
            [self showSettingsWindow:self];
        }
        
        return;
    }

    // If no valid cached data is available, proceed with API request
    NSURL *apiURL = [NSURL URLWithString:@"https://api.unsplash.com/photos/random?count=100&orientation=landscape"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    
    // Set HTTP headers
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"Unsplash%20Wallpapers/44 CFNetwork/1240.0.4.5 Darwin/20.6.0" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"en-gb" forHTTPHeaderField:@"Accept-Language"];
    NSString *authHeaderValue = [NSString stringWithFormat:@"Client-ID %@", clientId];
    [request setValue:authHeaderValue forHTTPHeaderField:@"Authorization"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error fetching JSON: %@", error);
            return;
        }
        
        NSData *dataToProcess;
        if ([self macOSSupportsAutomaticBrotliDecompression]) {
            dataToProcess = data;
        } else {
            dataToProcess = [self decompressBrotliData:data];
        }
        
        // Attempt to parse the data as JSON
        NSError *jsonError;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:dataToProcess options:kNilOptions error:&jsonError];
        
        if (!jsonError) {
            self.wallpapersArray = [json mutableCopy];
            
            // Save the data to Application Support in Wallpapery folder
            [dataToProcess writeToFile:dataFilePath atomically:YES];
            
            // Save the current date as the cache date
            NSString *currentDateString = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
            [currentDateString writeToFile:dateFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSLog(@"HTTP status code: %ld", (long)httpResponse.statusCode);
            
            if (httpResponse.statusCode != 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showInvalidClientIdAlert];
                });
            }
        }
    }] resume];
}

- (void)showInvalidClientIdAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Invalid API Key"];
    [alert setInformativeText:@"Your client-id is invalid or was not accepted by Unsplash, please make sure you entered it correctly without any extraneous characters."];
    [alert addButtonWithTitle:@"Fix"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSInteger modalResult = [alert runModal];
    
    switch (modalResult) {
        case NSAlertFirstButtonReturn: // Fix button
            [self showSettingsWindow:self];
            break;
        case NSAlertSecondButtonReturn: // Cancel button
            // Handle any logic for the cancel button, if needed
            break;
        default:
            break;
    }
}


- (BOOL)macOSSupportsAutomaticBrotliDecompression {
    NSString *versionString = [[NSProcessInfo processInfo] operatingSystemVersionString];
    NSArray *versionComponents = [versionString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    
    if (versionComponents.count >= 2) {
        NSInteger majorVersion = [versionComponents[0] integerValue];
        NSInteger minorVersion = [versionComponents[1] integerValue];
        
        // Assuming that macOS version 10.14 and above support the feature.
        if (majorVersion > 10 || (majorVersion == 10 && minorVersion >= 14)) {
            return YES;
        }
    }
    
    return NO;
}


- (NSData *)decompressBrotliData:(NSData *)compressedData {
    

    NSString *tempInputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempBrCompressed.br"];
    NSString *tempOutputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tempBrDecompressed.json"];
    
    // Write the compressed data to a temporary file
    [compressedData writeToFile:tempInputPath atomically:YES];
    
    // Get the path to the bundled brotli binary
    NSString *brotliPath = [[NSBundle mainBundle] pathForResource:@"brotli" ofType:nil];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:brotliPath];  // Use the bundled brotli binary path here
    [task setArguments:@[@"-d", tempInputPath, @"-o", tempOutputPath]];
    
    [task launch];
    [task waitUntilExit];
    
    // Read the decompressed data from the output file
    NSData *decompressedData = [NSData dataWithContentsOfFile:tempOutputPath];
    
    if (!decompressedData) {
         NSLog(@"Failed to decompress data.");
         return nil;
     }
    
    // Optionally, clean up the temporary files
    [[NSFileManager defaultManager] removeItemAtPath:tempInputPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:tempOutputPath error:nil];
    
    return decompressedData;
}


- (IBAction)displayRandomWallpaper:(id)sender {
    if (![self.wallpapersArray isKindOfClass:[NSArray class]] || self.wallpapersArray.count == 0) {
        // Handle the error - display an alert about the missing client ID
        [self showMissingClientIdAlert];
        return;
    }
    
    NSLog(@"Wallpapers count: %lu", (unsigned long)self.wallpapersArray.count);
    
    id randomElement = self.wallpapersArray[arc4random_uniform((uint32_t)self.wallpapersArray.count)];
    
    if (![randomElement isKindOfClass:[NSDictionary class]]) {
        // Handle the error - the element isn't a dictionary as expected
        [self showMissingClientIdAlert];
        return;
    }
    
    NSDictionary *randomWallpaper = (NSDictionary *)randomElement;
    NSString *smallURLString = randomWallpaper[@"urls"][@"small"];
    NSLog(@"Randomly selected wallpaper URL: %@", smallURLString);
    
    if (!smallURLString) {
        // Handle the error - the URL is missing
        [self showMissingClientIdAlert];
        return;
    }
    
    self.currentWallpaperData = randomWallpaper;
    [self fetchAndDisplayImageFromURL:[NSURL URLWithString:smallURLString]];
}

- (void)showMissingClientIdAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Missing API Key"];
    [alert setInformativeText:@"You must enter your Unsplash API Key in settings, Wallpapery will not work without this."];
    [alert addButtonWithTitle:@"Fix"];
    
    NSInteger modalResult = [alert runModal];
    
    switch (modalResult) {
        case NSAlertFirstButtonReturn: // Fix button
            [self showSettingsWindow:self];
            break;
    }
}



- (IBAction)setWallpaper:(id)sender {
    if (self.currentRawURL) {
        NSURL *rawURL = [NSURL URLWithString:self.currentRawURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:rawURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Error fetching raw image: %@", error);
                return;
            }
            
            if (data) {
                NSImage *image = [[NSImage alloc] initWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSError *error;
                        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"wallpaper.jpeg"];
                        [data writeToFile:path atomically:YES];
                        NSURL *fileURL = [NSURL fileURLWithPath:path];
                        [[NSWorkspace sharedWorkspace] setDesktopImageURL:fileURL forScreen:[NSScreen mainScreen] options:nil error:&error];
                        if (error) {
                            NSLog(@"Error setting wallpaper: %@", error);
                        }
                    });
                } else {
                    NSLog(@"Failed to create image from data");
                }
            }
        }] resume];
    }
}


- (void)fetchAndDisplayImageFromURL:(NSURL *)url {
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error fetching image: %@", error);
            return;
        }
        
        NSImage *downloadedImage = [[NSImage alloc] initWithData:data];
        if (downloadedImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageViewPlaceholder.image = downloadedImage;
                
                // After the image has been set, fetch the associated JSON data from the cache
                NSLog(@"FetchImage Called");
                NSDictionary *imageData = [self fetchJSONDataForImageWithURL:url];
                
                if (imageData) {
                    NSString *location = imageData[@"location"];
                    NSString *name = imageData[@"name"];
                    self.locationTextField.textColor = [NSColor blackColor]; // For example, set to red color
                    self.nameTextField.textColor = [NSColor blackColor];

                    
                    // Check if location is <null> or is NSNull and replace with Unknown Location
                    if ([location isKindOfClass:[NSNull class]] || [location isEqualToString:@"<null>"]) {
                        location = @"Unknown Location";
                    }
                    
                    NSLog(@"Before setting - Location: %@, Name: %@", location, name);
                    
                    [self.locationTextField setNeedsDisplay:YES];
                    [self.nameTextField setNeedsDisplay:YES];
                    
                    self.locationTextField.stringValue = location ?: @"Unknown Location";
                    self.nameTextField.stringValue = name ?: @"Unknown Name";
                    self.locationTextField.textColor = [NSColor darkGrayColor]; // For example, set to red color
                    self.nameTextField.textColor = [NSColor darkGrayColor];

                    
                    NSLog(@"After setting - Location: %@, Name: %@", self.locationTextField.stringValue, self.nameTextField.stringValue);
                } else {
                    NSLog(@"Image data returned nil for URL: %@", [url absoluteString]);
                }

                
            });
        }
    }] resume];
}


- (NSDictionary *)fetchJSONDataForImageWithURL:(NSURL *)url {
    NSString *appSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
    NSString *wallpaperyDirectory = [appSupportDirectory stringByAppendingPathComponent:@"Wallpapery"];
    NSString *jsonFilePath = [wallpaperyDirectory stringByAppendingPathComponent:@"WallpaperyData.json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath];
    if (jsonData) {
        NSError *jsonError = nil;
        NSArray *jsonResponseArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
        
        if (!jsonError && [jsonResponseArray isKindOfClass:[NSArray class]]) {
            NSLog(@"JSON data retrieved and parsed successfully. Searching for URL...");
            
            for (NSDictionary *entry in jsonResponseArray) {
                NSDictionary *urls = entry[@"urls"];
                if ([urls isKindOfClass:[NSDictionary class]]) {
                    NSString *smallImageURL = urls[@"small"];
                    if ([url.absoluteString isEqualToString:smallImageURL]) {
                        NSDictionary *userDetails = entry[@"user"];
                        if ([userDetails isKindOfClass:[NSDictionary class]]) {
                            return userDetails;
                        }
                    }
                }
            }

        } else {
            NSLog(@"Error parsing JSON: %@", jsonError.localizedDescription);
        }
    } else {
        NSLog(@"No cached JSON data found at path: %@", jsonFilePath);
    }
    
    return nil;
}

- (IBAction)helpButtonClicked:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"What is this?"];
    [alert setInformativeText:@"In order to use Wallpapery, you must obtain your own Unsplash API key. It is free of charge and offers up to 50 thirty-wallpaper pack recharges a day."];
    [alert addButtonWithTitle:@"Tell me how"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Why?"];
    
    NSModalResponse response = [alert runModal];
    
    switch(response) {
        case NSAlertFirstButtonReturn: {
            NSAlert *howAlert = [[NSAlert alloc] init];
            [howAlert setMessageText:@"How to get an API Key?"];
            [howAlert setInformativeText:@"You will have to create an account on Unsplash's developer website, free of charge, create a project, and then input the given client id into Wallpapery's settings."];
            [howAlert addButtonWithTitle:@"Go"];
            [howAlert addButtonWithTitle:@"Cancel"];
            
            NSModalResponse howResponse = [howAlert runModal];
            
            if (howResponse == NSAlertFirstButtonReturn) {
                // "Go" button was pressed
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://unsplash.com/developers"]];
                 [self.settingsWindow orderOut:nil];
            }
            break;
        }
        case NSAlertThirdButtonReturn: {
            NSAlert *whyAlert = [[NSAlert alloc] init];
            [whyAlert setMessageText:@"Why API Key?"];
            [whyAlert setInformativeText:@"Wallpapery needs Unsplash' permission to use their wallpapers on your computer. An API key (or client id) is the means by which Wallpapery identifies itself."];
            [whyAlert addButtonWithTitle:@"Tell me how"];
            [whyAlert addButtonWithTitle:@"Cancel"];
            
            NSModalResponse whyResponse = [whyAlert runModal];
            
            if (whyResponse == NSAlertFirstButtonReturn) {
                NSAlert *howAlert = [[NSAlert alloc] init];
                [howAlert setMessageText:@"How to get an API Key?"];
                [howAlert setInformativeText:@"You will have to create an account on Unsplash's developer website, free of charge, create a project, and then input the given client id into Wallpapery's settings."];
                [howAlert addButtonWithTitle:@"Go"];
                [howAlert addButtonWithTitle:@"Cancel"];
                
                NSModalResponse howResponse = [howAlert runModal];
                
                if (howResponse == NSAlertFirstButtonReturn) {
                    // "Go" button was pressed
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://unsplash.com/developers"]];
                     [self.settingsWindow orderOut:nil];
                }
            }
            break;
        }
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end

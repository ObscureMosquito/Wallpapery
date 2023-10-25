//
//  AppDelegate.m
//  Wallpapery
//
//  Created by Mauro on 15/10/23.
//  Copyright (c) 2023 Skyglow. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSTextField *locationTextField;
@property (nonatomic, strong) NSTextField *nameTextField;
@property (strong) NSImageView *imageViewPlaceholder;

- (void)fetchAndDisplayImageFromURL:(NSURL *)url;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:25];
    
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
    
    // Set the resized image to the status item
    self.statusItem.image = resizedImage;
    
    [self.statusItem setTarget:self];
    [self.statusItem setAction:@selector(statusItemClicked)];
    [self.statusItem setHighlightMode:YES];
    
    [self fetchWallpaperData];
    
    // Create the menu
    self.menu = [[NSMenu alloc] init];
    
    // Create a custom NSView for our menu
    NSView *customView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 295, 310)];
    customView.wantsLayer = YES;
    NSImage *backgroundImage = [NSImage imageNamed:@"backround_2.jpg"];
    customView.layer.contents = backgroundImage;
    customView.layer.contentsGravity = kCAGravityResizeAspectFill; // This line ensures the image fills the entire view.

    
    // Add large image view placeholder for current wallpaper
    self.imageViewPlaceholder = [[NSImageView alloc] initWithFrame:NSMakeRect(49, 152, 197, 118)];
    self.imageViewPlaceholder.wantsLayer = YES;
    self.imageViewPlaceholder.imageScaling = NSImageScaleProportionallyUpOrDown;
    self.imageViewPlaceholder.imageScaling = NSImageScaleAxesIndependently;
    NSImage *currentWallpaperImage = [[NSImage alloc] initWithContentsOfURL:[self currentWallpaperURL]];
    self.imageViewPlaceholder.image = currentWallpaperImage;

    
    // Add the wallpaper imageView to the customView first
    [customView addSubview:self.imageViewPlaceholder];
    
    NSImage *originalFrameImage = [NSImage imageNamed:@"frame4.png"];
    
    // Create a new image with the desired height (let's say 300 in this example)
    NSImage *resizedFrameImage = [[NSImage alloc] initWithSize:NSMakeSize(originalFrameImage.size.width, 375)];
    
    [resizedFrameImage lockFocus];
    [originalFrameImage drawInRect:NSMakeRect(0, 0, resizedFrameImage.size.width, resizedFrameImage.size.height)
                          fromRect:NSZeroRect
                         operation:NSCompositeSourceOver
                          fraction:1.0];
    [resizedFrameImage unlockFocus];
    
    // Create the imageView for the frame using the resized image
    NSImageView *frameImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(-8, -40, 310, 500)];
    frameImageView.image = resizedFrameImage;
    frameImageView.wantsLayer = YES;
    
    // Add the frame imageView to the customView on top of the wallpaper imageView
    [customView addSubview:frameImageView];

    // Add "Set as Wallpaper" button below the label
    NSButton *setWallpaperButton = [[NSButton alloc] initWithFrame:NSMakeRect(217, 58, 60, 60)]; // Adjust the frame to 40x40
    
    // Ensure the button doesn't have a title overlaying the image
    [setWallpaperButton setTitle:@""];
    
    // Load the image
    NSImage *buttonImage = [NSImage imageNamed:@"set_button.png"];
    [buttonImage setSize:NSMakeSize(72, 72)];
    
    [setWallpaperButton setImage:buttonImage];
    [setWallpaperButton setImagePosition:NSImageOnly];
    [setWallpaperButton setBordered:NO];
    [setWallpaperButton setButtonType:NSMomentaryChangeButton];
    
    [setWallpaperButton setTarget:self];
    [setWallpaperButton setAction:@selector(setWallpaperButtonClicked:)];
    
    
    [customView addSubview:setWallpaperButton];

    
    // Create "Next Wallpaper" button
    NSButton *nextWallpaperButton = [[NSButton alloc] initWithFrame:NSMakeRect(218, 2, 60, 60)];
    
    // Load the image
    NSImage *nextButtonImage = [NSImage imageNamed:@"next_button.png"];
    [nextButtonImage setSize:NSMakeSize(72, 72)]; // Set the image size to 40x40
    
    [nextWallpaperButton setImage:nextButtonImage];
    [nextWallpaperButton setImagePosition:NSImageOnly]; // Ensure only the image is displayed without any text
    
    [nextWallpaperButton setBordered:NO]; // Remove the border to make it look more like an image button
    [nextWallpaperButton setButtonType:NSMomentaryChangeButton]; // Momentary change button type
    
    [nextWallpaperButton setTarget:self];
    [nextWallpaperButton setAction:@selector(displayRandomWallpaper:)];
    
    
    [customView addSubview:nextWallpaperButton];
    
    // Create "Next Wallpaper" button
    NSButton *quitButton = [[NSButton alloc] initWithFrame:NSMakeRect(176, 40, 40, 40)];
    
    // Load the image
    NSImage *quitButtonImage = [NSImage imageNamed:@"quit_button.png"];
    [quitButtonImage setSize:NSMakeSize(40, 40)]; // Set the image size to 40x40
    
    [quitButton setImage:quitButtonImage];
    [quitButton setImagePosition:NSImageOnly]; // Ensure only the image is displayed without any text
    
    [quitButton setBordered:NO]; // Remove the border to make it look more like an image button
    [quitButton setButtonType:NSMomentaryChangeButton]; // Momentary change button type
    
    [quitButton setTarget:NSApp];  // Set target to the application object
    [quitButton setAction:@selector(terminate:)];  // Set action to terminate the application
    
    [customView addSubview:quitButton];
    
    
    NSMenuItem *viewMenuItem = [[NSMenuItem alloc] init];
    [viewMenuItem setView:customView];
    [self.menu addItem:viewMenuItem];
    
    NSImageView *plaqueImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(-50, 16, 290, 90)]; // Adjust the frame as needed
    [plaqueImageView setImage:[NSImage imageNamed:@"plaque2.png"]];
    [customView addSubview:plaqueImageView];
    
    //Font
    NSFont *customFont = [NSFont fontWithName:@"Times New Roman" size:14];
    
    //Location
    
    self.locationTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(32, 70, 125, 20)]; // Adjust the frame so it fits inside the plaque
    [self.locationTextField setStringValue:@""];
    [self.locationTextField setFont:customFont];
    [self.locationTextField setTextColor:[NSColor darkGrayColor]];
    [self.locationTextField setBordered:NO];
    [self.locationTextField setBackgroundColor:[NSColor clearColor]];
    [self.locationTextField setEditable:NO];
    [self.locationTextField setSelectable:NO];
    [customView addSubview:self.locationTextField];
    
    //Author Name
    
    self.nameTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(32, 50, 125, 20)]; // Adjust the frame so it fits inside the plaque
    [self.nameTextField setStringValue:@""];
    [self.nameTextField setFont:customFont];
    [self.nameTextField setTextColor:[NSColor darkGrayColor]];
    [self.nameTextField setBordered:NO];
    [self.nameTextField setBackgroundColor:[NSColor clearColor]];
    [self.nameTextField setEditable:NO];
    [self.nameTextField setSelectable:NO];
    [customView addSubview:self.nameTextField];


}

- (void)statusItemClicked {
    
    [self.statusItem popUpStatusItemMenu:self.menu];
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
    
    // If no new wallpaper URL, return
    if (!newWallpaperURL) {
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
    NSLog(@"Set Wallpaper button clicked.");  // Debug message
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
    
    // If no valid cached data is available, proceed with API request
    NSURL *apiURL = [NSURL URLWithString:@"https://api.unsplash.com/photos/random?count=100&orientation=landscape"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiURL];
    
    // Set HTTP headers
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"Unsplash%20Wallpapers/44 CFNetwork/1240.0.4.5 Darwin/20.6.0" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"en-gb" forHTTPHeaderField:@"Accept-Language"];
    [request setValue:@"Client-ID -Z2ubPge09M3Zgk0-FgA0Dk4xP_3LLF6xhP0jLr2Ccw" forHTTPHeaderField:@"Authorization"];
    
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
        }
    }] resume];
}

- (BOOL)macOSSupportsAutomaticBrotliDecompression {
    NSString *currentVersion = [[NSProcessInfo processInfo] operatingSystemVersionString];
    NSArray *versionComponents = [currentVersion componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ."]];
    
    if (versionComponents.count < 2) {
        return NO; // Safety check
    }
    
    NSInteger majorVersion = [versionComponents[0] integerValue];
    NSInteger minorVersion = [versionComponents[1] integerValue];
    
    if (majorVersion > 10 || (majorVersion == 10 && minorVersion >= 14)) {
        return YES;
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
    NSLog(@"Wallpapers count: %lu", (unsigned long)self.wallpapersArray.count);
    if (self.wallpapersArray.count > 0) {
        NSDictionary *randomWallpaper = self.wallpapersArray[arc4random_uniform((uint32_t)self.wallpapersArray.count)];
        NSString *smallURLString = randomWallpaper[@"urls"][@"small"];
        NSLog(@"Randomly selected wallpaper URL: %@", smallURLString);
        
        if (smallURLString) {
            self.currentWallpaperData = randomWallpaper;
            [self fetchAndDisplayImageFromURL:[NSURL URLWithString:smallURLString]];
        }
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
                    
                    // Check if location is <null> or is NSNull and replace with Unknown Location
                    if ([location isKindOfClass:[NSNull class]] || [location isEqualToString:@"<null>"]) {
                        location = @"Unknown Location";
                    }
                    
                    NSLog(@"Before setting - Location: %@, Name: %@", location, name);
                    
                    [self.locationTextField setNeedsDisplay:YES];
                    [self.nameTextField setNeedsDisplay:YES];
                    
                    self.locationTextField.stringValue = location ?: @"Unknown Location";
                    self.nameTextField.stringValue = name ?: @"Unknown Name";
                    
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


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end

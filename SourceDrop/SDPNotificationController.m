//
//  SDPNotificationController.m
//  SourceDrop
//
//  Created by Michael Hohl on 15.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPNotificationController.h"
#import "SDPSharingInterface.h"
#import "SDPNotificationPopup.h"
#import "SDPAppDelegate.h"

@implementation SDPNotificationController

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleFinishedSharingCode:) 
                                                     name:SDPSharedCodeNotification 
                                                   object:nil];
    }
    return self;
}


#pragma mark - Public Methods

- (void)copyPasteBinLinkToClipboard:(NSURL *)resultURL
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:[NSArray arrayWithObject:NSURLPboardType] owner:nil];
    [pasteboard writeObjects:[NSArray arrayWithObject:resultURL]];
}

- (void)playSuccessfulDropSound
{
    NSSound *uploadSound = [NSSound soundNamed:@"UploadNotification.wav"];
    [uploadSound setVolume:0.5];
    [uploadSound play];
}

- (void)showStatusBarNotificationForURL:(NSURL *)resultURL
{
    SDPNotificationPopup *controller = [SDPNotificationPopup notificationWithMessage:[resultURL absoluteString] description:nil];
    controller.delegate = self;
    controller.userInfo = resultURL;
    [controller showNotification:self];
}


#pragma mark - Notification Receiver

- (void)handleFinishedSharingCode:(NSNotification *)notification
{ 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Copy PasteBin link to clipboard if configured:
    if ([defaults boolForKey:@"SDPCopyPasteBinLinkToClipboard"]) 
    {
        [self copyPasteBinLinkToClipboard:notification.object];
    }
    
    // Play sound if configured:
    if ([defaults boolForKey:@"SDPPlayUploadSound"]) 
    {
        [self playSuccessfulDropSound];
    }
    
    // SDPUseGrowlForNotification == NO check is for backwards compatibility
    if ([defaults boolForKey:@"SDPUseGrowlForNotification"] == NO)
    {
        [self showStatusBarNotificationForURL:notification.object];
    }
}


#pragma mark - Status Bar Notification

- (void)notificationClicked:(SDPNotificationPopup *)notification
{
    NSURL *pasteURL = notification.userInfo;
    if (pasteURL) {
        [[NSWorkspace sharedWorkspace] openURL:pasteURL];
    }
}

@end

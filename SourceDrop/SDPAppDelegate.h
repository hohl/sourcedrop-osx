//
//  SDPAppDelegate.h
//  SourceDrop
//
//  Created by Michael Hohl on 11.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SDPSharingInterface.h"
#import "SDPStatusItemController.h"
#import "SDPNotificationController.h"
#import "SDPUploadFailureController.h"
#import "MASPreferencesWindowController.h"
#import "PTHotKey.h"
#import "PTHotKeyCenter.h"

#define NSAppDelegate ((SDPAppDelegate *)[NSApplication sharedApplication].delegate)

///
/// Application Delegate used by SourceDrop.
///
@interface SDPAppDelegate : NSObject <NSApplicationDelegate>
{
    MASPreferencesWindowController *_preferencesWindowController;
    id<SDPSharingInterface> _sharingInterface;
}

/// Loads the preset user defaults.
+ (void)setupDefaults;

/// Menu used by the status item.
@property (strong) IBOutlet NSMenu *statusMenu;

/// Preferences Window
@property (strong, readonly) MASPreferencesWindowController *preferencesWindowController;

/// controller for the item displayed in the status bar
@property (strong, readonly) SDPStatusItemController *statusItemController;

// item displayed in the status bar
@property (strong, readonly) NSStatusItem *statusItem;

/// Controller for Growl, Notifications and Sounds
@property (strong) SDPNotificationController *notificationController;

/// Controller for upload failures.
@property (strong) SDPUploadFailureController *uploadFailureController;

/// Holds the sharing interface, which should be used.
@property (strong) id<SDPSharingInterface> sharingInterface;

/// Global hotkey used to copy the stuff.
@property  PTHotKey *globalHotKey;

/// Loads the growl bridge and notifications controller.
- (void)setupNotifications;

/// Loads the sharing interface.
- (void)setupSharingInterface;

/// Show Preferences Window
- (IBAction)openPreferencesWindow:(id)sender;

/// Shows the popover shown on first launch. The popover describes how to use this application.
- (void)showInfoPopover:(id)sender;

/// Will share the content on clipboard.
- (IBAction)shareClipboardContent:(id)sender;

/// Registers the passed global hot key. The old registred hotkey will get dropped.
- (void)registerGlobalHotkey:(PTKeyCombo *)keyCombo;

/// Load sharing interface with name.
- (id<SDPSharingInterface>)sharingInterfaceWithName:(NSString *)interfaceName;

@end

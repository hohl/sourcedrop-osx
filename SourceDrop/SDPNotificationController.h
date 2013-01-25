//
//  SDPNotificationController.h
//  SourceDrop
//
//  Created by Michael Hohl on 15.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDPNotificationPopup.h"

///
/// Controller cares about the Growl Notification and Sound Notification.
///
/// @seealso SDPStatusItem
///
@interface SDPNotificationController : NSObject<SDPStatusBarNotificationDelegate>

/// Copies the PasteBin link to clipboard.
- (void)copyPasteBinLinkToClipboard:(NSURL *)resultURL;

/// Plays the sound for an successful drop/upload.
- (void)playSuccessfulDropSound;

/// Displays a status bar notification which shows the successful upload.
- (void)showStatusBarNotificationForURL:(NSURL *)resultURL;

@end

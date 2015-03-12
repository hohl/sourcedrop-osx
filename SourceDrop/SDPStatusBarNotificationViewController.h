//
//  SDPStatusBarNotificationViewController.h
//  SourceDrop
//
//  Created by Michael Hohl on 21.06.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPNotificationPopup.h"

///
/// SDPNotificationPopup for Mac OS X 10.7+. This implementation uses small popovers below the status bar icon.
///
@interface SDPStatusBarNotificationViewController : SDPNotificationPopup
{
    NSTimeInterval _closingDelay;
    IBOutlet NSTextField *_messageField;
    IBOutlet NSTextField *_descriptionField;
    IBOutlet NSPopover *_popover;
    NSTimer *_closingDelayTimer;
}

/// delay before closing the popover
@property (assign) NSTimeInterval closingDelay;

///
/// It is not recommended to instantiate this class yourself. Use the static creators in the super class instead!
///
/// @deprecated
///
- (id)initWithMessage:(NSString *)message description:(NSString *)descriptionMessage;

@end

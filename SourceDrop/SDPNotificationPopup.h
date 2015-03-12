//
//  SDPStatusBarNotification.h
//  SourceDrop
//
//  Created by Michael Hohl on 21.06.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDPNotificationPopup;

///
/// Delegate protocol for SDPStatusBarNotification.
///
@protocol SDPStatusBarNotificationDelegate <NSObject>

///
/// Called when the notification got clicked. (Does not work with custom views!)
///
/// @param notification which has been clicked
///
- (void)notificationClicked:(SDPNotificationPopup *)notification;

@end

///
/// Helper class which will cause a NSPopover with text to show below the status bar icon.
/// Attention: Popovers do not work with Mac OS X 10.6 but if you use only the static creators you will get a combat class automatically.
///
/// @seealso NSPopover
///
@interface SDPNotificationPopup : NSViewController<NSPopoverDelegate> {
    @protected
    NSString *_message;
    NSString *_descriptionMessage;
}

/// message to be displayed at the popover
@property (copy, readonly) NSString *message;

/// message to be displayed at the popover
@property (copy, readonly) NSString *descriptionMessage;

/// delegate to handle the clicks on the notification
@property (unsafe_unretained) id<SDPStatusBarNotificationDelegate> delegate;

/// additional information not used by the popover itself, could be used to identify popovers
@property (strong) id userInfo;

///
/// Creates a new notification with the passed information. Do not forget to call {@see showNotification}!
///
/// @param message which is displayed as the bold part of the notification
/// @param description which is displayed as the smaller detail of the notification
/// @return controller created for the notification
///
+ (SDPNotificationPopup *)notificationWithMessage:(NSString *)message description:(NSString *)descriptionMessage;

///
/// Displays the popup for the notification.
///
- (IBAction)showNotification:(id)sender;

///
/// Performs a click on the popover.
///
/// @param sender which is performing the click
///
- (IBAction)performClick:(id)sender;

@end

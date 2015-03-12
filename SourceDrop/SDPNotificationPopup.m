//
//  SDPStatusBarNotification.m
//  SourceDrop
//
//  Created by Michael Hohl on 21.06.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPNotificationPopup.h"
#import "SDPStatusBarNotificationViewController.h"

@implementation SDPNotificationPopup

+ (SDPNotificationPopup *)notificationWithMessage:(NSString *)message description:(NSString *)descriptionMessage
{
    Class popoverClass = NSClassFromString(@"NSPopover");
    if (popoverClass != nil)
    {
        return [[SDPStatusBarNotificationViewController alloc] initWithMessage:message description:descriptionMessage];
    }
    else
    {
        NSLog(@"Combat mode for earlier Mac OS X version. Disabling the usage of NSPopover.");
        return nil;
    }
}


- (void)showNotification:(id)sender
{
    // miss implementation!
    // but implementation is done in the subclasses!
}

- (void)performClick:(id)sender
{
    // miss implementation!
    // but implementation is done in the subclasses!
}

@end

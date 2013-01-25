//
//  SDPStatusBarNotificationViewController.m
//  SourceDrop
//
//  Created by Michael Hohl on 21.06.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPStatusBarNotificationViewController.h"
#import "SDPAppDelegate.h"
#import "NSString+Size.h"

@interface SDPStatusBarNotificationViewController ()

@end

@implementation SDPStatusBarNotificationViewController
@synthesize closingDelay = _closingDelay;

- (id)initWithMessage:(NSString *)message description:(NSString *)description
{
    self = [super initWithNibName:@"SDPStatusBarNotification" bundle:nil];
    if (self)
    {
        _message = message;
        _description = description;
        _closingDelay = 5.0; // seconds
    }
    return self;
}


- (void)awakeFromNib
{
    // padding used at the left and right of the frame
    const CGFloat TopPopoverPadding = 5.0;
    const CGFloat BottomPopoverPadding = 5.0;
    const CGFloat LeftPopoverPadding = 7.0;
    const CGFloat RightPopoverPadding = 5.0;
    const CGSize TextPadding = CGSizeMake(3.0, 3.0);
    
    // calculate sizes for the message
    _messageField.stringValue = self.message;
    NSSize messageTextSize = [self.message minimumWidthWithFont:_messageField.font];
    CGFloat popoverMessageWidth = messageTextSize.width;
    messageTextSize = NSMakeSize(messageTextSize.width + TextPadding.width, messageTextSize.height + TextPadding.height);
    [_messageField setFrameSize:messageTextSize];
    
    // calculate sizes for the description
    NSSize descriptionTextSize;
    if (self.description != nil)
    {
        _descriptionField.stringValue = self.description;
        descriptionTextSize = [self.description sizeWithWidth:popoverMessageWidth andFont:_descriptionField.font];
        descriptionTextSize = NSMakeSize(descriptionTextSize.width + TextPadding.width, descriptionTextSize.height + TextPadding.height);
    }
    else
    {
        _descriptionField.stringValue = @"";
        descriptionTextSize = NSMakeSize(messageTextSize.width, 0); 
    }
    [_descriptionField setFrameSize:descriptionTextSize];
    
    // calcualate size for the whole frame
    NSSize frameSize = NSMakeSize(messageTextSize.width + LeftPopoverPadding + RightPopoverPadding, 
                                  descriptionTextSize.height + messageTextSize.height + TopPopoverPadding + BottomPopoverPadding);
    [self.view setFrameSize:frameSize];
    
    // position origin
    [_messageField setFrameOrigin:NSMakePoint(RightPopoverPadding, frameSize.height - (messageTextSize.height + TopPopoverPadding))];
    [_descriptionField setFrameOrigin:NSMakePoint(RightPopoverPadding, BottomPopoverPadding)];

    [super awakeFromNib];
}

- (void)showNotification:(id)sender
{
    // retrieve the view of the status item
    NSView *statusItemView = NSAppDelegate.statusItemController.statusItem.view;
    
    // show popover
    _popover = [[NSPopover alloc] init];
    _popover.appearance = NSPopoverAppearanceHUD;
    _popover.behavior = NSPopoverBehaviorTransient;
    _popover.contentViewController = self;
    _popover.delegate = self;
    [_popover showRelativeToRect:[statusItemView bounds] ofView:statusItemView preferredEdge:NSMaxYEdge];
    
    // delayed closing of the status bar notification
    _closingDelayTimer = [NSTimer scheduledTimerWithTimeInterval:self.closingDelay
                                                          target:_popover
                                                        selector:@selector(performClose:)
                                                        userInfo:nil 
                                                         repeats:NO];
}

- (BOOL)popoverShouldClose:(NSPopover *)popover
{
    [_closingDelayTimer invalidate];
    _closingDelayTimer = nil;
    
    return YES;
}

- (void)performClick:(id)sender
{
    DLog(@"Performed a click on the status bar notification.");
    [self.delegate notificationClicked:self];
    [_popover performClose:sender];
}

@end

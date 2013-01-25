//
//  SDPStatusItemController.m
//  SourceDrop
//
//  Created by Michael Hohl on 12.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPStatusItemController.h"
#import "SDPSharingInterface.h"
#import "SDPAppDelegate.h"

@implementation SDPStatusItemController

- (id)init
{
    NSLog(@"Do not call [SDPStatusItemController init] yourself!");
    return nil;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    if (self = [super init])
    {
        self.statusItem = statusItem;
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleStartedSharingCode:) 
                                                     name:SDPStartedSharingCodeNotification 
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleFinishedSharingCode:) 
                                                     name:SDPSharedCodeNotification 
                                                   object:nil];
        
        [statusItem setViewDelegate:self];
        [statusItem.view registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSStringPboardType, nil]];
    }
    return self;
}

#pragma mark - Sharing Interface Handling

- (void)handleStartedSharingCode:(NSNotification *)notification
{
    // ToDo: Implement the changing of the Status Icon here.
}

- (void)handleFinishedSharingCode:(NSNotification *)notification
{
    // ToDo: Implement the rechanging of the Status Icon here.
}

#pragma mark - Drag Handling

- (NSDragOperation)statusItemView:(BCStatusItemView *)view draggingEntered:(id <NSDraggingInfo>)info
{
	return NSDragOperationCopy;
}

- (void)statusItemView:(BCStatusItemView *)view draggingExited:(id <NSDraggingInfo>)info
{
}

- (BOOL)statusItemView:(BCStatusItemView *)view prepareForDragOperation:(id <NSDraggingInfo>)info
{
	return YES;
}

- (BOOL)statusItemView:(BCStatusItemView *)view performDragOperation:(id <NSDraggingInfo>)info
{
    NSArray *possibleItemClasses = [NSArray arrayWithObjects:NSString.class, NSURL.class, nil];
    NSDictionary *pasteboardOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] 
                                                                  forKey:NSPasteboardURLReadingFileURLsOnlyKey];
    NSArray *pasteboardItems = [[info draggingPasteboard] readObjectsForClasses:possibleItemClasses 
                                                                        options:pasteboardOptions];
    
    if ([pasteboardItems count] == 1 && [[pasteboardItems objectAtIndex:0] isKindOfClass:NSString.class]) 
    {
        [NSAppDelegate.sharingInterface shareCodeString:[pasteboardItems objectAtIndex:0]];
    } 
    else if ([pasteboardItems count] > 0) 
    {
        [NSAppDelegate.sharingInterface shareCodeFiles:pasteboardItems];
    }
	return YES;
}

@end

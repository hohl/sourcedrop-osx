//
//  SDPRecentUploadsController.m
//  SourceDrop
//
//  Created by Michael Hohl on 22.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

// Max. length of upload name.
#define MAX_NAME_LENGTH 45

#import "SDPRecentUploadsController.h"
#import "SDPSharingInterface.h"
#import "NSString+Utils.h"

@implementation SDPRecentUploadsController
@synthesize recentUploads = _recentUploads;
@dynamic maxRecentUploads;

- (id)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _recentUploads = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"SDPRecentUploads"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(handleFinishedSharingCode:) 
                                                     name:SDPSharedCodeNotification 
                                                   object:nil];
    }
    return self;
}

- (NSUInteger)maxRecentUploads
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"SDPMaxRecentUploads"] unsignedIntegerValue];
}

- (void)setMaxRecentUploads:(NSUInteger)maxRecentUploads
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithUnsignedInteger:maxRecentUploads] forKey:@"SDPMaxRecentUploads"];
    [defaults synchronize];
}

- (void)noteNewRecentUpload:(NSURL *)uploadURL title:(NSString *)title
{
    // 1. Insert new recent upload
    NSDictionary *uploadInfo = [NSDictionary dictionaryWithObjectsAndKeys:[uploadURL absoluteString], @"Link",
                                [title stringTrimmedToLength:MAX_NAME_LENGTH appendOnOverlength:@"..."],@"Title", nil];
    [_recentUploads insertObject:uploadInfo atIndex:0];
    
    // 2. Delete oldest recent upload if more than MAX_RECENT_UPLOADS
    while (_recentUploads.count > self.maxRecentUploads) {
        [_recentUploads removeLastObject];
    }
    
    // 3. Save them to UserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_recentUploads forKey:@"SDPRecentUploads"];
    [defaults synchronize];
}


#pragma mark - Snippet Sharing Observer

- (void)handleFinishedSharingCode:(NSNotification *)notification
{
    NSString *uploadName = [notification.userInfo objectForKey:@"UploadName"];
    if (uploadName == nil) 
    {
        uploadName = [notification.object absoluteString];
    }
    [self noteNewRecentUpload:notification.object title:uploadName];
}


#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu
{
    [menu removeAllItems];
    if (_recentUploads.count > 0)
    {
        for (NSUInteger index = 0; index < _recentUploads.count; ++index)
        {
            NSDictionary *userInfo = [_recentUploads objectAtIndex:index];
            if ([userInfo objectForKey:@"Title"] == nil || [userInfo objectForKey:@"Link"] == nil) {
                continue;
            }
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[userInfo objectForKey:@"Title"]
                                                               action:@selector(clickedMenuItem:) 
                                                        keyEquivalent:@""];
            menuItem.target = self;
            menuItem.tag = index;
            [menu addItem:menuItem];
        }
                
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    // Clear Menu Item
    NSMenuItem *clearMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Clear Menu", @"title for the 'Clear Menu' item")
                                                            action:@selector(clearMenu:) 
                                                     keyEquivalent:@""];
    [menu addItem:clearMenuItem];
    
    if (_recentUploads.count > 0) {
        clearMenuItem.target = self;
    }
}

- (void)clearMenu:(id)sender
{
    [_recentUploads removeAllObjects];
}

- (void)clickedMenuItem:(NSMenuItem *)item
{
    NSURL *linkURL = [NSURL URLWithString:[[_recentUploads objectAtIndex:item.tag] objectForKey:@"Link"]];
    [[NSWorkspace sharedWorkspace] openURL:linkURL];
}

@end

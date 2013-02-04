//
//  SDPInfoPreferencesViewController.m
//  SourceDrop
//
//  Created by Michael Hohl on 04.02.13.
//  Copyright (c) 2013 Michael Hohl. All rights reserved.
//

#import "SDPInfoPreferencesViewController.h"

@interface SDPInfoPreferencesViewController ()

@end

@implementation SDPInfoPreferencesViewController

- (id)init
{
    self = [super initWithNibName:@"SDPInfoPreferencesView" bundle:[NSBundle mainBundle]];
    return self;
}

- (NSString *)identifier
{
    return @"InfoPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameInfo];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"About", @"Toolbar item name for the About preference pane");
}

- (NSString *)applicationName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleShortVersionString = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *bundleVersionString = [infoDictionary objectForKey:@"CFBundleVersion"];
    return [NSString stringWithFormat:@"Sourcedrop %@ (Build %@)", bundleShortVersionString, bundleVersionString];
}

- (void)showHomepage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.sourcedrop.net/"]];
}

- (void)showProject:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://github.com/hohl/sourcedrop-osx"]];
}

- (void)showLicense:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://github.com/hohl/sourcedrop-osx/blob/master/LICENSE"]];
}

@end

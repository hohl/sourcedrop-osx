//
//  SDPGeneralPreferencesViewControllerViewController.m
//  SourceDrop
//
//  Created by Michael Hohl on 12.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPGeneralPreferencesViewController.h"
#import "SDPAppDelegate.h"

@implementation SDPGeneralPreferencesViewController

- (id)init
{
    self = [super initWithNibName:@"SDPGeneralPreferencesView" bundle:[NSBundle mainBundle]];
    return self;
}

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
    PTKeyCombo *keyCombo = [PTKeyCombo keyComboWithKeyCode:newKeyCombo.code
                                                 modifiers:SRCocoaToCarbonFlags(newKeyCombo.flags)];
    
    [NSAppDelegate registerGlobalHotkey:keyCombo];
}

@end

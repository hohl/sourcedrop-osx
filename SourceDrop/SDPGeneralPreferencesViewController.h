//
//  SDPGeneralPreferencesViewControllerViewController.h
//  SourceDrop
//
//  Created by Michael Hohl on 12.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SRRecorderControl.h"

/// Adds app as to login tiems.
void SDPAddAppAsLoginItem(void);

/// Removes app from login items.
void SDPRemoveAppFromLoginItem(void);

///
/// Controller used by the 'Generals' page of the Preferences window.
///
@interface SDPGeneralPreferencesViewController : NSViewController

@end

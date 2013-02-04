//
//  SDPInfoPreferencesViewController.h
//  SourceDrop
//
//  Created by Michael Hohl on 04.02.13.
//  Copyright (c) 2013 Michael Hohl. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SDPInfoPreferencesViewController : NSViewController {
    __unsafe_unretained IBOutlet NSTextField *titleTextField;
}

@property (strong, readonly, nonatomic) NSString *applicationName;

- (IBAction)showHomepage:(id)sender;

- (IBAction)showProject:(id)sender;

- (IBAction)showLicense:(id)sender;

@end

//
//  SDPAdvancedViewController.h
//  SourceDrop
//
//  Created by Michael Hohl on 12.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SDPAuthenticationController;

///
/// Controller used by the 'Adcanced' page of the Preferences window.
///
@interface SDPAdvancedPreferencesViewController : NSViewController<NSComboBoxDelegate> {
    __unsafe_unretained IBOutlet NSTextField *usernameTextField;
    __unsafe_unretained IBOutlet NSSecureTextField *passwordTextField;
}

@property (strong) NSArray *sharingServiceNames;

@property (strong) NSString *sharingInterfaceName;

@property (strong) SDPAuthenticationController *authenticationController;

- (IBAction)applyAuthenticationCredentials:(id)sender;

- (NSArray *)retrieveSharingServiceNames;

@end

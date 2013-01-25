//
//  SDPAdvancedViewController.m
//  SourceDrop
//
//  Created by Michael Hohl on 12.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPAdvancedPreferencesViewController.h"
#import "SDPAppDelegate.h"
#import "SDPSharingInterface.h"
#import "SDPAuthenticationController.h"

@implementation SDPAdvancedPreferencesViewController

@dynamic sharingInterfaceName;

- (id)init
{
    self = [super initWithNibName:@"SDPAdvancedPreferencesView" bundle:[NSBundle mainBundle]];
    if (self) 
    {
        self.sharingServiceNames = [self retrieveSharingServiceNames];
        self.authenticationController = [[SDPAuthenticationController alloc] initWithServiceURL:[NSAppDelegate.sharingInterface postURL]];
    }
    
    return self;
}

- (NSString *)identifier
{
    return @"AdvancedPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Advanced", @"Toolbar item name for the Advanced preference pane");
}

- (BOOL)currentInterfaceDoesSupportAuthentication
{
    return [NSAppDelegate.sharingInterface respondsToSelector:@selector(authenticateWithUsername:password:)];
}

- (NSArray *)retrieveSharingServiceNames
{    
    NSString *pathToServiceInterfacesDict = [[NSBundle mainBundle] pathForResource:@"SDPSharingServices" ofType:@"plist"];
    NSDictionary *sharingServices = [NSDictionary dictionaryWithContentsOfFile:pathToServiceInterfacesDict];
    return [sharingServices allKeys];
}

- (NSString *)sharingInterfaceName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"SDPUsedSharingService"];
}

- (void)setSharingInterfaceName:(NSString *)sharingInterfaceName
{
    id<SDPSharingInterface> sharingInterface = [NSAppDelegate sharingInterfaceWithName:sharingInterfaceName];
    if (sharingInterface)
    {
        NSAppDelegate.sharingInterface = sharingInterface;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:sharingInterfaceName forKey:@"SDPUsedSharingService"];
        self.authenticationController = [[SDPAuthenticationController alloc] initWithServiceURL:[sharingInterface postURL]];
        if ([sharingInterface respondsToSelector:@selector(supportsSecureConnection)] 
            && [sharingInterface supportsSecureConnection]) 
        {
            [defaults setBool:YES forKey:@"SDPUseSecureUploads"];
        }
        else 
        {
            [defaults setBool:NO forKey:@"SDPUseSecureUploads"];
        }
        if ([sharingInterface respondsToSelector:@selector(alwaysPrivateUploads)] 
            && [sharingInterface alwaysPrivateUploads]) 
        {
            [defaults setBool:YES forKey:@"SDPUsePrivateUploads"];
        }
        else
        {
            [defaults setBool:NO forKey:@"SDPUsePrivateUploads"];
        }
        [defaults synchronize];
    }
}

- (void)applyAuthenticationCredentials:(id)sender
{
    [NSAppDelegate.sharingInterface authenticateWithUsername:usernameTextField.stringValue 
                                                    password:passwordTextField.stringValue];
}

@end

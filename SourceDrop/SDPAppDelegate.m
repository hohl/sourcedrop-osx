//
//  SDPAppDelegate.m
//  SourceDrop
//
//  Created by Michael Hohl on 11.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPAppDelegate.h"
#import "SDPGeneralPreferencesViewController.h"
#import "SDPAdvancedPreferencesViewController.h"
#import "SDPConfigurableInterface.h"
#import "SDPServicesProvider.h"
#import "SDPNotificationPopup.h"
#import "SDPAuthenticationController.h"
#import "MASPreferencesWindowController.h"

@implementation SDPAppDelegate

@dynamic sharingInterface;
@dynamic preferencesWindowController;

+ (void)initialize
{
    if (self.class == SDPAppDelegate.class) 
    {
        [self setupDefaults];
    }
}



#pragma mark - Application Lifecycle

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self setupNotifications];
    [self setupSharingInterface];
    [self setupGlobalHotkey];
    [NSApp setServicesProvider:[SDPServicesProvider sharedServicesProvider]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"SDPHasLaunchedBefore"] == NO) {
        [self performSelector:@selector(showInfoPopover:) withObject:self afterDelay:0.5];
        [defaults setBool:YES forKey:@"SDPHasLaunchedBefore"];
        [defaults synchronize];
    }
}

- (void)awakeFromNib
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [_statusItem setupView];
    [_statusItem setImage:[NSImage imageNamed:@"SDPStatusBarIcon.png"]];
    [_statusItem setAlternateImage:[NSImage imageNamed:@"SDPStatusBarAlternateIcon.png"]];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:self.statusMenu];
    _statusItemController = [[SDPStatusItemController alloc] initWithStatusItem:_statusItem];
}


#pragma mark - Properties

- (id<SDPSharingInterface>)sharingInterface
{
    if (_sharingInterface == nil) {
        [self setupSharingInterface];
    }
    return _sharingInterface;
}

- (void)setSharingInterface:(id<SDPSharingInterface>)sharingInterface
{
    _sharingInterface = sharingInterface;
}


#pragma mark - Setups

+ (void)setupDefaults
{    
    NSString *userDefaultsValuesPath = [[NSBundle mainBundle] pathForResource:@"SDPUserDefaults"
                                                                       ofType:@"plist"];
    
    NSDictionary *userDefaultsValuesDict = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];
}

- (void)setupNotifications
{
    if (!_notificationController) {
        _notificationController = [[SDPNotificationController alloc] init];
    }
    if (!_uploadFailureController) {
        _uploadFailureController = [[SDPUploadFailureController alloc] init];
    }
}

- (void)setupSharingInterface
{
    static const NSString *DefaultInterfaceName = @"SourceDrop";
    static const NSString *SharingServiceKey = @"SDPUsedSharingService";
    
    if (_sharingInterface == nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.sharingInterface = [self sharingInterfaceWithName:[defaults objectForKey:(NSString *)SharingServiceKey]];
        
        if (_sharingInterface == nil) {
            [defaults setObject:(NSString *)DefaultInterfaceName forKey:(NSString *)SharingServiceKey];
            [defaults synchronize];
            self.sharingInterface = [self sharingInterfaceWithName:(NSString *)DefaultInterfaceName];
        }
    }
}

- (void)setupGlobalHotkey
{
    if (!_globalHotKey) {
        NSDictionary *globalHotkey = [[NSUserDefaults standardUserDefaults] objectForKey:@"SDPGlobalHotkey"];
        NSInteger keyCode = [[globalHotkey objectForKey:@"keyCode"] integerValue];
        NSUInteger modifiers = [[globalHotkey objectForKey:@"modifierFlags"] unsignedIntegerValue];
        [self registerGlobalHotkey:[PTKeyCombo keyComboWithKeyCode:keyCode
                                                         modifiers:SRCocoaToCarbonFlags(modifiers)]];
    }
}


#pragma mark - Info Popover

- (void)showInfoPopover:(id)sender
{
    SDPNotificationPopup *controller = [SDPNotificationPopup notificationWithMessage:@"SourceDrop is ready to use!" description:@"Drop a selection or a file on this icon in the menu bar."];
    [controller showNotification:sender];
}


#pragma mark - Preferences Window

- (MASPreferencesWindowController *)preferencesWindowController 
{
    if (_preferencesWindowController == nil) {
        NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:2];
        [viewControllers addObject:[[SDPGeneralPreferencesViewController alloc] init]];
        [viewControllers addObject:[[SDPAdvancedPreferencesViewController alloc] init]];

        NSString *windowTitle = NSLocalizedString(@"Preferences", @"Title of the Preferences Window");
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:viewControllers title:windowTitle];
    }
    return _preferencesWindowController;
}

- (void)openPreferencesWindow:(id)sender
{
    [self.preferencesWindowController selectControllerAtIndex:0];
    [self.preferencesWindowController showWindow:nil];
    [self.preferencesWindowController.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}


#pragma mark - Sharing Interface

- (void)shareClipboardContent:(id)sender
{
    NSString *errorMessage = nil;
    [[SDPServicesProvider sharedServicesProvider] shareSnippet:[NSPasteboard generalPasteboard] userData:nil error:&errorMessage];
    if (errorMessage) {
        NSLog(@"Sharing failed: %@", errorMessage);
    }
}

- (id<SDPSharingInterface>)sharingInterfaceWithName:(NSString *)interfaceName
{
    NSString *pathToServiceInterfacesDict = [[NSBundle mainBundle] pathForResource:@"SDPSharingServices" ofType:@"plist"];
    NSDictionary *sharingServices = [NSDictionary dictionaryWithContentsOfFile:pathToServiceInterfacesDict];
    Class interfaceClass = NSClassFromString([[sharingServices objectForKey:interfaceName] objectForKey:@"ClassName"]);
    
    id<SDPSharingInterface> sharingInterface = [[interfaceClass alloc] init];
    sharingInterface.sharingInterfaceName = interfaceName;
    if ([sharingInterface respondsToSelector:@selector(properties)])
    {
        [[sharingInterface properties] addEntriesFromDictionary:[[sharingServices objectForKey:interfaceName] objectForKey:@"Properties"]];
    }
    if ([sharingInterface respondsToSelector:@selector(authenticateWithUsername:password:)])
    {
        SDPAuthenticationController *authenticationController = [[SDPAuthenticationController alloc] initWithServiceURL:[sharingInterface postURL]];
        NSString *username = authenticationController.username;
        NSString *password = authenticationController.password;
        if (authenticationController.useAuthentication && username && password) {
            [sharingInterface authenticateWithUsername:username password:password];
        }
    }
    
    return sharingInterface;
}


#pragma mark - Global Hotkey

- (void)registerGlobalHotkey:(PTKeyCombo *)keyCombo
{
    // Unregister old global hotkeys first
	if (_globalHotKey != nil)
	{
		[[PTHotKeyCenter sharedCenter] unregisterHotKey:_globalHotKey];
		_globalHotKey = nil;
	}
    
    // Register new global hotkey
	_globalHotKey = [[PTHotKey alloc] initWithIdentifier:@"SDPGlobalHotkey"
                                                keyCombo:keyCombo];
	
	[_globalHotKey setTarget:self];
	[_globalHotKey setAction:@selector(shareClipboardContent:)];
	
	[[PTHotKeyCenter sharedCenter] registerHotKey:_globalHotKey];
}


@end

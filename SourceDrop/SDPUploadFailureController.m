//
//  SDPUploadFailureController.m
//  SourceDrop
//
//  Created by Michael Hohl on 22.07.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPUploadFailureController.h"
#import "SDPSharingInterface.h"
#import "SDPAppDelegate.h"
#import "ASIFormDataRequest.h"

@implementation SDPUploadFailureController

@synthesize detailedLogTextField = _detailedLogTextField;
@synthesize detailedLogView = _detailedLogView;
@synthesize sendLogToDeveloper = _sendLogToDeveloper;

- (id)init
{
    if (self = [super init])
    {
#ifndef DEBUG
        // let release builds to error reporting per default
        self.sendLogToDeveloper = YES;
#endif
        
        [NSBundle loadNibNamed:@"SDPDetailedLogView" owner:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleFailedSharingCode:)
                                                     name:SDPCodeSharingFailedNotification
                                                   object:nil];
    }
    return self;
}



#pragma mark - Notification Handling

- (void)handleFailedSharingCode:(NSNotification *)notification
{
    // ToDo: Implement the rechanging of the Status Icon here.
    NSString *SharingService = [notification.userInfo objectForKey:@"SharingService"];
    SharingService = SharingService ? SharingService : @"Your service provider";
    NSString *ChangeService = [NSString stringWithFormat:NSLocalizedString(@"Maybe you want to change your sharing service in the preferences?", nil), SharingService];
    
    NSAlert *failureAlert = [[NSAlert alloc] init];
    failureAlert.messageText = NSLocalizedString(@"Failed uploading source code!", nil);
    if ([notification.object isEqualToString:SDPFailureReasonMaximumPasteSizeExceeded])
    {
        failureAlert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"%@ rejected it because it is too large.", nil), SharingService];
    }
    else if ([notification.object isEqualToString:SDPFailureReasonMaximumUploadsPerDayExceeded])
    {
        failureAlert.informativeText = [NSString stringWithFormat:@"%@ %@", [NSString stringWithFormat:NSLocalizedString(@"%@ rejected it because you already uploaded to much files today.", nil), SharingService], ChangeService];
    }
    else if ([notification.object isEqualToString:SDPFailureReasonTooMuchLogins])
    {
        failureAlert.informativeText = [NSString stringWithFormat:@"%@ %@", [NSString stringWithFormat:NSLocalizedString(@"%@ rejected it because of too much failed login attempts.", nil), SharingService], ChangeService];
    }
    else if ([notification.object isEqualToString:SDPFailureReasonInvalidAuthentication])
    {
        failureAlert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"%@ rejected your authentication details.", nil), SharingService];
    }
    else if ([notification.object isEqualToString:SDPFailureReasonCanNotReachServer])
    {
        failureAlert.informativeText = [NSString stringWithFormat:@"%@ %@", [NSString stringWithFormat:NSLocalizedString(@"Can not reach the upload server of %@.", nil), SharingService], ChangeService];
    }
    else
    {
        failureAlert.informativeText = [NSString stringWithFormat:NSLocalizedString(@"%@ rejected it with unknown reason.", nil), SharingService];
        self.detailedLogTextField.stringValue = [notification.userInfo description];
        failureAlert.accessoryView = _detailedLogView;
    }
    failureAlert.alertStyle = NSWarningAlertStyle;
    [failureAlert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    [failureAlert addButtonWithTitle:NSLocalizedString(@"Preferences", nil)];
    if ([failureAlert runModal] == NSAlertSecondButtonReturn)
    {
        [NSAppDelegate openPreferencesWindow:notification];
    }
    if (self.sendLogToDeveloper)
    {
        [self sendLogToDeveloper:nil];
    }
}


#pragma mark - Error Reporting

- (void)sendLogToDeveloper:(id)sender
{
    NSURL *contactURL = [NSURL URLWithString:@"http://www.sourcedrop.net/contact"];
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:contactURL];
    [request setPostValue:[NSString stringWithFormat:@"SourceDrop for Mac OS X, Version %@", bundleVersion] forKey:@"name"];
    [request setPostValue:@"support@sourcedrop.net" forKey:@"email"];
    [request setPostValue:@"http://www.sourcedrop.net/mac" forKey:@"website"];
    [request setPostValue:self.detailedLogTextField.stringValue forKey:@"message"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Error log report response: %@", request.responseString);
    if (request.responseStatusCode == 200)
    {
        NSLog(@"Successfully reported error log to the developers of SourceDrop.");
    }
    else
    {
        NSLog(@"Invalid server response when reporting the error log. Something is working wrong with the reporting servers. Try to manually get in contact with: support@sourcedrop.net");
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Can't report the failure of the upload because the developers servers are not reachable. We are sorry for that issue! Try to manually get in contact with: support@sourcedrop.net");
}


@end

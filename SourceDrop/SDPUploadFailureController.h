//
//  SDPUploadFailureController.h
//  SourceDrop
//
//  Created by Michael Hohl on 22.07.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>

///
/// Controller is used to handle upload failures and display an error message to user.
///
/// @seealso SDPNotificationController
///
@interface SDPUploadFailureController : NSObject<ASIHTTPRequestDelegate>
{
    NSView *_detailedLogView;
    NSTextField *_detailedLogTextField;
    BOOL _sendLogToDeveloper;
}

///
/// View is used as accessory view for the NSAlert to display a more detailed error log.
///
@property (strong) IBOutlet NSView *detailedLogView;

///
/// TextField is used to hold the log content.
///
@property (strong) IBOutlet NSTextField *detailedLogTextField;

///
/// CheckBox to let the user choose if he want to send the log to the developer.
///
@property (assign) BOOL sendLogToDeveloper;

///
/// Actions is bound to the 'Send to Developer' button and should send a new mail containing the content of the log to support@sourcedrop.net.
///
- (IBAction)sendLogToDeveloper:(id)sender;

@end

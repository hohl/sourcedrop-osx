//
//  SDPPasteAPI.h
//  SourceDrop
//
//  Created by Michael Hohl on 11.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>

///
/// Notification is called when starting the upload. This method is only called once.
///
static NSString *SDPStartedSharingCodeNotification = @"SDPStartedSharingCodeNotification";

///
/// Notification is called when code is beeing uploaded. Could get called multiple time...
///
static NSString *SDPCodeSharingFailedNotification = @"SDPCodeSharingFailedNotification";

///
/// Notification is called when code is completley uploaded. UserInfo will contain the link to the shared code.
///
static NSString *SDPSharedCodeNotification = @"SDPSharedCodeNotification";

///
/// Notification is called when the authentication failed.
///
static NSString *SDPAuthenticationFailed = @"SDPFinishedNotification";

///
/// Notification is called when the authentication was successful.
///
static NSString *SDPAuthenticated = @"SDPAuthenticated";


/// Possible reasons for a failure. (Will be the object of the failure notification)
static NSString *SDPFailureReasonMaximumUploadsPerDayExceeded = @"SDPFailureReasonMaximumUploadsPerDayExceeded";
static NSString *SDPFailureReasonMaximumPasteSizeExceeded = @"SDPFailureReasonMaximumPasteSizeExceeded";
static NSString *SDPFailureReasonCanNotReachServer = @"SDPFailureReasonCanNotReachServer";
static NSString *SDPFailureReasonInvalidAuthentication = @"SDPFailureInvalidAuthentication";
static NSString *SDPFailureReasonTooMuchLogins = @"SDPFailureReasonTooMuchLogins";
static NSString *SDPFailureReasonUnknown = @"SDPFailureReasonUnknown";

///
/// Interface used by all sharing APIs.
///
/// @seealso SDPPasteBinInterface
///
@protocol SDPSharingInterface <NSObject>

///
/// Returns the human readable name of the service used. Like 'Pastie.org' or 'PasteBin'.
///
/// @return the name as NSString.
///
@property (retain, nonatomic) NSString *sharingInterfaceName;

///
/// This will upload source code for sharing.
///
- (void)shareCodeString:(NSString *)sourceString;

///
/// This will upload source files for sharing.
///
- (void)shareCodeFiles:(NSArray *)sourceFiles;

/// When available, then the 'Properties' section of the Plist will be loaded into this property.
@property (readonly, retain) NSMutableDictionary *properties;

/// @return YES if the uploads will be private.
@property (readonly, assign) BOOL privateUploads;

/// @return YES if syntax highlighting.
@property (readonly, assign) BOOL useSyntaxHighlighting;

///
/// Property returns the URL for the uploads. The property will decide itself if 'Secure Post URL' or 'Post URL'
/// should be used.
///
/// @return URL to the post API
///
@property (readonly, nonatomic) NSURL *postURL;

///
/// Returns YES, if the service supports HTTPS.
///
@property (readonly, nonatomic) BOOL supportsSecureConnection;

///
/// Returns YES, if there isn't anything other possible than private uploads.
/// This property is used to gray out 'Private Uploads' in menus.
///
@property (readonly, nonatomic) BOOL alwaysPrivateUploads;

///
/// Returns YES, if the service supports authentication.
///
@property (readonly, nonatomic) BOOL supportsAuthentication;

///
/// Optional method, which is used to authenticate at the sharing interface.
/// Don't forget to set supportsAuthentication to YES if you want to allow users to login with their credentials.
///
@optional
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;

@end

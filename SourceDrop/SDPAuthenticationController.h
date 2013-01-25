//
//  SDPAuthenticationController.h
//  SourceDrop
//
//  Created by Michael Hohl on 24.05.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>

///
/// Controller used to handle the stored username and password. 
///
@interface SDPAuthenticationController : NSObject
{
    NSURL *_serviceURL;
    NSString *_serviceID;
    BOOL _useAuthentication;
    NSString *_username;
    NSString *_password;
}

///
/// Inits a controller for the passed service url.
/// @discussion Do not use [SDPAuthenticationController init]. It is valid to use but will not have any usage.
///
/// @param serviceURL the postURL of the sharing interface
/// @return the created controller
///
- (id)initWithServiceURL:(NSURL *)serviceURL;

@property (readonly) NSURL *serviceURL;

@property (assign) BOOL useAuthentication;

@property (strong) NSString *username;

@property (strong) NSString *password;

@end

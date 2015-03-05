//
//  SDPGistInterface.m
//  SourceDrop
//
//  Created by Michael Hohl on 11.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPGistInterface.h"
#import "ASIFormDataRequest.h"
#import "NSString+Utils.h"

static NSString *SDPExpectedFailureResponseForTooMuchLogins = @"Max number of login attempt exceeded";

@implementation SDPGistInterface

- (id)init
{
    self = [super init];
    if (self) {
        _encoding = NSUTF8StringEncoding;
    }
    return self;
}



#pragma mark - Sharing Interface Implementation

- (void)shareCodeString:(NSString *)sourceString
{
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [postDict setObject:(self.privateUploads ? @"false" : @"true") forKey:@"public"];

    NSDictionary *file = [NSDictionary dictionaryWithObject:sourceString forKey:@"content"];
    NSDictionary *files = [NSDictionary dictionaryWithObject:file forKey:@"content"];
    [postDict setObject:files forKey:@"files"];
        
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:self.notificationUserInfo];
    [userInfo setObject:sourceString forKey:@"UploadName"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:self.postURL];
    [request appendPostData:[[postDict JSONRepresentation] dataUsingEncoding:_encoding]];
    if (_username && _password) {
        [request setUsername:_username];
        [request setPassword:_password];
        [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    }
    [request setUserInfo:userInfo];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)shareCodeFiles:(NSArray *)sourceFiles
{
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithCapacity:3];
    [postDict setObject:(self.privateUploads ? @"false" : @"true") forKey:@"public"];
    NSMutableDictionary *files = [NSMutableDictionary dictionaryWithCapacity:sourceFiles.count];
    [postDict setObject:files forKey:@"files"];
    for (NSURL *sourceFile in sourceFiles) {
        NSError *error = nil;
        NSString *fileContent = [NSString stringWithContentsOfURL:sourceFile encoding:NSUTF8StringEncoding error:&error];
        if (fileContent != nil && error == nil) {
            NSDictionary *file = [NSDictionary dictionaryWithObject:fileContent forKey:@"content"];
            [files setObject:file forKey:[sourceFile lastPathComponent]];
        }
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:self.notificationUserInfo];
    [userInfo setObject:[NSString stringWithContentOfArray:sourceFiles seperatorString:@", "] forKey:@"UploadName"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:self.postURL];
    [request appendPostData:[[postDict JSONRepresentation] dataUsingEncoding:_encoding]];
    if (_username && _password) {
        [request setUsername:_username];
        [request setPassword:_password];
        [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
    }
    [request setUserInfo:userInfo];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password
{
    _username = username;
    _password = password;
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPStartedSharingCodeNotification 
                                                        object:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSURL *responseURL = [NSURL URLWithString:[[request.responseString JSONValue] objectForKey:@"html_url"]];
    if ([request responseStatusCode] >= 200 && [request responseStatusCode] < 300 && responseURL != nil) 
    {
        DLog(@"Shared code successfully, Link: %@", responseURL);
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPSharedCodeNotification 
                                                            object:responseURL
                                                          userInfo:request.userInfo];
    }
    else 
    {
        NSLog(@"SourceDrop received invalid response from GIST api: %@", request.responseString);
        
        if ([[[request.responseString JSONValue] objectForKey:@"message"] isEqualToString:SDPExpectedFailureResponseForTooMuchLogins]) 
        {
            DLog(@"Code sharing failed due to too much failed logins.");
            [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                                object:SDPFailureReasonTooMuchLogins
                                                              userInfo:request.userInfo];
        } 
        else 
        {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:request.userInfo];
            [userInfo setObject:[NSNumber numberWithInt:request.responseStatusCode] forKey:@"StatusCode"];
            [userInfo setObject:request.responseStatusMessage forKey:@"StatusMessage"];
            [userInfo setObject:request.responseString forKey:@"Response"];
            
            DLog(@"Code sharing failed due to invalid API response: '%@'", request.responseString);
            [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                                object:SDPFailureReasonUnknown
                                                              userInfo:userInfo];
        }
       
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.responseStatusCode == 401) 
    {
        DLog(@"Code sharing failed due to invalid authentication.");
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                            object:SDPFailureReasonInvalidAuthentication
                                                          userInfo:request.userInfo];
    }
    else 
    {
        DLog(@"Code sharing failed due to network failure.");
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                            object:SDPFailureReasonCanNotReachServer
                                                          userInfo:request.userInfo];
    }
}


@end

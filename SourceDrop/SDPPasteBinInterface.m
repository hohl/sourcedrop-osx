//
//  SDPPasteBinInterface.m
//  SourceDrop
//
//  Created by Michael Hohl on 11.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPPasteBinInterface.h"
#import "ASIFormDataRequest.h"

// Possible response strings:
static NSString *SDPPasteBinResponseMaximumPasteSizeExceeded = @"Bad API request, maximum paste file size exceeded";
static NSString *SDPPasteBinResponseMaximumUnlistedPastes = @"Bad API request, maximum number of 25 unlisted pastes for your free account";
static NSString *SDPPasteBinResponseMaximumPastesPerDay = @"Post limit, maximum pastes per 24h reached";

// Network request tags
enum {
    SDPNetworkRequestPasteTag = 1,
    SDPNetworkRequestAuthenticationTag
};


@implementation SDPPasteBinInterface



#pragma mark - Properties

- (NSString *)apiKey
{
    return [self.properties objectForKey:@"API Key"];
}

- (NSURL *)authenticationURL
{
    return [NSURL URLWithString:[self.properties objectForKey:@"Authentication URL"]];
}


#pragma mark - Sharing Interface Implementation

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:self.authenticationURL];
    [request setPostValue:self.apiKey forKey:@"api_dev_key"];
    [request setPostValue:username forKey:@"api_user_name"];
    [request setPostValue:password forKey:@"api_user_password"];
    [request setDelegate:self];
    [request setTag:SDPNetworkRequestAuthenticationTag];
    [request startAsynchronous];
}

- (void)shareCodeString:(NSString *)sourceString
{
    if (_authenticationFailed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                            object:SDPFailureReasonInvalidAuthentication
                                                          userInfo:self.notificationUserInfo];
    }
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:self.postURL];
    [request setPostValue:self.apiKey forKey:@"api_dev_key"];
    [request setPostValue:sourceString forKey:@"api_paste_code"];
    [request setPostValue:@"paste" forKey:@"api_option"];
    [request setPostValue:(self.privateUploads ? @"1" : @"0") forKey:@"api_paste_private"];
    if (_authenticationToken) {
        [request setPostValue:_authenticationToken forKey:@"api_user_key"];
    }
    [request setDelegate:self];
    [request setTag:SDPNetworkRequestPasteTag];
    [request startAsynchronous];
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    if (request.tag == SDPNetworkRequestPasteTag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPStartedSharingCodeNotification 
                                                            object:request
                                                          userInfo:self.notificationUserInfo];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = request.responseString;
    if (request.tag == SDPNetworkRequestPasteTag) 
    {
        if (![responseString hasPrefix:@"http://"]) 
        {
            DLog(@"Code sharing failed due to invalid API response: '%@'", responseString);
            if ([responseString isEqualToString:SDPPasteBinResponseMaximumPasteSizeExceeded]) 
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                                    object:SDPFailureReasonMaximumPasteSizeExceeded
                                                                  userInfo:self.notificationUserInfo];
            }
            else if ([responseString isEqualToString:SDPPasteBinResponseMaximumUnlistedPastes] || 
                     [responseString isEqualToString:SDPPasteBinResponseMaximumPastesPerDay])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                                    object:SDPFailureReasonMaximumUploadsPerDayExceeded
                                                                  userInfo:self.notificationUserInfo];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                                    object:SDPFailureReasonUnknown
                                                                  userInfo:self.notificationUserInfo];
            }
        }
        else 
        {
            DLog(@"Shared code successfully, Link: %@", responseString);
            [[NSNotificationCenter defaultCenter] postNotificationName:SDPSharedCodeNotification 
                                                                object:[NSURL URLWithString:responseString]
                                                              userInfo:self.notificationUserInfo];
        }
    }
    else if (request.tag == SDPNetworkRequestAuthenticationTag)
    {
        DLog(@"Authentication result: %@", responseString);
        NSString *const kBadAPIRequstRespons = @"Bad API request,";
        if ([[responseString substringToIndex:[kBadAPIRequstRespons length]] isEqualToString:kBadAPIRequstRespons])
        {
            _authenticationFailed = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:SDPAuthenticationFailedNotification
                                                                object:self
                                                              userInfo:self.notificationUserInfo];
        }
        else
        {
            _authenticationFailed = NO;
            _authenticationToken = responseString;
            [[NSNotificationCenter defaultCenter] postNotificationName:SDPSuccessfullyAuthenticatedNotification
                                                                object:self
                                                              userInfo:self.notificationUserInfo];
        }
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:self.notificationUserInfo];
    [userInfo setObject:[NSNumber numberWithInt:request.responseStatusCode] forKey:@"StatusCode"];
    [userInfo setObject:request.responseStatusMessage forKey:@"StatusMessage"];
    
    if (request.tag == SDPNetworkRequestPasteTag) 
    {
        DLog(@"Code sharing failed due to network failure.");
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                            object:SDPFailureReasonCanNotReachServer
                                                          userInfo:userInfo];
    }
    else if (request.tag == SDPNetworkRequestAuthenticationTag)
    {
        DLog(@"Authentication failed due to network failure.");
        _authenticationFailed = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPAuthenticationFailedNotification 
                                                            object:self
                                                          userInfo:userInfo];
    }
}

@end

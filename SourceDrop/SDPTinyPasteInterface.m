//
//  SDPTinyPasteInterface.m
//  SourceDrop
//
//  Created by Michael Hohl on 12.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPTinyPasteInterface.h"
#import "ASIFormDataRequest.h"
#import "NSString+MD5.h"

@implementation SDPTinyPasteInterface



#pragma mark - Properties

- (NSURL *)URLForPasteWithID:(NSString *)pasteID
{
    NSString *pasteUrlTemplate = [self.properties objectForKey:@"Get URL"];
    return [NSURL URLWithString:[NSString stringWithFormat:pasteUrlTemplate, pasteID]];
}


#pragma mark - Sharing Interface Implementation

- (void)shareCodeString:(NSString *)sourceString
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:self.postURL];
    [request setPostValue:sourceString forKey:@"paste"];
    [request setPostValue:@"1" forKey:@"is_code"];
    [request setPostValue:(self.privateUploads ? @"1" : @"0") forKey:@"is_private"];
    if (_authenticationToken) {
        [request setPostValue:_authenticationToken forKey:@"authenticate"];
    }
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)shareCodeFiles:(NSArray *)sourceFiles
{
    NSError *ioError = nil;
    NSMutableString *sourceString = [NSMutableString string];
    for (NSObject *sourceFile in sourceFiles) {
        if ([sourceFile isKindOfClass:NSURL.class] && [(NSURL *)sourceFile isFileURL]) {
            //[sourceString appendFormat:@"## %@\n", sourceString];
            [sourceString appendString:[NSString stringWithContentsOfURL:(NSURL *)sourceFile encoding:NSUTF8StringEncoding error:&ioError]];
            [sourceString appendString:@"\n\n"];
        } else {
            NSLog(@"URL is not valid local file.");
        }
        if (ioError) {
            NSLog(@"Errors occured during I/O. Ignored...");
        }
    }
    if (sourceString.length > 0) {
        [self shareCodeString:sourceString];
    }
}

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password
{
    _authenticationToken = [NSString stringWithFormat:@"%@:%@", username, password.md5];
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPStartedSharingCodeNotification 
                                                        object:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *responseResult = [[request.responseString JSONValue] objectForKey:@"result"];
    if ([responseResult objectForKey:@"response"]) 
    {
        NSString *pasteId = [responseResult objectForKey:@"response"];
        NSURL *responseURL = [self URLForPasteWithID:pasteId];
        DLog(@"Shared code successfully, Link: %@", responseURL);
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPSharedCodeNotification 
                                                            object:responseURL
                                                          userInfo:self.notificationUserInfo];
    }
    else 
    {
        NSString *failureString = [responseResult objectForKey:@"error"];
        DLog(@"Code sharing failed due to invalid API response: '%@'", failureString);
        if ([failureString isEqualToString:@"auth_invalid"]) 
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                                object:SDPFailureReasonInvalidAuthentication
                                                              userInfo:self.notificationUserInfo];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                                object:SDPFailureReasonUnknown
                                                              userInfo:self.notificationUserInfo];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    DLog(@"Code sharing failed due to network failure.");
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                        object:SDPFailureReasonCanNotReachServer
                                                      userInfo:self.notificationUserInfo];
}


@end

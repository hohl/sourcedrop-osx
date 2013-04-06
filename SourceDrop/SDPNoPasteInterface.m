//
//  SDPNoPasteInterface.m
//  Extension to SourceDrop
//
//  Created by Andrea Curtoni on 2013.04.06.
//  Copyright (c) 2013 Andrea Curtoni. All rights reserved.
//

#import "SDPNoPasteInterface.h"
#import "ASIFormDataRequest.h"
#import "NSString+MD5.h"

@implementation SDPNoPasteInterface



#pragma mark - Properties

#pragma mark - Sharing Interface Implementation

- (void)shareCodeString:(NSString *)sourceString
{
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:self.postURL];
  
    [request setPostValue:@"1" forKey:@"insert"];
    [request setPostValue:@"Pasted via SourceDrop" forKey:@"description"];
    [request setPostValue:sourceString forKey:@"code"];
    [request setPostValue:[self.properties objectForKey:@"Name"] forKey:@"name"];
    [request setPostValue:[self.properties objectForKey:@"Expires"] forKey:@"expires"];
    [request setPostValue:[self.properties objectForKey:@"Language"] forKey:@"language"];
  
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

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPStartedSharingCodeNotification 
                                                        object:self];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSString *regexPattern = [self.properties objectForKey:@"Response URL Regex"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:NULL];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:response
                                                         options:0
                                                           range:NSMakeRange(0, [response length])];
  
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
      NSURL *responseURL = [NSURL URLWithString:[response substringWithRange:rangeOfFirstMatch]];
      DLog(@"Shared code successfully, Link: %@", responseURL);
      [[NSNotificationCenter defaultCenter] postNotificationName:SDPSharedCodeNotification
                                                          object:responseURL
                                                        userInfo:self.notificationUserInfo];
    }
    else
    {
      NSString *failureString = response;
      DLog(@"Code sharing failed due to invalid API response: '%@'", failureString);
      [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification
                                                          object:SDPFailureReasonUnknown
                                                        userInfo:self.notificationUserInfo];
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

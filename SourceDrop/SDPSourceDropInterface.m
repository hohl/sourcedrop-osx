//
//  SDPSourceDropInterface.m
//  SourceDrop
//
//  Created by Michael Hohl on 04.05.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPSourceDropInterface.h"
#import "NSString+Utils.h"

@implementation SDPSourceDropInterface

#pragma mark - Properties

- (unsigned long long)postContentSizeLimit
{
    return [[self.properties objectForKey:@"Content Size Limit"] unsignedLongLongValue];
}

#pragma mark - Sharing Interface Implementation

- (void)shareCodes:(NSArray *)sharingContents
{
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:sharingContents.count];
    for (NSDictionary *sharingContent in sharingContents) {
        [titles addObject:[sharingContent objectForKey:@"title"]];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:self.notificationUserInfo];
    [userInfo setObject:[NSString stringWithContentOfArray:titles seperatorString:@", "] forKey:@"UploadName"];
    
    NSString *jsonRepresentation = sharingContents.JSONRepresentation;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:self.postURL];
    [request setPostValue:jsonRepresentation forKey:@"data"];
    [request addRequestHeader:@"Accept" value:@"text/plain"];
    [request setUserInfo:userInfo];
    [request setDelegate:self];
    
    DLog(@"Uploading file with %lu kB, Limit: %llu kB", jsonRepresentation.length / 1024, self.postContentSizeLimit / 1023);
    if (jsonRepresentation.length <= self.postContentSizeLimit) 
    {
        [request startAsynchronous];
    }
    else 
    {
        DLog(@"Code sharing failed due to much POST data.");
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                            object:SDPFailureReasonMaximumPasteSizeExceeded
                                                          userInfo:request.userInfo];
    }
    
    
}

- (void)shareCodeString:(NSString *)sourceString
{
    NSDictionary *sharingContent = [NSDictionary dictionaryWithObjectsAndKeys:[sourceString stringTrimmedToLength:42 appendOnOverlength:@"..."], @"title", sourceString, @"content", nil];
    [self shareCodes:[NSArray arrayWithObject:sharingContent]];
}

- (void)shareCodeFiles:(NSArray *)sourceFiles
{
    NSMutableArray *sharingContents = [NSMutableArray arrayWithCapacity:sourceFiles.count];
    for (NSObject *sourceFile in sourceFiles)
    {
        NSError *ioError = nil;
        if ([sourceFile isKindOfClass:NSURL.class] && [(NSURL *)sourceFile isFileURL]) 
        {
            NSString *content = [NSString stringWithContentsOfURL:(NSURL *)sourceFile encoding:NSUTF8StringEncoding error:&ioError];
            if (content.length > 0) {
                NSDictionary *sharingContent = [NSDictionary dictionaryWithObjectsAndKeys:[[(NSURL *)sourceFile path] lastPathComponent], @"title", 
                                                content, @"content", nil];
                [sharingContents addObject:sharingContent];
            }
        }
        else 
        {
            NSLog(@"URL is not valid local file.");
        }
        if (ioError)
        {
            NSLog(@"An error occured during reading the file. (Description: %@)", ioError.description);
        }
    }
    
    if (sharingContents.count > 0)
    {
        [self shareCodes:sharingContents];
    }
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SDPStartedSharingCodeNotification 
                                                        object:self
                                                      userInfo:request.userInfo];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.responseStatusCode == 200 && [request.url isEqual:request.originalURL] == NO)
    {
        DLog(@"Shared code successfully, Link: %@", request.url);
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPSharedCodeNotification 
                                                            object:request.url
                                                          userInfo:request.userInfo];
    }
    else if (request.responseStatusCode == 400)
    {
        NSLog(@"Code sharing failed due to 400 response.");
        NSLog(@"Server response: %@", request.responseString);
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                            object:SDPFailureReasonMaximumPasteSizeExceeded
                                                          userInfo:request.userInfo];
    }
    else
    {
        NSLog(@"Code sharing failed due to server side failure.");
        NSLog(@"Server response: %@", request.responseString);
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                            object:SDPFailureReasonUnknown
                                                          userInfo:request.userInfo];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:request.userInfo];
    [userInfo setObject:[NSNumber numberWithInt:request.responseStatusCode] forKey:@"StatusCode"];
    [userInfo setObject:(request.responseStatusMessage ? request.responseStatusMessage : @"") forKey:@"StatusMessage"];
    
    if (request.responseStatusCode == 500) {
        NSLog(@"Code sharing failed due to server side failure.");
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                            object:SDPFailureReasonUnknown
                                                          userInfo:userInfo];
    }
    else
    {
        NSLog(@"Code sharing failed due to network failure.");
        [[NSNotificationCenter defaultCenter] postNotificationName:SDPCodeSharingFailedNotification 
                                                            object:SDPFailureReasonCanNotReachServer
                                                          userInfo:userInfo];
    }
}

@end

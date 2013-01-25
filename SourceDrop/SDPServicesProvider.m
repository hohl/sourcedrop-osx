//
//  SDPServiceProvider.m
//  SourceDrop
//
//  Created by Michael Hohl on 06.05.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPAppDelegate.h"
#import "SDPServicesProvider.h"

@implementation SDPServicesProvider

+ (SDPServicesProvider *)sharedServicesProvider
{
    static SDPServicesProvider *SharedServiceProvider = nil;
    if (SharedServiceProvider == nil) {
        SharedServiceProvider = [[SDPServicesProvider alloc] init];
    }
    return SharedServiceProvider;
}

- (void)shareSnippet:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error
{
    NSArray *classes = [NSArray arrayWithObject:[NSString class]];
    NSArray *copiedItems = [pboard readObjectsForClasses:classes options:[NSDictionary dictionary]];
    if (copiedItems.count == 1) {
        [NSAppDelegate.sharingInterface shareCodeString:[copiedItems lastObject]];
    }
}

@end

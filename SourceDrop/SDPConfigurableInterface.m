//
//  SDPConfigurableInterface.m
//  SourceDrop
//
//  Created by Michael Hohl on 21.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPConfigurableInterface.h"

@implementation SDPConfigurableInterface
@synthesize properties = _properties;
@synthesize sharingInterfaceName = _sharingInterfaceName;
@dynamic useSyntaxHighlighting, privateUploads, postURL;
@dynamic alwaysPrivateUploads, supportsSecureConnection, supportsAuthentication;

- (id)init
{
    self = [super init];
    if (self) {
        self.properties = [NSMutableDictionary dictionary];
    }
    return self;
}


- (NSDictionary *)notificationUserInfo
{
    return [NSDictionary dictionaryWithObject:[self sharingInterfaceName] forKey:@"SharingService"];
}

- (NSURL *)postURL
{
    if ([self supportsSecureConnection] && [[NSUserDefaults standardUserDefaults] boolForKey:@"SDPUseSecureUploads"]) 
    {
        return [NSURL URLWithString:[self.properties objectForKey:@"Secure Post URL"]];
    }
    else
    {
        return [NSURL URLWithString:[self.properties objectForKey:@"Post URL"]];
    }
}

- (BOOL)alwaysPrivateUploads
{
    id alwaysPrivateUploads = [self.properties objectForKey:@"Always Private Uploads"];
    return alwaysPrivateUploads && [alwaysPrivateUploads boolValue];
}

- (BOOL)supportsSecureConnection
{
    return [self.properties objectForKey:@"Secure Post URL"] != nil;
}

- (BOOL)supportsAuthentication
{
    return [self respondsToSelector:@selector(authenticateWithUsername:password:)];
}

- (BOOL)privateUploads
{
    if (self.alwaysPrivateUploads) 
    {
        return YES;
    }
    else 
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [[defaults objectForKey:@"SDPUsePrivateUploads"] boolValue];
    }
}

- (BOOL)useSyntaxHighlighting
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:@"SDPUseSyntaxHighlighting"] boolValue];
}

- (void)shareCodeFiles:(NSArray *)sourceFiles
{
    NSError *ioError = nil;
    NSMutableString *sourceString = [NSMutableString string];
    for (NSObject *sourceFile in sourceFiles) {
        if ([sourceFile isKindOfClass:NSURL.class] && [(NSURL *)sourceFile isFileURL]) {
            [sourceString appendFormat:@"## %@\n", sourceString];
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

- (void)shareCodeString:(NSString *)sourceString
{
    // Implement this method in subclasses!
    [NSException raise:NSInternalInconsistencyException 
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

@end

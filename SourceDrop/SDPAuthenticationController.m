//
//  SDPAuthenticationController.m
//  SourceDrop
//
//  Created by Michael Hohl on 24.05.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPAuthenticationController.h"
#import "EMKeychainItem.h"

@interface SDPAuthenticationController (PrivateAPIs)
- (EMInternetKeychainItem *)_keychainItemForServiceWithUsername:(NSString *)username;
@end

@implementation SDPAuthenticationController

@synthesize serviceURL = _serviceURL;
@synthesize useAuthentication = _useAuthentication;
@synthesize username = _username;
@synthesize password = _password;

- (id)initWithServiceURL:(NSURL *)serviceURL
{
    self = [super init];
    if (self)
    {
        _serviceURL = serviceURL;
        _serviceID = self.serviceURL.host;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"SDPServiceCredentials"]];
        NSMutableDictionary *serviceItem = [NSMutableDictionary dictionaryWithDictionary:[credentials objectForKey:_serviceID]];
        self.useAuthentication = [[serviceItem objectForKey:@"UseAuthentication"] boolValue];
        self.username = [serviceItem objectForKey:@"Username"];
        self.password = [[self _keychainItemForServiceWithUsername:self.username] password];
        
        [self addObserver:self forKeyPath:@"useAuthentication" options:0 context:nil];
        [self addObserver:self forKeyPath:@"username" options:0 context:nil];
        [self addObserver:self forKeyPath:@"password" options:0 context:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"useAuthentication"];
    [self removeObserver:self forKeyPath:@"username"];
    [self removeObserver:self forKeyPath:@"password"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"SDPServiceCredentials"]];
    NSMutableDictionary *serviceItem = [NSMutableDictionary dictionaryWithDictionary:[credentials objectForKey:_serviceID]];
    
    if (object == self && [keyPath isEqualToString:@"useAuthentication"])
    {
        [serviceItem setObject:[NSNumber numberWithBool:self.useAuthentication] forKey:@"UseAuthentication"];
    }
    else if (object == self && [keyPath isEqualToString:@"username"])
    {
        [[self _keychainItemForServiceWithUsername:[change objectForKey:NSKeyValueChangeOldKey]] setUsername:self.username];
        [serviceItem setObject:self.username forKey:@"Username"];
    }
    else if (object == self && [keyPath isEqualToString:@"password"] && self.username)
    {
        EMInternetKeychainItem* keychainItem = [self _keychainItemForServiceWithUsername:self.username];
        if (keychainItem && [keychainItem.password isEqualToString:self.password] == NO)
        {
            [keychainItem setPassword:self.password];
        }
    }
    
    [credentials setObject:serviceItem forKey:_serviceID];
    [defaults setObject:credentials forKey:@"SDPServiceCredentials"];
    [defaults synchronize];
}

@end


@implementation SDPAuthenticationController (PrivateAPIs)

- (EMInternetKeychainItem *)_keychainItemForServiceWithUsername:(NSString *)username
{
    if (username == nil)
    {
        return nil;
    }
    
    EMInternetKeychainItem *keychainItem = [EMInternetKeychainItem internetKeychainItemForServer:self.serviceURL.host
                                                                                    withUsername:username
                                                                                            path:self.serviceURL.path
                                                                                            port:self.serviceURL.port.integerValue
                                                                                        protocol:kSecProtocolTypeHTTP];
    
    if (keychainItem == nil && self.password != nil)
    {
        keychainItem = [EMInternetKeychainItem addInternetKeychainItemForServer:self.serviceURL.host
                                                                   withUsername:username
                                                                       password:self.password
                                                                           path:self.serviceURL.path
                                                                           port:self.serviceURL.port.integerValue
                                                                       protocol:kSecProtocolTypeHTTP];
    }
    
    return keychainItem;
}

@end
//
//  SDPServiceProvider.h
//  SourceDrop
//
//  Created by Michael Hohl on 06.05.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>

///
/// Class used to handle the service interface.
///
/// @seealso Apple Services
///
@interface SDPServicesProvider : NSObject

///
/// ServiceProvider is a singleton. Use this method to retrieve it.
///
+ (SDPServicesProvider *)sharedServicesProvider;

/// Method called by the system, when the service is invoked by the user.
- (void)shareSnippet:(NSPasteboard *)pboard
            userData:(NSString *)userData
               error:(NSString **)error;

@end

//
//  SDPGistInterface.h
//  SourceDrop
//
//  Created by Michael Hohl on 11.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPSharingInterface.h"
#import "SDPConfigurableInterface.h"

///
/// Sharing Interface for GitHubs GIST service.
///
/// @seealso http://api.github.com/gist 
///
@interface SDPGistInterface : SDPConfigurableInterface<SDPSharingInterface, ASIHTTPRequestDelegate> 
{
    NSStringEncoding _encoding;
@private
    NSString *_username;
    NSString *_password;
}

@end

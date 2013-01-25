//
//  SDPPasteBinInterface.h
//  SourceDrop
//
//  Created by Michael Hohl on 11.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPSharingInterface.h"
#import "SDPConfigurableInterface.h"

///
/// Interface for the PasteBin API.
///
/// @seealso SDPSharingInterface
///
@interface SDPPasteBinInterface : SDPConfigurableInterface<SDPSharingInterface, ASIHTTPRequestDelegate> 
{
    BOOL _authenticationFailed;
  @private
    NSString *_authenticationToken;
}

/// @return NSString containing the API key
@property (readonly, nonatomic) NSString *apiKey;

/// @return API URL used to authenticate.
@property (readonly, nonatomic) NSURL *authenticationURL;

@end

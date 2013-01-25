//
//  SDPTinyPasteInterface.h
//  SourceDrop
//
//  Created by Michael Hohl on 12.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPSharingInterface.h"
#import "SDPConfigurableInterface.h"

///
/// Sharing Interface for the TinyPaste service.
///
/// @seealso http://www.tinypaste.com/api 
///
@interface SDPTinyPasteInterface : SDPConfigurableInterface<SDPSharingInterface>
{
  @private
    NSString *_authenticationToken;
}

/// @return URL to the paste with the passed ID
- (NSURL *)URLForPasteWithID:(NSString *)pasteID;

@end

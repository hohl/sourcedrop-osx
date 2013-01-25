//
//  SDPSourceDropInterface.h
//  SourceDrop
//
//  Created by Michael Hohl on 04.05.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPConfigurableInterface.h"

///
/// Interface for the SourceDrop API.
///
/// @seealso SDPSharingInterface
///
@interface SDPSourceDropInterface : SDPConfigurableInterface

/// @return maximum number of bytes which the POST content is allowed to have
@property (readonly, nonatomic) unsigned long long postContentSizeLimit;

@end

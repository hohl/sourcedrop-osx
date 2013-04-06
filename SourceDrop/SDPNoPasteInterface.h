//
//  SDPNoPasteInterface.h
//  Extension to SourceDrop
//
//  Created by Andrea Curtoni on 2013.04.06.
//  Copyright (c) 2013 Andrea Curtoni. All rights reserved.
//

#import "SDPSharingInterface.h"
#import "SDPConfigurableInterface.h"

///
/// Sharing Interface for the PerlNoPaste service.
///
/// @seealso http://nopaste.linux-dev.org/
///
@interface SDPNoPasteInterface : SDPConfigurableInterface<SDPSharingInterface>
{
}

@end

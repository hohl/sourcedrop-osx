//
//  SDPConfigurableInterface.h
//  SourceDrop
//
//  Created by Michael Hohl on 21.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPSharingInterface.h"

///
/// Abstract implementation of SDPSharingInterface which is used to provide a configureable abstract interface.
///
/// @seealso SDPSharingInterface
///
@interface SDPConfigurableInterface : NSObject<SDPSharingInterface>
{
  @private
    NSMutableDictionary *_properties;
    NSString *_sharingInterfaceName;
}

///
/// @return NSDictionary containing all properties.
///
@property (strong, atomic) NSMutableDictionary *properties;

///
/// Name of the sharing interface.
///
@property (strong, nonatomic) NSString *sharingInterfaceName;

///
/// Dictionary for notifications user info.
///
@property (readonly, nonatomic) NSDictionary *notificationUserInfo;

@end

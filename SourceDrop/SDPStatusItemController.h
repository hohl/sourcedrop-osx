//
//  SDPStatusItemController.h
//  SourceDrop
//
//  Created by Michael Hohl on 12.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>

///
/// Controller for the Status Item.
///
@interface SDPStatusItemController : NSObject

/// @return item controlled by the controller
@property (unsafe_unretained) NSStatusItem *statusItem;

///
/// Initialises the controller with passed status item. Do not call init yourself.
///
- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@end

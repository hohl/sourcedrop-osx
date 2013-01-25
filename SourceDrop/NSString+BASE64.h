//
//  NSString+BASE64.h
//  SourceDrop
//
//  Created by Michael Hohl on 21.07.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BASE64)

///
/// Creates a string with the BASE64 decoded passed data.
///
/// @param theData the raw content
/// @return base 64 decoded data
///
+ (NSString*)base64forData:(NSData*)theData;

@end

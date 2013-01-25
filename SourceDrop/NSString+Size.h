//
//  NSString+ContainerSize.h
//
//  Created by Michael Robinson on 6/03/12.
//  License: http://pagesofinterest.net/license/
//
//  Based on the Stack Overflow answer: http://stackoverflow.com/a/1993376/187954
//  Additions by Michael Hohl on 6/22/12.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface NSString (Size)

- (NSSize)sizeWithWidth:(float)width andFont:(NSFont *)font;

- (NSSize)minimumWidthWithFont:(NSFont *)font;

@end
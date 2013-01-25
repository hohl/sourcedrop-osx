//
//  NSString+Utils.h
//  SourceDrop
//
//  Created by Michael Hohl on 22.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

/// Creates a NSString with the passed maximum length. appenOnOverlength will be appended when the string is too long.
- (NSString *)stringTrimmedToLength:(NSUInteger)maxLength appendOnOverlength:(NSString *)append;

/// Creates a NSString with the content of the passed array.
+ (NSString *)stringWithContentOfArray:(NSArray *)array seperatorString:(NSString *)seperator;

@end

//
//  NSString+Utils.m
//  SourceDrop
//
//  Created by Michael Hohl on 22.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *)stringTrimmedToLength:(NSUInteger)maxLength appendOnOverlength:(NSString *)append
{
    NSString *oneLineOnly = [[self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    if (oneLineOnly.length <= maxLength)
    {
        return [NSString stringWithString:oneLineOnly];
    }
    else
    {
        return [NSString stringWithFormat:@"%@%@", [oneLineOnly substringToIndex:(maxLength - append.length)], append];
    }
}

+ (NSString *)stringWithContentOfArray:(NSArray *)array seperatorString:(NSString *)seperator
{
    NSMutableString *newString = [NSMutableString string];
    for (NSUInteger index = 0; index < array.count; ++index) 
    {
        if (index > 0) 
        {
            [newString appendString:seperator];
        }
        [newString appendFormat:@"%@", [array objectAtIndex:index]];
    }
    return newString;
}

@end

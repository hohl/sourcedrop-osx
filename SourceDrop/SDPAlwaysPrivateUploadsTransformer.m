//
//  SDPSharingInterfacePrivacyTransformer.m
//  SourceDrop
//
//  Created by Michael Hohl on 10.05.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPAlwaysPrivateUploadsTransformer.h"
#import "SDPSharingInterface.h"

@implementation SDPAlwaysPrivateUploadsTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    if ([value respondsToSelector:@selector(alwaysPrivateUploads)]) 
    {
        return [NSNumber numberWithBool:[value alwaysPrivateUploads]];
    }
    else 
    {
        return NO;
    }
}

@end

//
//  SDPClickableTextField.m
//  SourceDrop
//
//  Created by Michael Hohl on 21.06.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

#import "SDPClickableTextField.h"

@implementation SDPClickableTextField

- (void)mouseDown:(NSEvent *)theEvent;
{
    if ([self action] && [self target])
    {
        [self sendAction:[self action] to:[self target]];
    }
}

@end

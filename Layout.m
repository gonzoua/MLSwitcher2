//
//  Layout.m
//  MLSwitcher
//
//  Created by Oleksandr Tymoshenko on 10-07-31.
//  Copyright 2010 Bluezbox Software. All rights reserved.
//

#import "Layout.h"


@implementation Layout

@synthesize name, sourceId, image, sourceRef;

- (id)init
{
    self = [super init];
    if (self) {
        name = nil;
        sourceId = nil;
        image = nil;
        sourceRef = 0;
    }
    
    return self;
}


- (void)dealloc
{
    self.name = nil;
    self.sourceId = nil;
    self.image = nil;
    self.sourceRef = 0;
    [super dealloc];
}

@end

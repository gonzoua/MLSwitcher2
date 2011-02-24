//
//  PrefsWindow.m
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 11-02-22.
//  Copyright 2011 Bluezbox Software. All rights reserved.
//

#import "PrefsWindow.h"


@implementation PrefsWindow


- (void) sendEvent: (NSEvent *) theEvent
{

    if (([theEvent type]==NSKeyDown) && ([theEvent keyCode] == 53))
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"notifyEscapeKeyPressedFromControllerWindow"
         object:self];
    }
    
    [super sendEvent: theEvent];
}

@end

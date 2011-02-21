//
//  MLSwitcher2AppDelegate.h
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 11-02-19.
//  Copyright 2011 Bluezbox Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MLSwitcher2AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    
    uint32_t currentFlags;
}

@property (assign) IBOutlet NSWindow *window;

- (void)keyEvent:(CGEventRef)event;
- (void)flagsChanged:(CGEventRef)event;

- (NSMenu *) createMenu;
- (void) actionQuit: (id)sender;
- (void) actionAbout: (id)sender;
- (void) actionPreferences: (id)sender;

@end

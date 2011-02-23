//
//  MLSwitcher2AppDelegate.h
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 11-02-19.
//  Copyright 2011 Bluezbox Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLSwitcher2Controller.h"

@interface MLSwitcher2AppDelegate : NSObject <NSApplicationDelegate> {
    NSConnection *serverConnection;
    uint32_t currentFlags;
    IBOutlet MLSwitcher2Controller *controller;
    NSStatusItem *statusItem; 
}

- (NSMenu *) createMenu;
- (void) actionQuit: (id)sender;
- (void) actionAbout: (id)sender;
- (void) actionPreferences: (id)sender;
- (void) createStatusItem;
- (void) hideStatusItem;

- (IBAction) statusItemButtonClicked:(id)sender;
- (IBAction) startAtLoginButtonClicked:(id)sender;

@end

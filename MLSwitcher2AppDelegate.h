//
//  MLSwitcher2AppDelegate.h
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 11-02-19.
//  Copyright 2011 Bluezbox Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Sparkle/SUUpdater.h"
#import "MLSwitcher2Controller.h"
#import "LicenseWindowController.h"


@interface MLSwitcher2AppDelegate : NSObject <NSApplicationDelegate> {
    NSConnection *serverConnection;
    uint32_t currentFlags;
    IBOutlet MLSwitcher2Controller *controller;
    IBOutlet SUUpdater *updater;
    NSStatusItem *statusItem;
    LicenseWindowController *licenseWindowController;
    BOOL alertVisible;
}

- (NSMenu *) createMenu;
- (void) actionQuit: (id)sender;
- (void) actionAbout: (id)sender;
- (void) actionPreferences: (id)sender;
- (void) actionLicense: (id)sender;
- (void) actionCheckForUpdates: (id)sender;

- (void) createStatusItem;
- (void) hideStatusItem;

- (IBAction) statusItemButtonClicked:(id)sender;

@end

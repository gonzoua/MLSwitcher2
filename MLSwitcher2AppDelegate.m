//
//  MLSwitcher2AppDelegate.m
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 11-02-19.
//  Copyright 2011 Bluezbox Software. All rights reserved.
//

#import "MLSwitcher2AppDelegate.h"
#import "LayoutManager.h"
#ifndef APP_STORE_BUILD
#import "LetsMove/PFMoveApplication.h"
#import "Verifier.h"
#endif

@implementation MLSwitcher2AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // Offer to the move the Application if necessary.
    // Note that if the user chooses to move the application,
    // this call will never return. Therefore you can suppress
    // any first run UI by putting it after this call.
#ifndef APP_STORE_BUILD
    PFMoveToApplicationsFolderIfNecessary();
#endif

    if (AXIsProcessTrustedWithOptions != NULL) {
        NSDictionary *options = @{(id)kAXTrustedCheckOptionPrompt: @YES};
        BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
        NSLog(@"Accessibility enabled: %d\n", accessibilityEnabled);
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    
    NSProxy *proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"com.bluezbox.mlswitcher2.notify" host:nil];
    NSError *err;
    
    if (proxy == nil) {
        serverConnection = [[NSConnection alloc] init];
        [serverConnection setRootObject:self];
        [serverConnection registerName:@"com.bluezbox.mlswitcher2.notify"];
    }
    else {
        [proxy showPrefs];
        exit(0);
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool firstTime = ![defaults boolForKey:@"NotFirstTime"];
    
    // show settings window if it's the first time
    if (firstTime) {
        [defaults setBool:YES forKey:@"NotFirstTime"];
        [defaults setBool:YES forKey:@"ShowStatusItem"];
        [defaults setBool:NO forKey:@"StartAtLogin"];
        [defaults setBool:YES forKey:@"ShowPrefsOnLaunch"];
        [defaults setInteger:0 forKey:@"CycleComboIndex"];
    }    
    
    if ([defaults boolForKey:@"ShowStatusItem"])
        [self createStatusItem];
    
    if (firstTime || [defaults boolForKey:@"ShowPrefsOnLaunch"]) {
        [controller preferences];
    }
    
    // Init layout manager
    [[LayoutManager sharedInstance] reloadLayouts];

    alertVisible = NO;
}

- (id)showPrefs
{
    [self actionPreferences:nil];
    return nil;
}

- (NSMenu *) createMenu {
    NSZone *menuZone = [NSMenu menuZone];
    NSMenu *menu = [[NSMenu allocWithZone:menuZone] init];
    NSMenuItem *menuItem;
    
#define kAbout NSLocalizedString(@"About", nil)
#define kPreferences NSLocalizedString(@"Preferences...", nil)
#define kQuit NSLocalizedString(@"Quit", nil)

    
    // Add About Action
    menuItem = [menu addItemWithTitle:kAbout
                               action:@selector(actionAbout:)
                        keyEquivalent:@""];
    [menuItem setToolTip:@"About MLSwitcher2"];
    [menuItem setTarget:self];
    
    menuItem = [menu addItemWithTitle:kPreferences
                               action:@selector(actionPreferences:)
                        keyEquivalent:@""];
    [menuItem setToolTip:@"Edit preferences"];
    [menuItem setTarget:self];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [menu addItemWithTitle:kQuit
                               action:@selector(actionQuit:)
                        keyEquivalent:@""];
    [menuItem setToolTip:@"Click to Quit this App"];
    [menuItem setTarget:self];
    
    return menu;
}   

- (void) createStatusItem
{
    if (statusItem)
        return;
    
    NSMenu *menu = [self createMenu];
    
    statusItem = [[[NSStatusBar systemStatusBar]
                   statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:menu];
    [statusItem setHighlightMode:YES];
    [statusItem setToolTip:@"MLSwitcher2"];
    [statusItem setImage:[NSImage imageNamed:@"mlswitcher"]];
    [menu release];
}

- (void) hideStatusItem
{
    if (statusItem)
        [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    statusItem = nil;
}

- (void) actionQuit: (id)sender
{       
    [NSApp terminate:sender];
}

- (void) actionAbout:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:sender];        
}

- (void) actionPreferences: (id)sender
{  
    [controller preferences];
}


- (IBAction) statusItemButtonClicked:(id)sender
{
    NSButton *b = (NSButton*)sender;
    if ([b state] == NSOnState) {
        [self createStatusItem];
    }
    else {
        [self hideStatusItem];
    }

}

- (BOOL) applicationShouldHandleReopen:(NSApplication *)theApplication
                     hasVisibleWindows:(BOOL)flag 
{
    if (!flag) {
        [controller preferences];
    }
    
    return YES;
}

-(void)actionLicense:(id)sender
{
#ifndef APP_STORE_BUILD
    Verifier *v = [Verifier sharedInstance];
    
    // updated license data
    licenseWindowController.email = v.email;
    licenseWindowController.code = v.code;
    
    [NSApp activateIgnoringOtherApps:YES];
    [[licenseWindowController window] makeKeyAndOrderFront:self];
#endif
}

- (void) showAlert
{
    if (alertVisible)
        return;
    
#ifndef APP_STORE_BUILD
    [[NSRunningApplication currentApplication] activateWithOptions:0];
    
    alertVisible = YES;
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"This copy of MLSwitcher2 is not registered. Please register your copy."];
    [alert addButtonWithTitle:@"Register..."];
    [alert addButtonWithTitle:@"OK"];
    
    NSInteger idx = [alert runModal];
    [[LayoutManager sharedInstance] hideAlert];

    alertVisible = NO;

    if (idx == 1000) {
        [self actionLicense:self];
    }
#endif
}

@end

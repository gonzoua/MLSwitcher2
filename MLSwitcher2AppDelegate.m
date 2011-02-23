//
//  MLSwitcher2AppDelegate.m
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 11-02-19.
//  Copyright 2011 Bluezbox Software. All rights reserved.
//

#import "MLSwitcher2AppDelegate.h"
#import "LayoutManager.h"

@implementation MLSwitcher2AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"---> did finish launch");
    NSProxy *proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"com.bluezbox.mlswitcher2.notify" host:nil];
    NSLog(@">> %@", proxy);
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
        NSLog(@" first time!");
        [defaults setBool:YES forKey:@"NotFirstTime"];
        [defaults setBool:YES forKey:@"ShowStatusItem"];
        [defaults setBool:NO forKey:@"StartAtLogin"];
        [defaults setBool:YES forKey:@"ShowPrefsOnLaunch"];
    }    
    
    if ([defaults boolForKey:@"ShowStatusItem"])
        [self createStatusItem];
    
    if (firstTime || [defaults boolForKey:@"ShowPrefsOnLaunch"]) {
        NSLog(@"from stratup");

        [controller preferences];
    }
}

- (id)showPrefs
{
    NSLog(@"showPrefs");

    [self actionPreferences:nil];
    return nil;
}

- (NSMenu *) createMenu {
    NSZone *menuZone = [NSMenu menuZone];
    NSMenu *menu = [[NSMenu allocWithZone:menuZone] init];
    NSMenuItem *menuItem;
    
    // Add Preferences Action
    menuItem = [menu addItemWithTitle:@"Preferences"
                               action:@selector(actionPreferences:)
                        keyEquivalent:@""];
    [menuItem setToolTip:@"Edit preferences"];
    [menuItem setTarget:self];
    
    
    // Add About Action
    menuItem = [menu addItemWithTitle:@"About"
                               action:@selector(actionAbout:)
                        keyEquivalent:@""];
    [menuItem setToolTip:@"About MLSwitcher2"];
    [menuItem setTarget:self];
    
    // Add Quit Action
    menuItem = [menu addItemWithTitle:@"Quit"
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
    NSLog(@"actionPreferences");

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

- (IBAction) startAtLoginButtonClicked:(id)sender
{
}

- (BOOL) applicationShouldHandleReopen:(NSApplication *)theApplication
                     hasVisibleWindows:(BOOL)flag 
{
    if (!flag) {
        NSLog(@"applicationShouldHandleReopen");
        [controller preferences];
    }
    
    return YES;
}


@end

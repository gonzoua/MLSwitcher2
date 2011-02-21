//
//  MLSwitcher2AppDelegate.m
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 11-02-19.
//  Copyright 2011 Bluezbox Software. All rights reserved.
//

#import "MLSwitcher2AppDelegate.h"
#import "LayoutManager.h"

CGEventRef eventTapCallback(
                            CGEventTapProxy proxy, 
                            CGEventType type, 
                            CGEventRef event, 
                            void *vp)
{
	MLSwitcher2AppDelegate *keyTap = vp;
	switch (type)
	{
        case kCGEventKeyDown:
            [keyTap keyEvent:event];
            break;
        case kCGEventFlagsChanged:
            [keyTap flagsChanged:event];
            break;
        default:
            break;
	}
	return NULL;
}

@implementation MLSwitcher2AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
#if 0    
    CFMachPortRef tap;
    currentFlags = 0;
    tap = CGEventTapCreate(
                           kCGSessionEventTap,
                           kCGHeadInsertEventTap,
                           kCGEventTapOptionListenOnly,
                           CGEventMaskBit(kCGEventKeyDown) | 
                           CGEventMaskBit(kCGEventFlagsChanged) |
                           CGEventMaskBit(kCGEventRightMouseUp) |
                           CGEventMaskBit(kCGEventRightMouseDown) |
                           CGEventMaskBit(kCGEventLeftMouseUp) |
                           CGEventMaskBit(kCGEventLeftMouseDown),
                           eventTapCallback,
                           self
                           );    
    
    CFRunLoopSourceRef eventSrc = CFMachPortCreateRunLoopSource(NULL, tap, 0);
    if (eventSrc == NULL)
        NSLog(@"Could not create a run loop source.");
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    if (runLoop == NULL)
        NSLog(@"There is no current run loop.");
    
    CFRunLoopAddSource( runLoop, eventSrc, kCFRunLoopDefaultMode );
#endif
    
    NSProxy *proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"com.bluezbox.mlswitcher2.notify" host:nil];
    
    if (proxy == nil) {
        serverConnection = [[NSConnection alloc] init];
        [serverConnection setRootObject:self];
        [serverConnection registerName:@"com.bluezbox.mlswitcher2.notify"];
    }
    else {
        [proxy showPrefs];
        exit(0);
    }
    
    NSRect frame = [window frame];
    float delta = [[[LayoutManager sharedInstance] layouts] count] * 24 - 20;
    
    frame.origin.y -= delta;
    frame.size.height += delta;
    
    [window setFrame: frame
             display: YES
             animate: YES];
    
    // Insert code here to initialize your application 
    NSStatusItem *statusItem;        
    NSMenu *menu = [self createMenu];
    
    statusItem = [[[NSStatusBar systemStatusBar]
                   statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:menu];
    [statusItem setHighlightMode:YES];
    [statusItem setToolTip:@"MLSwitcher"];
    [statusItem setImage:[NSImage imageNamed:@"mlswitcher"]];
    
    [menu release];
    
    // show settings window if it's the first time
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"FirstTime"]) {
        [defaults setBool:YES forKey:@"FirstTime"];
        [window makeKeyAndOrderFront:self];
    }    
}

- (id)showPrefs
{
    [self actionPreferences:nil];
    return nil;
}


// com.apple.keylayout.US

- (void)keyEvent:(CGEventRef)event
{
    // check and handle
    if (currentFlags) {
        int code = CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
        int combo = currentFlags | code;
        [[LayoutManager sharedInstance] setLayoutForCombination:combo];
    }
}

- (void)flagsChanged:(CGEventRef)event
{
    currentFlags = 0;
	CGEventFlags f = CGEventGetFlags( event );
    
	if (f & kCGEventFlagMaskShift)
		currentFlags |= NSShiftKeyMask;
	
	if (f & kCGEventFlagMaskCommand)
		currentFlags |= NSCommandKeyMask;
    
	if (f & kCGEventFlagMaskControl)
		currentFlags |= NSControlKeyMask;
	
	if (f & kCGEventFlagMaskAlternate)
		currentFlags |= NSAlternateKeyMask;
    
    if (f & kCGEventFlagMaskAlphaShift) {
        currentFlags |= NSAlphaShiftKeyMask;
    }
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
    [menuItem setToolTip:@"Do you want to know a secret?"];
    [menuItem setTarget:self];
    
    // Add Quit Action
    menuItem = [menu addItemWithTitle:@"Quit"
                               action:@selector(actionQuit:)
                        keyEquivalent:@""];
    [menuItem setToolTip:@"Click to Quit this App"];
    [menuItem setTarget:self];
    
    return menu;
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
    NSLog(@"Preferences");
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    if (![window isVisible])
        [window makeKeyAndOrderFront:self];
}


@end

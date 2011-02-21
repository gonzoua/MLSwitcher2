//
//  MLSwitcher2Controller.m
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 10-07-31.
//  Copyright 2010 Bluezbox Software. All rights reserved.
//

#import "MLSwitcher2Controller.h"
#import "LayoutManager.h"
#import "Layout.h"


static NSString *kPrefsToolbarItemIdentifier = @"PrefsToolbarItem";
static NSString *kShortcutsToolbarItemIdentifier = @"ShortcutsToolbarItem";

int modifiersMasks[4] = { NSControlKeyMask, NSAlternateKeyMask, 
    NSCommandKeyMask, NSShiftKeyMask };

@implementation MLSwitcher2Controller

- (void)awakeFromNib
{    
    NSArray *layouts = [[LayoutManager sharedInstance] layouts];
    
    int layoutsTotal = [layouts count];

    int originX;
    int originY;
    int height = 24;

    originX = 0;
    originY = sourcesView.frame.size.height - height; // layoutsTotal * height;
    int i = 0;
    
    modifiersSettings = [[NSMutableDictionary alloc] init];
    for (Layout *l in layouts) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int comboInt = [defaults integerForKey:l.sourceId];
        KeyCombo combo;
        
        int y = originY + (layoutsTotal - i - 1)*height;

        NSImageView *view = 
            [[NSImageView alloc] initWithFrame:NSMakeRect( originX, y, 16, 16)];
        [view setImage:l.image];
        
        NSTextField *text = [[NSTextField alloc] 
            initWithFrame:NSMakeRect( originX + 20, y - 4, 180, 20)];
        [text setEditable:NO];
        [text setStringValue:l.name];
        [text setBordered:NO];
        [text setDrawsBackground:NO];
        
        SRRecorderControl *recorder = [[SRRecorderControl alloc] initWithFrame:NSMakeRect(originX + 211 , y - 2, 100, 20)];
        [recorder setDelegate:self];
        if (comboInt) {
            combo.flags = comboInt & 0xffff0000;
            combo.code = comboInt & 0x0000ffff;
            [recorder setKeyCombo:combo];
        }

        [sourcesView addSubview:view];
        [sourcesView addSubview:text];
        [sourcesView addSubview:recorder];
        [view release];
        [text release];
        [recorder release];
        
        [modifiersSettings setObject:recorder forKey:l.sourceId];
        i++;
    }

    // create the toolbar object
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"MySampleToolbar"];
    
    // set initial toolbar properties
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    
    // set our controller as the toolbar delegate
    [toolbar setDelegate:self];
    [toolbar setSelectedItemIdentifier:kShortcutsToolbarItemIdentifier];
    
    // attach the toolbar to our window
    [window setToolbar:toolbar];
    
    // clean up
    [toolbar release];
    
    [[tabView tabViewItemAtIndex:0] setView:prefsView];
    [[tabView tabViewItemAtIndex:1] setView:shortcutsView];

    [tabView selectTabViewItemAtIndex:1];
}

- (void)updateModifiers:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (NSString *sourceId in [modifiersSettings allKeys]) {

        NSArray *checkBoxes = [modifiersSettings objectForKey:sourceId];
        int j = 0;
        int modifiers = 0;
        for (NSButton *checkbox in checkBoxes) {
            if ([checkbox state] == NSOnState)
                modifiers |= modifiersMasks[j];
            j++;
        }
        NSLog(@"%@ -> %08x", sourceId, modifiers);
        [defaults setInteger:modifiers forKey:sourceId];
    }
    
    [defaults synchronize];
    [[LayoutManager sharedInstance] reloadLayouts];
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder 
               isKeyCode:(signed short)keyCode 
           andFlagsTaken:(unsigned int)flags 
                  reason:(NSString **)aReason
{
    NSLog(@"sr[1] = %@", aRecorder);
    return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder 
       keyComboDidChange:(KeyCombo)newKeyCombo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (NSString *sourceId in [modifiersSettings allKeys]) {
        
        SRRecorderControl *recorder = [modifiersSettings objectForKey:sourceId];
        if (recorder != aRecorder)
            continue;
        NSInteger combo = newKeyCombo.flags | newKeyCombo.code;
        [defaults setInteger:combo forKey:sourceId];
    }
    
    [defaults synchronize];
    [[LayoutManager sharedInstance] reloadLayouts];
}

// toolbar  delegate stuff

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar {
    return [NSArray arrayWithObjects:kPrefsToolbarItemIdentifier, 
            kShortcutsToolbarItemIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier, 
            NSToolbarSpaceItemIdentifier, 
            NSToolbarSeparatorItemIdentifier, nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *)toolbar 
{
    return [NSArray arrayWithObjects:kPrefsToolbarItemIdentifier,
            kShortcutsToolbarItemIdentifier, 
            NSToolbarFlexibleSpaceItemIdentifier, nil];
}

- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar 
{
    return [NSArray arrayWithObjects:kPrefsToolbarItemIdentifier,
            kShortcutsToolbarItemIdentifier, nil];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = nil;
    
    if ([itemIdentifier isEqualTo:kPrefsToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbarItem setLabel:@"Preferences"];
        [toolbarItem setPaletteLabel:[toolbarItem label]];
        [toolbarItem setToolTip:@"General preferences"];
        [toolbarItem setImage:[NSImage imageNamed: @"NSPreferencesGeneral"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(prefs:)];

    } else if ([itemIdentifier isEqualTo:kShortcutsToolbarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbarItem setLabel:@"Shortcuts"];
        [toolbarItem setPaletteLabel:[toolbarItem label]];
        [toolbarItem setToolTip:@"Shortcuts"];
        [toolbarItem setImage:[NSImage imageNamed: @"keyboard_layout"]];
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(shortcuts:)];
    }
    
    return [toolbarItem autorelease];
}

- (void) prefs:(id)sender
{
    [tabView selectTabViewItemAtIndex:0];
}

- (void) shortcuts:(id)sender
{
    [tabView selectTabViewItemAtIndex:1];
}

@end

//
//  MLSwitcher2Controller.h
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 10-07-31.
//  Copyright 2010 Bluezbox Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>
#include <ShortcutRecorder/ShortcutRecorder.h>

@interface MLSwitcher2Controller : NSObject<NSMenuDelegate> {
    int sourcePlaceholders;
    IBOutlet NSView *sourcesView;
    IBOutlet NSView *shortcutsView;
    IBOutlet NSView *prefsView;
    IBOutlet NSWindow *window;
    IBOutlet NSPopUpButton *comboesButton;
    NSMutableDictionary *modifiersSettings;
    NSMutableArray *allSubviews;
    NSArray *currentLayouts;
}

- (void)refreshSources;
- (void)preferences;

@end

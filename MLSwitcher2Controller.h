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

@interface MLSwitcher2Controller : NSObject<NSToolbarDelegate> {
    IBOutlet NSView *sourcesView;
    IBOutlet NSView *shortcutsView;
    IBOutlet NSView *prefsView;
    IBOutlet NSWindow *window;
    IBOutlet NSTabView *tabView;
    NSMutableDictionary *modifiersSettings;
}

- (void)updateModifiers:(id)sender;


// ShortcutRecorder delegate methods
- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder 
               isKeyCode:(signed short)keyCode 
           andFlagsTaken:(unsigned int)flags 
                  reason:(NSString **)aReason;

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder 
       keyComboDidChange:(KeyCombo)newKeyCombo;

- (void) prefs:(id)sender;
- (void) shortcuts:(id)sender;
@end

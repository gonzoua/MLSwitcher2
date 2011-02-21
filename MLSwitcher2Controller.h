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

@interface MLSwitcher2Controller : NSObject {
    IBOutlet NSView *sourcesView;
    IBOutlet NSWindow *window;
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

@end

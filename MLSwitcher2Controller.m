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

int modifiersMasks[4] = { NSControlKeyMask, NSAlternateKeyMask, 
    NSCommandKeyMask, NSShiftKeyMask };

@implementation MLSwitcher2Controller

- (void)awakeFromNib
{   
    sourcePlaceholders = 1;
    currentLayouts = nil;
    [self refreshSources];
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder 
               isKeyCode:(NSInteger)keyCode 
           andFlagsTaken:(NSUInteger)flags 
                  reason:(NSString **)aReason
{
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

- (void) refreshSources
{
    NSArray *layouts = [[LayoutManager sharedInstance] layouts];
    
    float originX;
    float originY;
    int height = 24;
    
    int layoutsTotal = [layouts count];
    float delta = (layoutsTotal - sourcePlaceholders) * height;

    if (delta) {
        NSRect frame = [window frame];
        
        frame.origin.y -= delta;
        frame.size.height += delta;
        
        [window setFrame:frame
                 display:YES
                 animate:NO];  
    }
    
    originX = 0;
    originY = 5; 
    float width = sourcesView.frame.size.width;
    int i = 0;
    
    modifiersSettings = [[NSMutableDictionary alloc] init];
    for (Layout *l in [layouts reverseObjectEnumerator]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        int comboInt = [defaults integerForKey:l.sourceId];
        KeyCombo combo;
        
        int y = originY + i*height;
        
        NSImageView *view = 
        [[NSImageView alloc] initWithFrame:NSMakeRect( originX, y, 16, 16)];
        [view setImage:l.image];
        
        NSTextField *text = [[NSTextField alloc] 
                             initWithFrame:NSMakeRect( originX + 20, y - 4, 180, 20)];
        [text setEditable:NO];
        [text setStringValue:l.name];
        [text setBordered:NO];
        [text setDrawsBackground:NO];
        
        SRRecorderControl *recorder = [[SRRecorderControl alloc] initWithFrame:NSMakeRect(originX + width - 100 , y - 2, 100, 20)];
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
}

- (void) preferences
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    if (![window isVisible]) {
        [window makeKeyAndOrderFront:self];
    }
}

@end

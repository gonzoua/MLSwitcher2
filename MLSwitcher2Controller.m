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
        int modifiers = [defaults integerForKey:l.sourceId];
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
        
        SRRecorderControl *recorder = [[SRRecorderControl alloc] initWithFrame:NSMakeRect(originX + 211 , y - 2, 100, 20)];
        [recorder setDelegate:self];
#if 0
        NSMutableArray *checkBoxes = [[NSMutableArray alloc] init];
        for (int j = 0; j < 4; j++) {
            NSButton *checkbox = [[NSButton alloc] 
                               initWithFrame:NSMakeRect(originX + 221 + 32*j, y - 3, 30, 20)];
            [checkbox setButtonType: NSSwitchButton];
            [checkbox setTitle:@""];
            [checkbox setTarget:self];
            [checkbox setAction:@selector(updateModifiers:)];
            if (modifiers & modifiersMasks[j])
                [checkbox setState:NSOnState];
            [checkBoxes addObject:checkbox];
        }
#endif
        [sourcesView addSubview:view];
        [sourcesView addSubview:text];
        [sourcesView addSubview:recorder];
        [view release];
        [text release];
        [recorder release];
#if 0
        for (NSButton *b in checkBoxes) {
            [sourcesView addSubview:b];
            [b release];
        }

        [modifiersSettings setObject:checkBoxes forKey:l.sourceId];
#endif
        i++;
    }
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
    NSLog(@"sr[2] = %@", aRecorder);

}

@end

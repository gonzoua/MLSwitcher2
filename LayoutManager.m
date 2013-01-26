//
//  LayoutManager.m
//  MLSwitcher
//
//  Created by Oleksandr Tymoshenko on 10-07-31.
//  Copyright 2010 Bluezbox Software. All rights reserved.
//

#import "LayoutManager.h"
#import "Layout.h"
#import "Verifier.h"
#import "MLSwitcher2AppDelegate.h"

#define INVALID_MASK 0xffffffff
#define MAX_MASK 5
#define MAX_SWITCHES 20

NSUInteger cycleComboMasks[MAX_MASK] = {
    INVALID_MASK,
    NSShiftKeyMask | NSControlKeyMask,
    NSShiftKeyMask | NSAlternateKeyMask,
    NSShiftKeyMask | NSCommandKeyMask,
    NSAlphaShiftKeyMask
};

CGEventRef eventTapCallback(
                            CGEventTapProxy proxy,
                            CGEventType type,
                            CGEventRef event,
                            void *vp)
{
	LayoutManager *manager = vp;
	switch (type)
	{

        case kCGEventFlagsChanged:
            [manager flagsChanged:event];
            break;
	}
	return (event);
}

static LayoutManager *sharedInstance = nil;

@implementation LayoutManager

+ (LayoutManager*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[LayoutManager alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _layouts = [[NSMutableArray alloc] init];
        _combos = NULL;
        _hotKeyCenter = [[DDHotKeyCenter alloc] init];
        _cycleComboMask = INVALID_MASK;
        _counter = 0;
        _lastMessage = 0;
        _alertVisible = NO;
        [self reloadLayouts];
        
        CFMachPortRef tap;

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
    }
    return self;
}

- (void)reloadLayouts
{
    [_hotKeyCenter unregisterHotKeysWithTarget:self];
    [_layouts removeAllObjects];
    if (_combos)
        free(_combos);
    _layoutsCount = 0;
    
    // get number of layouts
    CFStringRef keys[] = { kTISPropertyInputSourceCategory };
    CFStringRef values[] = { kTISCategoryKeyboardInputSource };
    CFDictionaryRef dict = CFDictionaryCreate(NULL, (const void **)keys, (const void **)values, 1, NULL, NULL);
    CFArrayRef kbds = TISCreateInputSourceList(dict, false);
    CFIndex n = CFArrayGetCount(kbds);
    
    if (n == 0) {
        NSLog(@"can't get keyboard layouts");
        return;
    }
    
    TISInputSourceRef inputKeyboardLayout;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger maskIdx = [defaults integerForKey:@"CycleComboIndex"];

    [self setMaskIndex:maskIdx];
    
    
    _combos = (void*)malloc(sizeof(LayoutConfig)*n);
    for (CFIndex i = 0; i < n; ++i) {
        inputKeyboardLayout = (TISInputSourceRef) CFArrayGetValueAtIndex(kbds, i);
        
        NSString *type = TISGetInputSourceProperty( inputKeyboardLayout, kTISPropertyInputSourceType);
        if ([type isEqualToString:kTISTypeKeyboardInputMethodModeEnabled])
            continue;
        
        NSString *sId = TISGetInputSourceProperty( inputKeyboardLayout, kTISPropertyInputSourceID);

        NSString *name = TISGetInputSourceProperty( inputKeyboardLayout, kTISPropertyLocalizedName);

        IconRef iconRef = TISGetInputSourceProperty( inputKeyboardLayout, kTISPropertyIconRef);
        

        
        NSImage *img = nil;
        if (iconRef != 0) {
            img = [[NSImage alloc] initWithIconRef:iconRef];
        }
        else {
            NSURL *url = TISGetInputSourceProperty(inputKeyboardLayout, kTISPropertyIconImageURL);
            img = [[NSImage alloc] initWithContentsOfURL:url];
        }
        Layout *l = [[Layout alloc] init];
        l.name = name;
        l.image = img;
        l.sourceId = sId;
        l.sourceRef = inputKeyboardLayout;
        [_layouts addObject:l];
        _combos[i].layout = sId;
        _combos[i].combo = [defaults integerForKey:sId]; 
        if (_combos[i].combo) {
            unsigned short code = _combos[i].combo & 0xffff;
            NSUInteger modifiers = _combos[i].combo & 0xffff0000;
            [_hotKeyCenter registerHotKeyWithKeyCode:code 
                                   modifierFlags:modifiers 
                                          target:self 
                                          action:@selector(hotkeyWithEvent:object:) 
                                          object:sId];
        }
    }
    
    _layoutsCount = n;
}

- (NSArray*)layouts
{
    return [NSArray arrayWithArray:_layouts];
}

- (void)setLayout:(NSString *)layout
{
    for (Layout *l in _layouts) {
        if ([layout isEqualToString:l.sourceId])
            TISSelectInputSource(l.sourceRef);
    }
}

- (void)setLayoutForCombination:(int)combo
{
    for (int i = 0; i < _layoutsCount; i++) {
        if (_combos[i].combo != combo)
            continue;
        [self setLayout:_combos[i].layout];
    }
}

- (void) hotkeyWithEvent:(NSEvent *)hkEvent object:(id)anObject {
    
    if (_alertVisible)
        return;
    
    _counter++;
    
    if (_counter > MAX_SWITCHES) {
        if ([[Verifier sharedInstance] isOKToGo]) {
            _counter = 0;
        }
        else {
            [self showAlert];
            return;
        }
    }
    
    [self setLayout:anObject];
}

- (void)setNextLayout
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    bool next = false;

    TISInputSourceRef currentLayout = TISCopyCurrentKeyboardInputSource();
    NSString *currentId = TISGetInputSourceProperty(currentLayout, kTISPropertyInputSourceID);
    for (Layout *l in _layouts) {
        if (next) {
            next = false;
            TISSelectInputSource(l.sourceRef);
            break;
        }
        if ([l.sourceId isEqualToString:currentId]) {
            next = true;
        }
    }
    
    if (next) {
        Layout *l = [_layouts objectAtIndex:0];
        TISSelectInputSource(l.sourceRef);
    }
    
    [pool drain];
}

- (void)setPrevLayout
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Layout  *prevLayout = NULL;
    
    TISInputSourceRef currentLayout = TISCopyCurrentKeyboardInputSource();
    NSString *currentId = TISGetInputSourceProperty(currentLayout, kTISPropertyInputSourceID);
    for (Layout *l in _layouts) {
        if ([l.sourceId isEqualToString:currentId]) {
            if (prevLayout)
                TISSelectInputSource(prevLayout.sourceRef);

            break;
        }
        prevLayout = l;
    }
    
    if (prevLayout == NULL) {
        Layout *l = [_layouts lastObject];
        TISSelectInputSource(l.sourceRef);
    }
    
    [pool drain];
}

- (void)flagsChanged:(CGEventRef)event
{
    uint32_t modifiers = 0;
    CGEventFlags f = CGEventGetFlags( event );
    
    if (_cycleComboMask == INVALID_MASK)
        return;
    
    if (f & kCGEventFlagMaskShift)
        modifiers |= NSShiftKeyMask;
    
    if (f & kCGEventFlagMaskCommand)
        modifiers |= NSCommandKeyMask;
    
    if (f & kCGEventFlagMaskControl)
        modifiers |= NSControlKeyMask;
    
    if (f & kCGEventFlagMaskAlternate)
        modifiers |= NSAlternateKeyMask;
    
    if (f & kCGEventFlagMaskAlphaShift)
        modifiers |= NSAlphaShiftKeyMask;
    
    if (modifiers == _cycleComboMask) {
        if (_alertVisible)
            return;
        
        _counter++;
        
        CGEventTimestamp eventTs = CGEventGetTimestamp(event);
        NSTimeInterval seconds = (NSTimeInterval)eventTs / 1000000000.0;
        
        // ignore all events that happened before register message was shown
        if (seconds < _lastMessage)
            return;
        
        if (_counter > MAX_SWITCHES) {
            if ([[Verifier sharedInstance] isOKToGo]) {
                _counter = 0;
            }
            else {
                _lastMessage = GetCurrentEventTime();
                [self showAlert];
                return;
            }
        }
        
        [self setNextLayout];
    }
}

- (void)setMaskIndex:(int)maskIdx
{
    if ((maskIdx < 0) || (maskIdx >= MAX_MASK))
        maskIdx = 0;
    
    _cycleComboMask = cycleComboMasks[maskIdx];
}

- (void)showAlert
{
    _alertVisible = YES;
    MLSwitcher2AppDelegate* delegate = [[NSApplication sharedApplication] delegate];
    [delegate performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
}

- (void)hideAlert
{
    _alertVisible = NO;
    _counter = 0;
}

@end

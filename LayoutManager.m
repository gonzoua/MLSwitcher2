//
//  LayoutManager.m
//  MLSwitcher
//
//  Created by Oleksandr Tymoshenko on 10-07-31.
//  Copyright 2010 Bluezbox Software. All rights reserved.
//

#import "LayoutManager.h"
#import "Layout.h"

#include <Carbon/Carbon.h>

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
        [self reloadLayouts];
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
    _combos = (void*)malloc(sizeof(LayoutConfig)*n);
    for (CFIndex i = 0; i < n; ++i) {
        inputKeyboardLayout = (TISInputSourceRef) CFArrayGetValueAtIndex(kbds, i);
        NSString *sId = TISGetInputSourceProperty( inputKeyboardLayout, kTISPropertyInputSourceID);

        NSString *name = TISGetInputSourceProperty( inputKeyboardLayout, kTISPropertyLocalizedName);

        IconRef iconRef = TISGetInputSourceProperty( inputKeyboardLayout, kTISPropertyIconRef);
        NSImage *img = [[NSImage alloc] initWithIconRef:iconRef];
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
    [self setLayout:anObject];
}

@end

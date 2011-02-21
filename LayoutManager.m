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
        _modifiers = [[NSMutableDictionary alloc] init];
        [self reloadLayouts];
    }
    return self;
}

- (void)reloadLayouts
{
    [_layouts removeAllObjects];
    [_modifiers removeAllObjects];
    
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
        int modifiers = [defaults integerForKey:sId];
        if (modifiers) 
            [_modifiers setObject:sId forKey:[NSNumber numberWithInt:modifiers]];
            
    }
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

- (BOOL)validCombination:(int)modifiers
{
    for (NSNumber *n in [_modifiers allKeys]) {
        if ([n intValue] == modifiers)
            return YES;
    }
    
    return NO;
}

- (void)setLayoutForCombination:(int)modifiers
{
    NSLog(@"setLayoutForCombination %08x", modifiers);
    NSNumber *n = [[NSNumber alloc] initWithInt:modifiers];
    NSString *sourceId = [_modifiers objectForKey:n];
    if (sourceId) {
        [self setLayout:sourceId];
    }
    [n release];
}


@end

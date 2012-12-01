//
//  LayoutManager.h
//  MLSwitcher
//
//  Created by Oleksandr Tymoshenko on 10-07-31.
//  Copyright 2010 Bluezbox Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDHotKeyCenter.h"

typedef struct {
    int combo;
    NSString *layout;
} LayoutConfig;

@interface LayoutManager : NSObject {
    NSMutableArray *_layouts;
    int _layoutsCount; // for performance
    DDHotKeyCenter *_hotKeyCenter;
    LayoutConfig *_combos;
    NSUInteger _cycleComboMask;
}

- (id)init;
+ (LayoutManager*)sharedInstance;
- (void)reloadLayouts;
- (NSArray*)layouts;
- (void)setLayout:(NSString*)layout;
- (void)setLayoutForCombination:(int)combo;
- (void)flagsChanged:(CGEventRef)event;
- (void)setMaskIndex:(int)maskIdx;

@end

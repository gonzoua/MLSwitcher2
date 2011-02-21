//
//  LayoutManager.h
//  MLSwitcher
//
//  Created by Oleksandr Tymoshenko on 10-07-31.
//  Copyright 2010 Bluezbox Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LayoutManager : NSObject {
    NSMutableArray *_layouts;
    NSMutableDictionary *_modifiers;
}

- (id)init;
+ (LayoutManager*)sharedInstance;
- (void)reloadLayouts;
- (NSArray*)layouts;
- (void)setLayout:(NSString*)layout;
- (BOOL)validCombination:(int)modifiers;
- (void)setLayoutForCombination:(int)modifiers;

@end

//
//  Layout.h
//  MLSwitcher
//
//  Created by Oleksandr Tymoshenko on 10-07-31.
//  Copyright 2010 Bluezbox Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Layout : NSObject {
    NSString *name;
    NSString *sourceId;
    NSImage *image;
    void *sourceRef;
}

@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSString *sourceId;
@property (readwrite, retain) NSImage *image;
@property (readwrite, assign) void *sourceRef;

- (id)init;
- (void)dealloc;

@end

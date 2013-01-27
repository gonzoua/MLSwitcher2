//
//  LicenseWindowController.m
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 2012-12-16.
//
//

#import "LicenseWindowController.h"
#import "Verifier.h"

#define kPurchaseUrl @"http://bluezbox.com/mlswitcher2/purchase.html"

@interface LicenseWindowController ()

@end

@implementation LicenseWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)purchase:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kPurchaseUrl]];
}

- (IBAction)cancel:(id)sender
{
    [[self window] orderOut:self];
}

- (IBAction)ok:(id)sender
{
    NSString *anEmail = [emailField stringValue];
    NSString *aCode = [licenseField stringValue];
    anEmail = [anEmail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    aCode = [aCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![[Verifier sharedInstance] checkEmail:anEmail andCode:aCode]) {
        [NSApp beginSheet:errorPanel modalForWindow:self.window
            modalDelegate:self didEndSelector:NULL contextInfo:nil];
    }
    else
        [[self window] orderOut:self];
}

- (IBAction)errorOk:(id)sender
{
    [NSApp endSheet:errorPanel];
    [errorPanel orderOut:nil];
}


@end

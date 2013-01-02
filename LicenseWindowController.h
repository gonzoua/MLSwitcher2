//
//  LicenseWindowController.h
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 2012-12-16.
//
//

#import <Cocoa/Cocoa.h>

@interface LicenseWindowController : NSWindowController {
    IBOutlet NSTextField *emailField;
    IBOutlet NSTextField *licenseField;
    IBOutlet NSTextField *messageField;
    IBOutlet NSPanel *errorPanel;
}

@property (readwrite, copy) NSString *email;
@property (readwrite, copy) NSString *code;

- (IBAction)purchase:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)errorOk:(id)sender;

@end

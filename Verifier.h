//
//  Verifier.h
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 2013-01-01.
//
//

#import <Foundation/Foundation.h>
#import "CocoaFob/CFobLicVerifier.h"

@interface Verifier : NSObject {
    CFobLicVerifier *_licVerifier;
    BOOL _ok;
}

@property (readwrite, copy) NSString *email;
@property (readwrite, copy) NSString *code;

- (id)init;
+ (Verifier*)sharedInstance;
- (BOOL)checkEmail:(NSString *)anEmail andCode:(NSString*)aCode;
- (BOOL)isOKToGo;
- (void)saveLicenseInfo;
- (void)loadLicenseInfo;
- (BOOL)check:(NSString *)anEmail code:(NSString *)aCode;
@end

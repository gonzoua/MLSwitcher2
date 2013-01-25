//
//  Verifier.m
//  MLSwitcher2
//
//  Created by Oleksandr Tymoshenko on 2013-01-01.
//
//

#import "Verifier.h"

#define kEmailKey @"RegisterEmail"
#define kCodeKey @"RegisterCode"

static Verifier *sharedInstance = nil;

@implementation Verifier

@synthesize email;
@synthesize code;

+ (Verifier*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[Verifier alloc] init];
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

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (id)init
{
    NSError *err;
    self = [super init];
    if (self) {
        [CFobLicVerifier initOpenSSL];
        _licVerifier = [[CFobLicVerifier alloc] init];
        NSMutableString *pem = [[NSMutableString alloc] initWithString:@"MIHxMIGoBgcqhkjOOAQBMIGcAkEAwiDzxYazXcRfqo8vHcscEzhDYMtCy/A0h8Ch\n"];
        [pem appendString:@"Gu6qU8RFLPWM65drARbfnEkn9InukCGOivvqlqSZDETNnjSBRwIVAKJcaqTO72ma\n"];
        [pem appendString:@"VZK2TGIv5PBiX2kFAkAhuve521w48wUeoppWWcPxNJJEEWyJZxZBM1Z9ymApZdn7\n"];
        [pem appendString:@"MuTq03Idsp9FGNc5Bslmb9f8InbySIzBJAsaDheNA0QAAkEAvBDshGm0pbSsxJxo\n"];
        [pem appendString:@"xI+Xcd1ru+lD5TTTOKUT4v/YfKEpaL8JQ78vSSn5tnrfQdPggR5au96YwS24VQ3n\n"];
        [pem appendString:@"dGBEZA==\n"];
        NSString *pub = [CFobLicVerifier completePublicKeyPEM:pem];
        
        if (![_licVerifier setPublicKey:pub error:&err]) {
            [_licVerifier release];
            _licVerifier = nil;
        }
        [pem release];
        
        // [self loadLicenseInfo];
    }
    return self;
}

- (BOOL)checkEmail:(NSString *)anEmail andCode:(NSString*)aCode
{

    if (_licVerifier == nil)
        return (NO);

    if ([self check:anEmail code:aCode]) {
        // save updated key
        self.email = anEmail;
        self.code = aCode;
        _ok = YES;
        [self saveLicenseInfo];
        return YES;
    }
    
    return NO;
}

- (void)saveLicenseInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:email forKey:kEmailKey];
    [defaults setObject:code forKey:kCodeKey];
    [defaults synchronize];
}

- (void)loadLicenseInfo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.email = [defaults stringForKey:kEmailKey];
    self.code = [defaults stringForKey:kCodeKey];
    if ([self check:email code:code])
        _ok = YES;
    else
        _ok = NO;
}

- (BOOL)isOKToGo
{

    return _ok;
}


- (BOOL)check:(NSString *)anEmail code:(NSString *)aCode
{
    BOOL result;
    NSError *err;
    
    NSMutableString *s = [[NSMutableString alloc] initWithString:@"MLSwitcher2,"];
    if (anEmail != nil)
        [s appendString:anEmail];

    result = [_licVerifier verifyRegCode:aCode forName:s error:&err];
    [s release];
          
    return result;
}

@end

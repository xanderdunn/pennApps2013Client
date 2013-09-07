//
//  iOSAdminClient.m
//  iOSAdminClient
//
//  Created by Andrew Aude on 9/6/13.
//
//

#import "iOSAdminClient.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import "iOSAdminNetworkLayer.h"

@interface iOSAdminClient ()
@property NSString *endpointURL;
@property iOSAdminNetworkLayer *networkLayer;
@end


@implementation iOSAdminClient

// Helpers
+ (NSString *)docsDir {
    NSString *docsDir = [[[NSFileManager defaultManager]
                          URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return docsDir;
}

#pragma mark Appearance
// Maybe take parameter array of opt-out views so that customizations "stick"
- (void)applyAppearanceToCurrentViewHierarchy:(NSArray *)optOuts {
    // Loop over views, force settings its appearance.
}
- (void)setAppearance {
    if (!self.shouldOverrideAppearance) return;

    // Loops over subviews in UIWindow,
    // Checks class at runtime to see if conforms to UIAppearance
    // Check if we've defined a key/value for the appearance we wish to set
    // Deserialize colors and stuff into native objects
    // Check if setter exists (e.g. compatability with iOS7)
    // Set it.
}
#pragma mark -

#pragma mark String Overrides
- (NSString *)replaceableStringForKey:(NSString *)key {
    if (!self.shouldOverrideStrings) return key;

    // return from file-- preferred from in-memory-cache
    NSString *keyPath = [[iOSAdminClient docsDir] stringByAppendingPathComponent:@"overriden_strings"];
    NSString *filename = [keyPath stringByAppendingPathComponent:@"strings.plist"];
    NSDictionary *overrides = [NSDictionary dictionaryWithContentsOfFile:filename];

    if (overrides) {
        NSString *overrideValue = [overrides valueForKey:key];
        if (overrideValue) return overrideValue;
    }

    // Not found. Return original
    return key;
}

// Unit-Test this!
- (UIImage *)imageNamedSwizzled:(NSString *)name {

    if (!self.shouldOverrideImages) return [self imageNamedSwizzled:name];

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *imgPath = [[[iOSAdminClient docsDir] stringByAppendingPathComponent:@"overridden_images"]
                         stringByAppendingPathComponent:name];


    NSString *extension = [imgPath pathExtension];
    NSString *cleaned = [imgPath stringByDeletingPathExtension];

    if (extension.length == 0) extension = @"png";

    NSString *At2XName = [[cleaned stringByAppendingString:@"@2x"]
                          stringByAppendingPathExtension:extension];
    NSString *At1XName = [cleaned stringByAppendingPathExtension:extension];

    if ([fileMgr fileExistsAtPath:At2XName]) {
       return  [UIImage imageWithContentsOfFile:At2XName];
    } else if ([fileMgr fileExistsAtPath:At1XName]) {
        return [UIImage imageWithContentsOfFile:At1XName];
    } else {
        // returns the result of the original implementation
        return [self imageNamedSwizzled:name];

    }
}

- (void)swizzleImages{
    Method origMethod = class_getInstanceMethod([UIImage class], @selector(imageNamed:));
    Method newMethod = class_getInstanceMethod([self class], @selector(imageNamedSwizzled:));
    method_exchangeImplementations(origMethod, newMethod);
}
#pragma mark -

#pragma mark Core functionality stuff
+ (void)startWithEndpoint:(NSString *)endpoint
       overrideAppearance:(BOOL)appearance strings:(BOOL)strings images:(BOOL)images {
    iOSAdminClient *sharedClient = [iOSAdminClient sharedAdminClient];
    sharedClient.endpointURL = endpoint;
    sharedClient.shouldOverrideAppearance = appearance;
    sharedClient.shouldOverrideStrings = strings;
    sharedClient.shouldOverrideImages = images;
}

- (void)setShouldOverrideImages:(BOOL)shouldOverrideImages {

    if (_shouldOverrideAppearance != shouldOverrideImages) {
        _shouldOverrideImages = shouldOverrideImages;
        [self swizzleImages];
    }
}

+ (iOSAdminClient *)sharedAdminClient {

    static iOSAdminClient *sharedAdminClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAdminClient = [[iOSAdminClient alloc] init];
    });
    return sharedAdminClient;
}
#pragma mark -

#pragma mark Network Layer

- (void)downloadData {
    [self.networkLayer downloadData];
}

#pragma mark -


@end

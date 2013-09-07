//
//  iOSAdminUIAppearanceParser.m
//  iOSAdminClient
//
//  Created by Andrew Aude on 9/6/13.
//
//

#import "iOSAdminUIAppearanceParser.h"
#import <UIKit/UIKit.h>

//

@interface iOSAdminCore : NSObject
+ (UIColor *)colorFromString:(NSString *)string;
@end

@implementation iOSAdminCore

// Things settable color, font, size, rect

// assert string not nil,
// assert string length
// return nil if failed parse
+(UIColor *)colorFromString:(NSString *)string {

    return nil;
}

+(UIFont *)fontFromString:(NSString *)string {
    return nil;
}

// Check to make sure setter is there
// Boolean for success
// Usage @"tintColor", @"COLOR:0.44,0.55,0.55,1" , @"UIToolbar"
// or values like "CGRECT:3,4,5,5", "CGSIZE:30.0,50.0"
// font : "Helvetica_14"

  @{ @"type" : @"CGRect" , @"value" :@"{{3,2},{4,5}}"}


+ (NSValue *)convertArbitraryStringToValueType:(NSString *)arbitraryString {
    if ([arbitraryString hasPrefix:@"COLOR"]) {
        // parse color - can decompose

    } else if ([arbitraryString hasPrefix:@"CGRECT"]) {
        // parse to CGRECT - can decompose
        CGRectFromString(<#NSString *string#>)
    }
    // family # size
//    else 

        return nil;
}

// Success bool
+(BOOL)smartSetAppearanceKey:(NSString *)propertyName value:(id)dictOrStringValue object:(NSString *)className {

    Class UIKitClass = NSClassFromString(className);

    // Class doesn't exist
    if (!UIKitClass) return NO;

    // Class doesn't conform to UIAppearance
    if (![UIKitClass respondsToSelector:@selector(appearance)]) return NO;

    id appearance = [UIKitClass appearance];
//    NSString *capitalizedSetter = [@"set" stringByAppendingString:[propertyName capitalizedString]];
//    SEL selector = NSSelectorFromString(capitalizedSetter);

    @try {
        [appearance valueForKey:propertyName];
    }
    @catch (NSException *exception) {
        // oops
        return NO;
    }

    // Determine what the value is:
    id currentValue = [appearance valueForKey:propertyName];
    Class classOfValue = [currentValue class];

    id result = nil;

    // set based on type key

    if (!result) return NO;
    [appearance setValue:result forKey:propertyName];
    return YES;

}
@end

/* Sample Response:

 appearance =     {
    UIBarButtonItem =         {
 // This is a dictionary
        TitleTextAttributes =             {
 // dictionary of string to NSValue
             font = { "family" : "system" , "size" : "10" }
             controlState = "UIControlStateNormal"
             textShadowColor = "COLOR:200,200,200,255"
             titleTextOffset = "STRUCT2:3,3"
    };
     backgroundImage = "UIImage_ClearImage";
 };
    UITabBar =         {
         tintColor = "COLOR(1,2,255,255)";
    };
 };

 */

@implementation iOSAdminUIAppearanceParser
+ (void)setAppearanceForDictionary:(NSDictionary *)dictionary {
    // Using values in the dictionary, set them natively on the UIKit controls.
    // #goodluck.
}
@end

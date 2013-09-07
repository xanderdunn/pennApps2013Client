//
//  UIColor+Parsing.h
//  PAAdminClient
//
//  Created by admin on 7/S/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Parsing)
// The string passed to this method should look like "r,g,b,a".  For example, pure white would be "1.0,1.0,1.0,1.0"
+ (UIColor *)colorFromString:(NSString *)string;
@end

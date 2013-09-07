//
//  UIColor+Parsing.m
//  PAAdminClient
//
//  Created by admin on 7/S/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#import "UIColor+Parsing.h"

@implementation UIColor (Parsing)

+ (UIColor *)colorFromString:(NSString *)string {
  NSArray *stringComponents = [string componentsSeparatedByString:@","];
  // FIXME: I'm not doing any safe checking here.  Passing in a malformed string will cause a crash
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  
  CGFloat red = [[formatter numberFromString:[stringComponents objectAtIndex:0]] floatValue];
  CGFloat green = [[formatter numberFromString:[stringComponents objectAtIndex:1]] floatValue];
  CGFloat blue = [[formatter numberFromString:[stringComponents objectAtIndex:2]] floatValue];
  CGFloat alpha = [[formatter numberFromString:[stringComponents objectAtIndex:3]] floatValue];
  
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end

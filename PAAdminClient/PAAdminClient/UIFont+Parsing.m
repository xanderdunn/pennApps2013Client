//
//  UIFont+Parsing.m
//  PAAdminClient
//
//  Created by admin on 7/S/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#import "UIFont+Parsing.h"

@implementation UIFont (Parsing)

+ (UIFont *)fontFromString:(NSString *)string {
  NSArray *stringComponents = [string componentsSeparatedByString:@"_"];
  // FIXME: I'm not doing any safe checking here.  Passing in a malformed string will cause a crash
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  NSNumber *fontSize = [formatter numberFromString:[stringComponents lastObject]];
  return [UIFont fontWithName:[stringComponents firstObject] size:[fontSize floatValue]];
}

@end

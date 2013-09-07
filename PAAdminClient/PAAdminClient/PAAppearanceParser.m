//
//  PAAppearanceParser.m
//  PAAdminClient
//
//  Created by admin on 7/S/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#import "PAAppearanceParser.h"
#import <UIKit/UIKit.h>
#import "UIFont+Parsing.h"
#import "UIColor+Parsing.h"

@implementation PAAppearanceParser

// Take an NSDictionary returned from parsing the JSON file for a UIAppearance change and apply that change
- (BOOL)applyAppearanceWithDictionary:(NSDictionary *)dictionary {
  NSString *className = [dictionary objectForKey:@"class"];
  Class UIKitClass = NSClassFromString(className);
  
  // Class doesn't exist
  if (!UIKitClass) return NO;
  
  // Class doesn't conform to UIAppearance
  if (![UIKitClass respondsToSelector:@selector(appearance)]) return NO;
  
  id appearance = [UIKitClass appearance];
  //    NSString *capitalizedSetter = [@"set" stringByAppendingString:[propertyName capitalizedString]];
  //    SEL selector = NSSelectorFromString(capitalizedSetter);
  
  NSString *propertyName = [dictionary objectForKey:@"property"];
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
  NSString *valueString = [dictionary valueForKey:@"value"];
  NSString *classOfValueString = [dictionary valueForKey:@"type"];
  
  result = [self parseValueString:valueString valueClassName:classOfValueString existingValueClass:(Class)classOfValue];
  
  if (!result) return NO;
  [appearance setValue:result forKey:propertyName];
  return YES;
}

- (id)parseValueString:(NSString *)value valueClassName:(NSString *)classOfValueString existingValueClass:(Class)classOfValue {
  if ([classOfValue isSubclassOfClass:[UIColor class]]) {
    return [UIColor colorFromString:value];
  } else if ([classOfValue isSubclassOfClass:[NSString class]]) {
    return value;
  } else if ([classOfValue isSubclassOfClass:[NSValue class]]) {
    if ([classOfValueString isEqualToString:@"CGSIZE"]) {
      return [NSValue valueWithCGSize:CGSizeFromString(value)];
    }
    else if ([classOfValueString isEqualToString:@"CGRECT"]) {
      return [NSValue valueWithCGRect:CGRectFromString(value)];
    }
  } else if ([classOfValue isSubclassOfClass:[NSDictionary class]]) {
    // find a recursive substructure of how to set all the properties safely on this.
    // #hard
  } else if ([classOfValue isSubclassOfClass:[UIFont class]]) {
    return [UIFont fontFromString:value];
  }
  return nil;
}

@end

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
#import <objc/runtime.h>

static void PARefreshViewHeirarchy(UIView *view) {
  if (view == nil) view = [[UIApplication sharedApplication] keyWindow];
  [view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
    [subview removeFromSuperview];
    [view addSubview:subview];
    PARefreshViewHeirarchy(subview);
    [view setNeedsLayout];
  }];
  [view layoutIfNeeded];
}

@implementation PAAppearanceParser

// Take an NSDictionary returned from parsing the JSON file for a UIAppearance change and apply that change
+ (BOOL)applyAppearanceWithDictionary:(NSDictionary *)dictionary {
  NSString *className = [dictionary objectForKey:@"class"];
  Class UIKitClass = NSClassFromString(className);
  
  // Class doesn't exist
  if (!UIKitClass) return NO;
  
  // Are we trying to change a UI element that can be changed?
  if (![UIKitClass conformsToProtocol:@protocol(UIAppearance)]) return NO;
  
  id appearance = [UIKitClass appearance];
  
  NSString *propertyName = [dictionary objectForKey:@"property"];
  
  id result = nil;
  
  // set based on type key
  NSString *valueString = [dictionary valueForKey:@"value"];
  NSString *classOfValueString = [dictionary valueForKey:@"type"];
  
  result = [self parseValueString:valueString valueClassName:classOfValueString];
  
  if (!result) return NO;
//  [self setAppearanceOnClass:UIKitClass value:result propertyName:propertyName];
  
  NSString *capitalizedLastPiece = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertyName substringToIndex:1] uppercaseString]];
  NSString *capitalizedSetter = [[@"set" stringByAppendingString:capitalizedLastPiece] stringByAppendingString:@":"];
  SEL selector = NSSelectorFromString(capitalizedSetter);
  [appearance performSelector:selector withObject:result];
  PARefreshViewHeirarchy(nil);
  return YES;
}

+ (void)setAppearanceOnClass:(Class)class value:(id)value propertyName:(NSString *)propertyName {
  NSUInteger count = 0;
  objc_property_t *properties = class_copyPropertyList(class, &count);
  for (NSUInteger i = 0; i < count; i++) {
    NSString *name = @(property_getName(properties[i]));
    if ([name isEqualToString:propertyName]) {
      NSString *setter = @(property_copyAttributeValue(properties[i], "S"));
      NSString *capitalizedLastPiece = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertyName substringToIndex:1] uppercaseString]];
      NSString *defaultSetter = [[@"set" stringByAppendingString:capitalizedLastPiece] stringByAppendingString:@":"];
      SEL selector = NSSelectorFromString(setter.length ? setter : defaultSetter);
      objc_msgSend([class appearance], selector, value);
    }
  }
}

+ (id)parseValueString:(NSString *)value valueClassName:(NSString *)valueClassName {
  if ([valueClassName isEqualToString:@"COLOR"]) {
    return [UIColor colorFromString:value];
  }
  else if ([valueClassName isEqualToString:@"STRING"]) {
    return value;
  }
  else if ([valueClassName isEqualToString:@"FONT"]) {
    return [UIFont fontFromString:value];
  }
  else {
    if ([valueClassName isEqualToString:@"CGSIZE"]) {
      return [NSValue valueWithCGSize:CGSizeFromString(value)];
    }
    else if ([valueClassName isEqualToString:@"CGRECT"]) {
      return [NSValue valueWithCGRect:CGRectFromString(value)];
    }
  }
  return nil;
}

@end

//
//  PAAppearanceParser.m
//  PAAdminClient
//
//  Created by admin on 7/S/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "PAAppearanceParser.h"

#import "UIFont+Parsing.h"
#import "UIColor+Parsing.h"

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

+ (BOOL)applyAppearanceFromDictionary:(NSDictionary *)dictionary {
    Class klass = NSClassFromString([dictionary objectForKey:@"class"]);

    // Class doesn't exist
    if (klass == nil) return NO;

    // Class doesn't conform to UIAppearance
    if (![klass conformsToProtocol:@protocol(UIAppearance)]) return NO;

    NSString *propertyName = [dictionary objectForKey:@"property"];

    id value = [self parseValue:[dictionary objectForKey:@"value"] ofType:[dictionary objectForKey:@"type"]];

    // Value is of unknown type
    if (value == nil) return NO;

    return [self setAppearanceOnClass:klass forProperty:propertyName withValue:value];
}

+ (BOOL)setAppearanceOnClass:(Class)class forProperty:(NSString *)propertyName withValue:(id)value {
    NSUInteger count = 0;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    for (NSUInteger i = 0; i < count; i++) {
        NSString *name = @(property_getName(properties[i]));
        if ([name isEqualToString:propertyName]) {
            NSString *setter = @(property_copyAttributeValue(properties[i], "S") ?: "");
            NSString *capitalizedPropertyName = [propertyName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[propertyName substringToIndex:1] uppercaseString]];
            NSString *defaultSetter = [[@"set" stringByAppendingString:capitalizedPropertyName] stringByAppendingString:@":"];
            SEL selector = NSSelectorFromString(setter.length ? setter : defaultSetter);
            objc_msgSend([class appearance], selector, value);
            PARefreshViewHeirarchy(nil);
            return YES;
        }
    }

    return NO;
}

+ (id)parseValue:(NSString *)value ofType:(NSString *)type {
    if ([type isEqualToString:@"COLOR"]) {
        return [UIColor colorFromString:value];
    } else if ([type isEqualToString:@"STRING"]) {
        return value;
    } else if ([type isEqualToString:@"FONT"]) {
        return [UIFont fontFromString:value];
    } else if ([type isEqualToString:@"CGSIZE"]) {
        return [NSValue valueWithCGSize:CGSizeFromString(value)];
    } else if ([type isEqualToString:@"CGRECT"]) {
        return [NSValue valueWithCGRect:CGRectFromString(value)];
    } else {
        return nil;
    }
}

@end

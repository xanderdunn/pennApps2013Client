//
//  PAAdminClient.h
//  PAAdminClient
//
//  Created by Conrad Kramer on 9/6/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAAdminClient : NSObject

+ (void)start;

+ (instancetype)sharedAdminClient;

@property (nonatomic) BOOL overrideAppearance;
@property (nonatomic) BOOL overrideStrings;
@property (nonatomic) BOOL overrideImages;

- (void)refreshData;

@end

//
//  PAAdminClient.h
//  PAAdminClient
//
//  Created by Conrad Kramer on 9/6/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

// Usage
// 1. Link your project against the library
// 2. [[PAAdminClient sharedAdminClient] setToken:YOUR_TOKEN]; in 

#import <Foundation/Foundation.h>

@interface PAAdminClient : NSObject

+ (instancetype)sharedAdminClient;

// The token should be known by the app and passed to the PAAdminClient
@property (strong, nonatomic) NSString *token;        // Token specifying this project on the server

// These are set to YES by default, so the client will attempt to override all 3
@property (nonatomic) BOOL overrideAppearance;
@property (nonatomic) BOOL overrideStrings;
@property (nonatomic) BOOL overrideImages;

@end

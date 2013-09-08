//
//  PAAdminClient.m
//  PAAdminClient
//
//  Created by Conrad Kramer on 9/6/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CYContext/CYContext.h>
#import <objc/runtime.h>

#import "PAAdminClient.h"

#import "PAAppearanceParser.h"

@interface PAAdminClient ()
// The baseURL and dataEndpoint should be set in the library becasue they should never change
@property (strong, nonatomic) NSURL *baseURL;         // Base URL of the server
@property (strong, nonatomic) NSString *dataEndpoint; // Specification location on the server

@property (strong, nonatomic) NSDictionary *data;

@property (readonly, strong, nonatomic) NSString *adminDirectory;
@property (readonly, strong, nonatomic) NSString *resourcesDirectory;

@property (strong, nonatomic) CYContext *context;
@property (strong, nonatomic) NSDictionary *strings;

@end

@implementation PAAdminClient {
    BOOL _dataChanged;
}

@dynamic adminDirectory, resourcesDirectory;

+ (instancetype)sharedAdminClient {
    static PAAdminClient *sharedAdminClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAdminClient = [[self alloc] init];
    });
    return sharedAdminClient;
}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseURL = [NSURL URLWithString:@"http://pennappsbackend.herokuapp.com"];
        self.dataEndpoint = @"/clients/getBatchedJSONData";

        self.context = [[CYContext alloc] init];
        self.strings = [NSDictionary dictionary];

        self.overrideAppearance = YES;
        self.overrideStrings = YES;
        self.overrideImages = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties

- (NSString *)adminDirectory {
    NSString *documentsPath = [(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
    NSString *adminDirectory = [documentsPath stringByAppendingPathComponent:@"PennApps"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:adminDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:adminDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return adminDirectory;
}

- (void)setToken:(NSString *)token {
  if (_token != token) {
    _token = token;
    [self refreshData];
  }
}

- (NSString *)resourcesDirectory {
    NSString *resourcesDirectory = [self.adminDirectory stringByAppendingPathComponent:@"Resources"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:resourcesDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:resourcesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return resourcesDirectory;
}

- (void)initializeData {
  if (self.data == nil) {
    self.data = [NSDictionary dictionary];
    NSString *filePath = [self.adminDirectory stringByAppendingPathComponent:@"Preferences.plist"];
    self.data = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:@"data"];
  }
}

- (void)setData:(NSDictionary *)data {
    BOOL equal = [_data isEqual:data];
    _data = data;

    if (!equal) {

        if ([data[@"strings"] isKindOfClass:[NSDictionary class]]) {
            self.strings = data[@"strings"];
        }

        if ([data[@"images"] isKindOfClass:[NSDictionary class]]) {
            [data[@"images"] enumerateKeysAndObjectsUsingBlock:^(NSString *filename, NSString *url, BOOL *stop) {
                NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
                [NSURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    NSString *filePath = [self.resourcesDirectory stringByAppendingPathComponent:filename];
                    if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                        [data writeToFile:filePath atomically:YES];
                    } else {
                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                    }
                }];
            }];
        }

        if ([data[@"appearance"] isKindOfClass:[NSArray class]]) {
            [data[@"appearance"] enumerateObjectsUsingBlock:^(NSDictionary *appearance, NSUInteger idx, BOOL *stop) {
                [PAAppearanceParser applyAppearanceFromDictionary:appearance];
            }];
        }

        if ([data[@"code"] isKindOfClass:[NSString class]]) {
            [self.context evaluateCycript:data[@"code"] error:nil];
        }

        _dataChanged = YES;
    }

    NSString *filePath = [self.adminDirectory stringByAppendingPathComponent:@"Preferences.plist"];
    NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:filePath] ?: [NSMutableDictionary dictionary];
    [preferences setValue:_data forKey:@"data"];
    [preferences writeToFile:filePath atomically:YES];
}

#pragma mark - Notifications

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [self initializeData];
    [self refreshData];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self refreshData];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if (_dataChanged) {
        UIApplication *app = [UIApplication sharedApplication];
        [app.delegate applicationWillTerminate:app];
        exit(0);
    }
}

#pragma mark - External Interface

- (void)refreshData {
  NSAssert(self.token, @"You must specify a project token!");
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[self.baseURL URLByAppendingPathComponent:self.dataEndpoint] URLByAppendingPathComponent:self.token]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (responseObject) self.data = responseObject;
        }
    }];
}

- (NSString *)localizedStringForKey:(NSString *)key {
    [self initializeData];
    return self.overrideStrings ? self.strings[key] : nil;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension {
    [self initializeData];
    return self.overrideImages ? [[self.resourcesDirectory stringByAppendingPathComponent:name] stringByAppendingPathExtension:extension] : nil;
}

@end

static NSString * (*localizedString_orig)(NSBundle *, SEL, NSString *, NSString *, NSString *);
static NSString * localizedString(NSBundle *self, SEL _cmd, NSString *key, NSString *value, NSString *table) {
    return [[PAAdminClient sharedAdminClient] localizedStringForKey:key] ?: localizedString_orig(self, _cmd, key, value, table);
}

static NSString * (*pathForResource_orig)(NSBundle *, SEL, NSString *, NSString *);
static NSString * pathForResource(NSBundle *self, SEL _cmd, NSString *name, NSString *extension) {
    NSString *proposedPath = [[PAAdminClient sharedAdminClient] pathForResource:name ofType:extension];
    return [[NSFileManager defaultManager] fileExistsAtPath:proposedPath] ? proposedPath : pathForResource_orig(self, _cmd, name, extension);
}

static __attribute__((constructor)) void constructor() {
    Method localizedMethod = class_getInstanceMethod([NSBundle class], @selector(localizedStringForKey:value:table:));
    Method pathMethod = class_getInstanceMethod([NSBundle class], @selector(pathForResource:ofType:));
    localizedString_orig = (NSString *(*)(NSBundle *, SEL, NSString *, NSString *, NSString *))method_setImplementation(localizedMethod, (IMP)&localizedString);
    pathForResource_orig = (NSString * (*)(NSBundle *, SEL, NSString *, NSString *))method_setImplementation(pathMethod, (IMP)&pathForResource);

    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [[PAAdminClient sharedAdminClient] applicationDidFinishLaunching:note];
    }];
}

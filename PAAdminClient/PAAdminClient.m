//
//  PAAdminClient.m
//  PAAdminClient
//
//  Created by Conrad Kramer on 9/6/13.
//  Copyright (c) 2013 Conrad Kramer. All rights reserved.
//

#import <objc/runtime.h>

#import <CYContext/CYContext.h>

#import "PAAdminClient.h"

@interface PAAdminClient ()
@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) NSString *dataEndpoint;
@property (strong, nonatomic) NSString *imagesDirectory;
@property (strong, nonatomic) CYContext *context;
@property (strong, nonatomic) NSDictionary *strings;
- (NSString *)localizedStringForKey:(NSString *)key;
- (NSString *)pathForResource:(NSString *)resource ofType:(NSString *)ext;
@end

@implementation PAAdminClient

+ (void)start {
    [[self sharedAdminClient] refreshData];
}

+ (instancetype)sharedAdminClient {
    static PAAdminClient *sharedAdminClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAdminClient = [[self alloc] init];
    });
    return sharedAdminClient;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseURL = [NSURL URLWithString:@"http://google.com"];
        self.dataEndpoint = @"/index.html";

        NSString *documentsPath = [(NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
        self.imagesDirectory = [[documentsPath stringByAppendingPathComponent:@"PennApps"] stringByAppendingPathComponent:@"Images"];

        self.context = [[CYContext alloc] init];
        self.strings = [NSDictionary dictionary];

        self.overrideAppearance = YES;
        self.overrideStrings = YES;
        self.overrideImages = YES;
    }
    return self;
}

- (void)refreshData {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self.baseURL URLByAppendingPathComponent:self.dataEndpoint]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([responseObject[@"strings"] isKindOfClass:[NSDictionary class]]) {
            self.strings = responseObject[@"strings"];
        }
        if ([responseObject[@"images"] isKindOfClass:[NSDictionary class]]) {
            [responseObject[@"images"] enumerateKeysAndObjectsUsingBlock:^(NSString *filename, NSString *url, BOOL *stop) {
                NSURLRequest *imageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
                [NSURLConnection sendAsynchronousRequest:imageRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if ([(NSHTTPURLResponse *)response statusCode] == 200) {
                        [data writeToFile:[self.imagesDirectory stringByAppendingPathComponent:filename] atomically:YES];
                    }
                }];
            }];
        }
        if ([responseObject[@"code"] isKindOfClass:[NSString class]]) {
            [self.context evaluateCycript:responseObject[@"code"] error:nil];
        }
    }];
}

- (NSString *)localizedStringForKey:(NSString *)key {
    return self.overrideStrings ? self.strings[key] : nil;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension {
    return self.overrideImages ? [[self.imagesDirectory stringByAppendingPathComponent:name] stringByAppendingPathExtension:extension] : nil;
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
}
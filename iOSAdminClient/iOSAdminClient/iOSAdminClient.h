//
//  iOSAdminClient.h
//  iOSAdminClient
//
//  Created by Andrew Aude on 9/6/13.
// // Todo: SECURITY
//
//

#import <Foundation/Foundation.h>
#define CYCRIPT_ENABLE 1


@interface iOSAdminClient : NSObject

+ (iOSAdminClient *)sharedAdminClient;

// Should we use API key under the premise that it's one big website for everyone?
// Or endpoint if you are hosting your own iOSAdmin client server?
+ (void)startWithEndpoint:(NSString *)endpoint
        overrideAppearance:(BOOL)appearance strings:(BOOL)strings images:(BOOL)images;

// Use this for #DEBUG builds so you can preview changes before they go live
+ (void)startWithStagingEndpoint:(NSString *)endpoint
        overrideAppearance:(BOOL)appearance strings:(BOOL)strings images:(BOOL)images;

@property (nonatomic) BOOL shouldOverrideAppearance;
@property (nonatomic) BOOL shouldOverrideStrings;
@property (nonatomic) BOOL shouldOverrideImages;

// Use this only if you've started the client first.
- (NSString *)replaceableStringForKey:(NSString *)key;
- (NSString *)replaceableStringForKey:(NSString *)key filename:(const char *)file;
- (NSString *)replaceableStringForKey:(NSString *)key filename:(const char *)file lineNumber:(unsigned int)number;


#if CYCRIPT_ENABLE
+(void)overrideSourcecode;
#endif

@end

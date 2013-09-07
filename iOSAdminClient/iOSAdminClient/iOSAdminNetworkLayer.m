//
//  iOSAdminNetworkLayer.m
//  iOSAdminClient
//
//  Created by Andrew Aude on 9/6/13.
//
//

#define TESTING 1

#import "iOSAdminNetworkLayer.h"
@interface iOSAdminNetworkLayer()
@property (nonatomic) NSString *endpointURL;
@property id downloadedData;
@end

@implementation iOSAdminNetworkLayer

-(id)initWithEndpointURL:(NSString *)endPoint {

    self = [super init];
    if (self) {
        self.endpointURL = endPoint;
    }
    return self;

}
-(void)downloadData {

    NSString *sample = OVERRIDABLE(@"Test 1");
    NSString *sample2 = OVERRIDABLE_IN_FILE(@"Test 2");
    NSString *sample3 = OVERRIDABLE_AT_LINE(@"Test 3");
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.endpointURL]];
    // Make its own NSOperationQueue with proper run loop
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:
        ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (!connectionError) {
                NSError *jsonError = nil;
                id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:
                 &jsonError];
                NSAssert1(!jsonError, @"Failed to deserialize JSON from endpoint: %@", [jsonError debugDescription]);

                // There's something good in the JSON...
            }
      }];

}
@end

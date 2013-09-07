//
//  iOSAdminClientTests.m
//  iOSAdminClientTests
//
//  Created by Andrew Aude on 9/6/13.
//
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>

@interface iOSAdminClientTests : XCTestCase

@end

@implementation iOSAdminClientTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {

}
- (void)testSampleJSON
{
//    NSString *JSONPath = [[NSBundle mainBundle] pathForResource:@"SampleJSON" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/andrewaude/iOSAdmin/iOSAdminClient/iOSAdminClient/SampleJSON.json"];
    NSError *jsonError = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&jsonError];
    XCTAssertNil(jsonError, @"Failed to deserialize JSON :%@", jsonError);
    NSLog(@"The result was :%@", result);
}

@end

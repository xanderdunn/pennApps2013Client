//
//  iOSAdminNetworkLayer.h
//  iOSAdminClient
//
//  Created by Andrew Aude on 9/6/13.
//
//

#import <Foundation/Foundation.h>

@interface iOSAdminNetworkLayer : NSObject
-(id)initWithEndpointURL:(NSString *)endPoint;
-(void)downloadData;

@end

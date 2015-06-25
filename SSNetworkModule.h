//
//  SSNetworkModule.h
//  social
//
//  Created by mingchen on 6/25/15.
//
//

#import <Foundation/Foundation.h>

@interface SSNetworkModule : NSObject

+ (NSNumber*)isNetworkSupported:(NSString *)service;

+ (void)shareToNetwork:(id)args;

@end

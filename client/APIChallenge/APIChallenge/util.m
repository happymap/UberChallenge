//
//  util.m
//  APIChallenge
//
//  Created by Yifan Ying on 4/7/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "util.h"
#import "KeychainWrapper.h"

@implementation util

+(void)updateKey:(NSString *)key withValue:(NSString *)value{
    //if the key is stored in keychain
    if([KeychainWrapper keychainStringFromMatchingIdentifier:key]){
        [KeychainWrapper updateKeychainValue:value forIdentifier:key];
    }
    
    //otherwise, create the key
    else{
        [KeychainWrapper createKeychainValue:value forIdentifier:key];
    }
}

+(BOOL)ifLoggedIn
{
    NSLog([NSString stringWithFormat:@"token:%@", [KeychainWrapper keychainStringFromMatchingIdentifier:@"token"]]);
    return [KeychainWrapper keychainStringFromMatchingIdentifier:@"token"] &&
    [KeychainWrapper keychainStringFromMatchingIdentifier:@"expiresIn"] &&
    [KeychainWrapper keychainStringFromMatchingIdentifier:@"refreshToken"] &&
    [[KeychainWrapper keychainStringFromMatchingIdentifier:@"expiresIn"] longLongValue] > [[NSDate date] timeIntervalSince1970];
}

+(DeviceEnum)getDeviceType {
    switch ((int)[[UIScreen mainScreen] bounds].size.height) {
        case 480:
            return IPHONE_4;
            break;
        case 568:
            return IPHONE_5;
        case 668:
            return IPHONE_6;
        case 736:
            return IPHONE_6S;
        default:
            return IPHONE_6;
    }
}

@end

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

@end
//
//  util.h
//  APIChallenge
//
//  Created by Yifan Ying on 4/7/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#ifndef APIChallenge_util_h
#define APIChallenge_util_h

#import <UIKit/UIKit.h>
#import "constants.h"

@interface util : NSObject

+ (void)updateKey:(NSString *)key withValue:(NSString *)value;
+ (BOOL)ifLoggedIn;
+ (DeviceEnum)getDeviceType;

@end


#endif

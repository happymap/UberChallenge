//
//  UserObject.h
//  APIChallenge
//
//  Created by Yifan Ying on 5/9/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserObject : NSObject {
    NSString *firstName;
    NSString *lastName;
    NSString *email;
    NSString *picture;
    NSString *uuid;
}

@property NSString *firstName;
@property NSString *lastName;
@property NSString *email;
@property NSString *picture;
@property NSString *uuid;

@end

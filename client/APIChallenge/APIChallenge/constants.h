//
//  Header.h
//  APIChallenge
//
//  Created by Yifan Ying on 4/4/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]

#define AUTH_URL @"https://login.uber.com/oauth/authorize?response_type=code&client_id=c83AN3Jf2MAwZdIwhpcpv4NNZddAs2BH"
#define CALLBACK_URL @"http://localhost:7000/submit"
#define TOKEN_URL @"https://login.uber.com/oauth/token"
#define CLIENT_SECRET @"z9UdMsZWOy9fCaxP33xPu-hiGXzFEZp8MyeziVlg"
#define CLIENT_ID @"c83AN3Jf2MAwZdIwhpcpv4NNZddAs2BH"

#define GEOCODE_KEY @"AIzaSyCE18o874T69B2mxhxHvxSQB5ySFgxvEHg"
#define GEOCODE_URL @"https://maps.googleapis.com/maps/api/geocode/json"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define MIN_TARGET_PRICE 1
#define MAX_TARGET_PRICE 100
#define DEFAULT_PRICE 20

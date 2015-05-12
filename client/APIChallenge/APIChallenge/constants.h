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

#define UBER_API_BASE_URL @"https://api.uber.com"
#define PRICE_ESTIMATE_ENDPOINT @"/v1/estimates/price"
#define USER_INFO_URL @"/v1/me"
#define PRODUCT_DETAIL_URL @"/v1/products"

#define UBER_APPSTORE_URL @"https://itunes.apple.com/us/app/uber/id368677368?mt=8"

#define PARSE_APP_ID @"P5wz7xWh6lObh25omhnaK4YElPx4OUKFNYyWKkx4"

#define PARSE_CLIENT_ID @"BbxPZXUY0t1Se3l6kZa4zW7YILZAWAxjNYij3sbM"

#define MIN_TARGET_PRICE 1
#define MAX_TARGET_PRICE 100
#define DEFAULT_PRICE 20

#define SERVER_URL @"http://52.24.179.244:8080"
#define LOGIN_URL @"/user/login"
#define REQUEST_START_URL @"/request/start"
#define REQUEST_END_URL @"/request/end"
#define REQUEST_LOCATION_URL @"/request/location"

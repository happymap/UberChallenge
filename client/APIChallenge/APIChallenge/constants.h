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
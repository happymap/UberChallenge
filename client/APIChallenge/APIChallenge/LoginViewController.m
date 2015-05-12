//
//  LoginViewController.m
//  APIChallenge
//
//  Created by Yifan Ying on 4/4/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import "LoginViewController.h"
#import "UberLoginViewController.h"
#import "constants.h"
#import "util.h"
#import "KeychainWrapper.h"
#import "UserObject.h"
#import <Parse/Parse.h>


@interface LoginViewController ()

@end

@implementation LoginViewController {
    UberLoginViewController *loginModal;
    NSOperationQueue *queue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([util ifLoggedIn]) {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    } else {
        queue = [[NSOperationQueue alloc] init];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    UIImage *background = [UIImage imageNamed: @"uber_bg_5.png"];
    UIImageView *bgView = [[UIImageView alloc] initWithImage: background];
    [self.view addSubview: bgView];
    [self.view sendSubviewToBack:bgView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)login:(id)sender {
    
    /* login webview */
    loginModal = [[UberLoginViewController alloc] init];
    [loginModal setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    loginModal.delegate = self;
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:loginModal];
    [self presentViewController:navCon animated:NO completion:nil];
}

/*UberLoginDelegate*/
-(void)authDismiss:(NSString *)authCode {
    NSString *urlString = TOKEN_URL;
    NSString *params = [[NSString alloc] initWithFormat:@"client_secret=%@&client_id=%@&grant_type=authorization_code&redirect_uri=%@&code=%@", CLIENT_SECRET, CLIENT_ID, CALLBACK_URL, authCode];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: urlString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0 && error == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSError *parseErr = nil;
                NSDictionary *res = [NSJSONSerialization JSONObjectWithData:[NSData dataWithData:data] options:NSJSONReadingMutableLeaves error:&parseErr];
                
                NSString *token = [res objectForKey:@"access_token"];
                long expiresIn = [[res objectForKey:@"expires_in"] longValue];
                NSString *refreshToken = [res objectForKey:@"refresh_token"];
                
                NSLog(@"%ld", expiresIn);
                
                NSString *infoUrl = [NSString stringWithFormat:@"%@%@", UBER_API_BASE_URL, USER_INFO_URL];
                NSMutableURLRequest *infoRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: infoUrl]];
                [infoRequest setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
                [NSURLConnection sendAsynchronousRequest:infoRequest queue:queue completionHandler:^(NSURLResponse *infoResponse, NSData *infoData, NSError *infoError) {
                    if([infoData length] > 0 && infoError == nil) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSError *infoParseErr = nil;
                            NSDictionary *res = [NSJSONSerialization JSONObjectWithData:[NSData dataWithData:infoData] options:NSJSONReadingMutableLeaves error:&infoParseErr];
                            NSString *email = [res objectForKey:@"email"];
                            NSString *firstName = [res objectForKey:@"first_name"];
                            NSString *lastName = [res objectForKey:@"last_name"];
                            NSString *picture = [res objectForKey:@"picture"];
                            NSString *uuid = [res objectForKey:@"uuid"];
                            
                            //create user object
                            UserObject *user = [[UserObject alloc] init];
                            [user setEmail:email];
                            [user setFirstName:firstName];
                            [user setLastName:lastName];
                            [user setPicture: picture];
                            [user setUuid:uuid];
                            
                            // save token, expires into keychain
                            [util updateKey:@"token" withValue:token];
                            long expiredDate = expiresIn + (long)[[NSDate date] timeIntervalSince1970];
                            [util updateKey:@"expiresIn" withValue: [NSString stringWithFormat:@"%ld", expiredDate]];
                            [util updateKey:@"refreshToken" withValue:refreshToken];
                            
                            //login our system asynchronously
                            [self loginSystem:user token:token refreshToken:refreshToken expires:expiredDate];
                        }];
                    } else {
                        NSLog([infoError localizedDescription]);
                    }
                }];
            }];
        } else {
            [loginModal dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

/* Log in our system */
-(void)loginSystem: (UserObject *)userObject token:(NSString *)token refreshToken:(NSString *)refreshToken expires:(long)expiredDate  {
    NSString *signupParams = [NSString stringWithFormat:@"first_name=%@&last_name=%@&email=%@&picture=%@&uber_uuid=%@&token=%@&refresh_token=%@&token_expires=%ld", userObject.firstName, userObject.lastName, userObject.email, userObject.picture, userObject.uuid, token, refreshToken, expiredDate];
    NSString *url = [NSString stringWithFormat:@"%@%@", SERVER_URL, LOGIN_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *requestData = [signupParams dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    [request setValue:[NSString stringWithFormat:@"%u", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    NSLog(signupParams);
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0 && error == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                int userId = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
                [util updateKey:@"userId" withValue:[NSString stringWithFormat:@"%d", userId]];
                NSString *userIdStr = [NSString stringWithFormat:@"%d", userId];
                [util updateKey:@"userId" withValue:userIdStr];
                NSLog(@"new userId: %d", userId);
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                NSString *channelId = [NSString stringWithFormat:@"userId-%@", userIdStr];
                [currentInstallation addUniqueObject:channelId forKey:@"channels"];
                [currentInstallation saveInBackground];
                
                //login success, navigate to next page
                [loginModal dismissViewControllerAnimated:YES completion:nil];
                [self performSegueWithIdentifier:@"loginSegue" sender:self];
            }];

        } else {
            NSLog([error localizedDescription]);
        }
    }];
}

@end

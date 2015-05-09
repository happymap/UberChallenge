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
                
                [util updateKey:@"token" withValue:token];
                [util updateKey:@"expiresIn" withValue:[[NSNumber numberWithLong:expiresIn + [[NSDate date] timeIntervalSince1970]] stringValue]];
                [util updateKey:@"refreshToken" withValue:refreshToken];
                
                [loginModal dismissViewControllerAnimated:YES completion:nil];
                [self performSegueWithIdentifier:@"loginSegue" sender:self];
            }];
        } else {
            [loginModal dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

@end

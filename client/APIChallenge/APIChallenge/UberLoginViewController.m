//
//  UberLoginViewController.m
//  APIChallenge
//
//  Created by Yifan Ying on 4/4/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import "UberLoginViewController.h"
#import "constants.h"
#import "LoginViewController.h"

@interface UberLoginViewController ()

@end

@implementation UberLoginViewController

@synthesize delegate, webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStyleBordered target:self
                                                                            action:@selector(cancelAction:)];
    NSURL *nsUrl = [NSURL URLWithString:AUTH_URL];
    NSURLRequest *request= [NSURLRequest requestWithURL:nsUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *currentUrl = [[request URL] absoluteString];
    currentUrl = [NSString stringWithCString:[currentUrl cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    if([currentUrl rangeOfString:CALLBACK_URL].location != NSNotFound) {
        NSArray *tempArray = [currentUrl componentsSeparatedByString:@"code="];
        NSString *authCode = [tempArray objectAtIndex:1];
        [delegate authDismiss: authCode];
        return false;
    }
    return true;
}

-(IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

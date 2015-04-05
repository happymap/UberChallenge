//
//  UberLoginViewController.m
//  APIChallenge
//
//  Created by Yifan Ying on 4/4/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import "UberLoginViewController.h"
#import "constants.h"

@interface UberLoginViewController ()

@end

@implementation UberLoginViewController

@synthesize delegate, webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
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
    
    return false;
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

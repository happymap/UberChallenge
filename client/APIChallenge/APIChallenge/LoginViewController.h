//
//  LoginViewController.h
//  APIChallenge
//
//  Created by Yifan Ying on 4/4/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UberLoginDelegate

-(void)authDismiss;

@end

@interface LoginViewController : UIViewController <UberLoginDelegate>

@property (nonatomic, strong) IBOutlet UIButton *loginBtn;

- (IBAction)login:(id)sender;

@end

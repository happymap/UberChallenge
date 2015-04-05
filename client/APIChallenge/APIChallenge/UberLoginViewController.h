//
//  UberLoginViewController.h
//  APIChallenge
//
//  Created by Yifan Ying on 4/4/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UberLoginDelegate;

@interface UberLoginViewController : UIViewController <UIWebViewDelegate> {
    id<UberLoginDelegate> delegate;
}

@property (nonatomic, strong) id <UberLoginDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIWebView *webView;

-(IBAction)cancelAction:(id)sender;

@end

//
//  DashboardViewController.h
//  APIChallenge
//
//  Created by Yifan Ying on 4/19/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property int targetPrice;

@property (nonatomic, strong) IBOutlet UILabel *priceLabel;

@end

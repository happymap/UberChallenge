//
//  DashboardViewController.h
//  APIChallenge
//
//  Created by Yifan Ying on 4/19/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DashboardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property int targetPrice;
@property float targetLat;
@property float targetLng;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UITableView *table;

- (IBAction)stop:(id)sender;

@end
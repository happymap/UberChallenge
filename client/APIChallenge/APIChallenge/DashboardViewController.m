//
//  DashboardViewController.m
//  APIChallenge
//
//  Created by Yifan Ying on 4/19/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import "DashboardViewController.h"
#import "productCell.h"
#import "constants.h"
#import "KeychainWrapper.h"

@interface DashboardViewController ()

@end

@implementation DashboardViewController {
    NSOperationQueue *queue;
    CLLocation *currentLocation;
    NSArray *results;
}

@synthesize targetLat, targetLng;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // request queue
    queue = [[NSOperationQueue alloc] init];
    
    //set target price
    [self.priceLabel setText:[NSString stringWithFormat:@"$%d", self.targetPrice]];
    
    //get user location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if(IS_OS_8_OR_LATER){
        NSUInteger code = [CLLocationManager authorizationStatus];
        if (code == kCLAuthorizationStatusNotDetermined && ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [self.locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [self.locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    [self.locationManager startMonitoringSignificantLocationChanges];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 30; //meters

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"productCell";
    
    productCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:identifier owner:nil options:nil];
        cell = (productCell *)[nib objectAtIndex:0];
    }
    
    [cell.priceLbl setText:[[results objectAtIndex:indexPath.row] objectForKey:@"estimate"]];
    [cell.nameLbl setText:[[results objectAtIndex:indexPath.row] objectForKey:@"display_name"]];
    [cell.distanceLbl setText:[NSString stringWithFormat:@"%0.2fm", [[[results objectAtIndex:indexPath.row] objectForKey:@"distance"] floatValue]]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (IBAction)stop:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    currentLocation = newLocation;
    NSLog(@"location updated: %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    
    NSString *params = [[NSString stringWithFormat:@"start_latitude=%f&start_longitude=%f&end_latitude=%f&end_longitude=%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, targetLat, targetLng] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@", UBER_API_BASE_URL, PRICE_ESTIMATE_ENDPOINT, params]]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [KeychainWrapper keychainStringFromMatchingIdentifier:@"token"]] forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0 && error == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog([NSString stringWithFormat:@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]);
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSError *parseErr = nil;
                    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:[NSData dataWithData:data] options:NSJSONReadingMutableLeaves error:&parseErr];
                    results = [res objectForKey:@"prices"];
                    [self.table reloadData];
                }];
            }];
        } else {
            NSLog([error localizedDescription]);
        }
    }];
}

@end

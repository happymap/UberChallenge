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
    NSString *bestProductId;
    long lastTimeLocationUpdated;
}

@synthesize targetLat, targetLng, requestId, targetPrice, mode;

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
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 30; //meters
    
    //set stop btn title
    if (mode == BOOK) {
        [self.stopButton setTitle:@"Reset My Request" forState:UIControlStateNormal];
    }
    
    //init variables
    lastTimeLocationUpdated = -1l;
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
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:identifier owner:nil options:nil];
        cell = (productCell *)[nib objectAtIndex:0];
        [cell addGestureRecognizer:singleFingerTap];
    }
    
    [cell.priceLbl setText:[[results objectAtIndex:indexPath.row] objectForKey:@"estimate"]];
    [cell.nameLbl setText:[[results objectAtIndex:indexPath.row] objectForKey:@"display_name"]];
    float surge_multiplier = [[[results objectAtIndex:indexPath.row] objectForKey:@"surge_multiplier"] floatValue];
    [cell.surgeMultiplierLbl setText:[NSString stringWithFormat:@"Surge Multiplier: ×%.1f", surge_multiplier]];
    [cell setTag:indexPath.row];
//    [cell.distanceLbl setText:[NSString stringWithFormat:@"%0.2fm", [[[results objectAtIndex:indexPath.row] objectForKey:@"distance"] floatValue]]];
    
    if (([[results objectAtIndex:indexPath.row] objectForKey:@"low_estimate"] != nil &&
        [[results objectAtIndex:indexPath.row] objectForKey:@"low_estimate"] != [NSNull null] &&
        [[[results objectAtIndex:indexPath.row] objectForKey:@"low_estimate"] intValue] > self.targetPrice) ||
        ([[results objectAtIndex:indexPath.row] objectForKey:@"low_estimate"] == nil ||
         [[results objectAtIndex:indexPath.row] objectForKey:@"low_estimate"] == [NSNull null])) {
            
        //grey out options more expensive that target price
        [cell.priceLbl setTextColor:[UIColor lightGrayColor]];
        [cell.nameLbl setTextColor:[UIColor lightGrayColor]];
        [cell.surgeMultiplierLbl setTextColor:[UIColor lightGrayColor]];
    }
    
    if ([[results objectAtIndex:indexPath.row] objectForKey:@"product_id"] == bestProductId) {
        [cell.bestPriceLbl setHidden:NO];
    }
    
    NSString *productDetailsUrl = [NSString stringWithFormat:@"%@%@/%@", UBER_API_BASE_URL, PRODUCT_DETAIL_URL, [[results objectAtIndex:indexPath.row] objectForKey:@"product_id"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:productDetailsUrl]];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", [KeychainWrapper keychainStringFromMatchingIdentifier:@"token"]] forHTTPHeaderField:@"Authorization"];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0 && error == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSError *parseErr = nil;
                NSDictionary *res = [NSJSONSerialization JSONObjectWithData:[NSData dataWithData:data] options:NSJSONReadingMutableLeaves error:&parseErr];
                NSString *imgUrl = [res objectForKey:@"image"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
                    if (imgData) {
                        UIImage *image = [UIImage imageWithData:imgData];
                        if (image) {
                            productCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                            [updateCell setProductImage:image];
                        }
                    }
                });
            }];
        } else {
            NSLog([error localizedDescription]);
        }
    }];
    
    return cell;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    UIView *view = recognizer.view; //cast pointer to the derived class if needed
    NSLog(@"%d", view.tag);
    
    //update request status
    NSString *product_id = [[results objectAtIndex:view.tag] objectForKey:@"product_id"];
    
    //if mode is BOOK, no need to update request
    if (mode == BOOK) {
        [self placeUberOrder:product_id];
        return;
    }
    
    NSObject *raw_low_estimate = [[results objectAtIndex:view.tag] objectForKey:@"low_estimate"];
    int low_estimate = -1;
    if (raw_low_estimate != nil && raw_low_estimate != [NSNull null]) {
        low_estimate = [[[results objectAtIndex:view.tag] objectForKey:@"low_estimate"] intValue];
    }
    
    NSString *params = [NSString stringWithFormat:@"request_id=%ld&end_price_estimate=%d&product_id=%@", requestId,  low_estimate, product_id];
    NSString *url = [NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_END_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *requestData = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    [request setValue:[NSString stringWithFormat:@"%u", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0 && error == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                int result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
                NSLog(@"request id: %d", result);
                [self placeUberOrder:product_id];
            }];
        } else {
            NSLog([error localizedDescription]);
        }
    }];
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (IBAction)stop:(id)sender {
    if (mode == BOOK) {
        [queue cancelAllOperations];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSString *params = [NSString stringWithFormat:@"request_id=%ld", requestId];
    NSString *url = [NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_CANCEL_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSData *requestData = [params dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:requestData];
    [request setValue:[NSString stringWithFormat:@"%u", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0 && error == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                int result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
                NSLog(@"request id: %d", result);
                [queue cancelAllOperations];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            NSLog([error localizedDescription]);
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    currentLocation = newLocation;
    NSLog(@"location updated: %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    
    long now = [[NSDate date] timeIntervalSince1970];
    if (now - lastTimeLocationUpdated < 60) {
        return;
    } else {
        lastTimeLocationUpdated = now;
    }
    
    //update the list
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
                    [self analyzeResults];
                    [self.table reloadData];
                }];
            }];
        } else {
            NSLog([NSString stringWithFormat:@"response code: %d", [(NSHTTPURLResponse *)response statusCode]]);
            NSLog([error localizedDescription]);
        }
    }];
    
    
    //update the current location on server side
    NSString *params2 = [NSString stringWithFormat:@"request_id=%ld&current_latitude=%f&current_longitude=%f", requestId, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    NSString *url2 = [NSString stringWithFormat:@"%@%@", SERVER_URL, REQUEST_LOCATION_URL];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url2]];
    NSData *data2 = [params2 dataUsingEncoding:NSUTF8StringEncoding];
    [request2 setHTTPMethod:@"POST"];
    [request2 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request2 setHTTPBody:data2];
    [request2 setValue:[NSString stringWithFormat:@"%u", [data2 length]] forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection sendAsynchronousRequest:request2 queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if([data length] > 0 && error == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                int result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
                NSLog(@"request id: %d", result);
            }];
        } else {
            NSLog([error localizedDescription]);
        }
    }];
}

- (void)placeUberOrder:(NSString *)product_id {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        // Do something awesome - the app is installed! Launch App.
        
        NSString *uberUrl = [NSString stringWithFormat:@"uber://?client_id=%@&action=setPickup&pickup[latitude]=%0.2fm&pickup[longitude]=%0.2fm&dropoff[latitude]=%0.2fm&dropoff[longitude]=%0.2fm&product_id=%@", CLIENT_ID, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, targetLat, targetLng, product_id];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:uberUrl]];
        
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UBER_APPSTORE_URL]];
        // No Uber app! Open Mobile Website.
    }
}

- (void)analyzeResults {
    int lowEstimate = INT_MAX;
    NSString *product = nil;
    for(int i = 0; i < [results count]; i++) {
        NSObject *lowPriceObject = [[results objectAtIndex:i] objectForKey:@"low_estimate"];
        if (lowPriceObject != nil && lowPriceObject != [NSNull null]) {
            int price = [[[results objectAtIndex:i] objectForKey:@"low_estimate"] intValue];
            if (price < lowEstimate) {
                lowEstimate = price;
                product = [[results objectAtIndex:i] objectForKey:@"product_id"];
            }
        }
    }
    bestProductId = product;
}


@end

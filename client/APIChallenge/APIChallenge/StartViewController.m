//
//  StartViewController.m
//  APIChallenge
//
//  Created by Yifan Ying on 4/9/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import "StartViewController.h"
#import "DashboardViewController.h"
#import "constants.h"
#import "KeychainWrapper.h"

@interface StartViewController ()

@end

@implementation StartViewController {
    NSOperationQueue *queue;
    float targetLat;
    float targetLng;
    CLLocation *currentLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // request queue
    queue = [[NSOperationQueue alloc] init];
    
    // localtion
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
    
    // map
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.005f;
    region.span.longitudeDelta = 0.005f;
    [self.mapView setRegion:region animated:YES];
    
    //reset
    destination = nil;
    targetPrice = DEFAULT_PRICE;
    [self.priceLabel setText:[NSString stringWithFormat:@"$%d", DEFAULT_PRICE]];
    [self.priceSlider setValue:(float)(DEFAULT_PRICE - MIN_TARGET_PRICE)/(MAX_TARGET_PRICE - MIN_TARGET_PRICE)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)search:(id)sender {
    //dismiss keyboard
    [self.addressField resignFirstResponder];
    
    destination = [self.addressField text];
    
    if ([destination length] > 0) {
        NSString *params = [[NSString stringWithFormat:@"address=%@&sensor=false&key=%@", destination, GEOCODE_KEY] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", GEOCODE_URL, params]]];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if([data length] > 0 && error == nil) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSError *parseErr = nil;
                    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:[NSData dataWithData:data] options:NSJSONReadingMutableLeaves error:&parseErr];
                    NSArray *results = [res objectForKey:@"results"];
                    if ([results count] > 0) {
                        NSDictionary *location = [[[results objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
                        targetLat = [[location objectForKey:@"lat"] floatValue];
                        targetLng = [[location objectForKey:@"lng"] floatValue];
                        NSLog(@"lat: %f, lng: %f", targetLat, targetLng);
                        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake((CLLocationDegrees)targetLat, (CLLocationDegrees)targetLng);
                        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 800, 800);
                        [self.mapView setRegion:region animated:YES];
                        
                        // Add an annotation
                        [self.mapView removeAnnotations:self.mapView.annotations];
                        MKPointAnnotation *destinationPoint = [[MKPointAnnotation alloc] init];
                        destinationPoint.coordinate = coordinate;
                        destinationPoint.title = destination;
                        [self.mapView addAnnotation:destinationPoint];
                        
                        //update recommended price
                        [self updateRecomPrice];
                    }
                }];
            } else {
                NSLog(@"No address Found");
                
            }
        }];
    }
}

- (IBAction)start:(id)sender {
    if (destination != nil) {
        [self performSegueWithIdentifier:@"startSegue" sender:self];
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (destination == nil) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    }
}

- (IBAction)slidePrice:(id)sender {
    targetPrice = (int)(MIN_TARGET_PRICE + (MAX_TARGET_PRICE - MIN_TARGET_PRICE)*self.priceSlider.value);
    [self.priceLabel setText:[NSString stringWithFormat:@"$%d", targetPrice]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"startSegue"]) {
        DashboardViewController *vc = [segue destinationViewController];
        [vc setTargetPrice:targetPrice];
        [vc setTargetLat:targetLat];
        [vc setTargetLng:targetLng];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
}

-(void)updateRecomPrice {
    if (currentLocation != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *params = [[NSString stringWithFormat:@"start_latitude=%f&start_longitude=%f&end_latitude=%f&end_longitude=%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, targetLat, targetLng] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSMutableURLRequest *priceRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?%@", UBER_API_BASE_URL, PRICE_ESTIMATE_ENDPOINT, params]]];
            [priceRequest setValue:[NSString stringWithFormat:@"Bearer %@", [KeychainWrapper keychainStringFromMatchingIdentifier:@"token"]] forHTTPHeaderField:@"Authorization"];
            [NSURLConnection sendAsynchronousRequest:priceRequest queue:queue completionHandler:^(NSURLResponse *priceResponse, NSData *priceData, NSError *priceError) {
                if([priceData length] > 0 && priceError == nil) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSError *priceErr = nil;
                        NSDictionary *priceRes = [NSJSONSerialization JSONObjectWithData:[NSData dataWithData:priceData] options:NSJSONReadingMutableLeaves error:&priceErr];
                        NSArray *priceResults = [priceRes objectForKey:@"prices"];
                        if([priceResults count] > 0) {
                            NSObject *minPrice = [[priceResults objectAtIndex:0] objectForKey:@"low_estimate"];
                            if (minPrice != nil && minPrice != [NSNull null]) {
                                [self.recomPriceLbl setText:[NSString stringWithFormat:@"$%@", (NSString *)minPrice]];
                            }
                        }
                    }];
                }
            }];
        });
    }
}

-(IBAction)openMenu:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Log Out", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            NSLog(@"logging out");
            [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"token"];
            [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"expiresIn"];
            [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"refreshToken"];
            [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"userId"];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}



@end

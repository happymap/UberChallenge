//
//  StartViewController.h
//  APIChallenge
//
//  Created by Yifan Ying on 4/9/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface StartViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    NSString *destination;
    int targetPrice;
    CLLocation *currentLocation;
    CLLocation *targetLocation;
}

@property (nonatomic, strong) IBOutlet UIButton *searchBtn;
@property (nonatomic, strong) IBOutlet UITextField *addressField;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet UISlider *priceSlider;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;

- (IBAction)search:(id)sender;
- (IBAction)slidePrice:(id)sender;
- (IBAction)start:(id)sender;

@end

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
}

@property (nonatomic, strong) IBOutlet UIButton *searchBtn;
@property (nonatomic, strong) IBOutlet UITextField *addressField;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (IBAction)search:(id)sender;

@end

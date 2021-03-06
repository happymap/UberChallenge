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

@interface StartViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    NSString *destination;
    int targetPrice;
}

@property (nonatomic, strong) IBOutlet UIButton *searchBtn;
@property (nonatomic, strong) IBOutlet UITextField *addressField;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet UISlider *priceSlider;
@property (nonatomic, strong) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) IBOutlet UILabel *recomPriceLbl;
@property (nonatomic, strong) IBOutlet UILabel *lowPriceLbl;
@property (nonatomic, strong) IBOutlet UIButton *menuBtn;
@property (nonatomic, strong) IBOutlet UIButton *startBtn;

- (IBAction)search:(id)sender;
- (IBAction)slidePrice:(id)sender;
- (IBAction)start:(id)sender;
- (IBAction)openMenu:(id)sender;

@end

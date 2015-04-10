//
//  StartViewController.m
//  APIChallenge
//
//  Created by Yifan Ying on 4/9/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import "StartViewController.h"
#import "constants.h"

@interface StartViewController ()

@end

@implementation StartViewController {
    NSOperationQueue *queue;    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    queue = [[NSOperationQueue alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)search:(id)sender {
    NSString *address = [self.addressField text];
    
    if ([address length] > 0) {
        NSString *params = [[NSString stringWithFormat:@"address=%@&sensor=false&key=%@", address, GEOCODE_KEY] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", GEOCODE_URL, params]]];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if([data length] > 0 && error == nil) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSError *parseErr = nil;
                    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:[NSData dataWithData:data] options:NSJSONReadingMutableLeaves error:&parseErr];
                    NSArray *results = [res objectForKey:@"results"];
                    if ([results count] > 0) {
                        NSDictionary *location = [[[results objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
                        float lat = [[location objectForKey:@"lat"] floatValue];
                        float lng = [[location objectForKey:@"lng"] floatValue];
                        NSLog(@"lat: %f, lng: %f", lat, lng);
                    }

                }];
            } else {
                NSLog(@"No address Found");
            }
        }];
    }
}

@end

//
//  productCell.h
//  APIChallenge
//
//  Created by Yifan Ying on 4/20/15.
//  Copyright (c) 2015 Yifan Ying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface productCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *priceLbl;
@property (nonatomic, strong) IBOutlet UILabel *nameLbl;
@property (nonatomic, strong) IBOutlet UILabel *distanceLbl;
@property (nonatomic, strong) IBOutlet UIImageView *productImg;
@property (nonatomic, strong) IBOutlet UILabel *surgeMultiplierLbl;

-(void)setProductImage:(UIImage *)image;

@end

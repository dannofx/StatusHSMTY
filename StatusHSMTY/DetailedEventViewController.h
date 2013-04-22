//
//  DetailedEventViewController.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface DetailedEventViewController : UIViewController

@property (nonatomic,retain) IBOutlet UILabel * name_label;
@property (nonatomic,retain) IBOutlet UILabel * dateInit_label;
@property (nonatomic,retain) IBOutlet UILabel * description_label;
@property (nonatomic,retain) IBOutlet UIImageView * imageView;
@property (nonatomic,retain) IBOutlet UIImageView * checkImageView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView * imageActivityIndicator;

@property (nonatomic,weak)Event * event;

@end

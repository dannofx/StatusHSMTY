//
//  StatusViewController.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSMTYViewController.h"
#import "HSLabel.h"

@interface StatusViewController : HSMTYViewController<UIActionSheetDelegate>;

@property (nonatomic,retain) IBOutlet UILabel* statusLabel;
@property (nonatomic,retain) IBOutlet UILabel * statusMessageLabel;
@property (nonatomic,retain) IBOutlet HSLabel * addressLabel;
@property (nonatomic,retain) IBOutlet UILabel *spaceNameLabel;
@property (nonatomic,retain) IBOutlet UILabel *epochLabel;
@property (nonatomic,retain) IBOutlet UIImageView * logoImageView;
@property (nonatomic,retain) IBOutlet UIImageView * statusImageView;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView * logo_activityIndicator;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView * status_activityIndicator;



-(IBAction)showLocationInMap:(id)sender;
-(IBAction)showWebSite:(id)sender;



@end

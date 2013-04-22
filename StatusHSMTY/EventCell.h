//
//  EventCell.h
//  StatusHSMTY
//
//  Created by Danno on 2/22/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DownloadRequest.h"

@interface EventCell : UITableViewCell

@property(nonatomic,retain)IBOutlet UILabel * eventNameLabel;
@property(nonatomic,retain)IBOutlet UILabel * dateLabel;
@property (nonatomic,retain) IBOutlet UIImageView * imageView;
@property (nonatomic,retain) NSString * imagePath;

-(void)imageDownloadFinishedSuccessfully:(DownloadRequest *)request;
-(void)addBorder;

@end

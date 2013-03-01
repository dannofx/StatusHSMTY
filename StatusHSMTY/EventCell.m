//
//  EventCell.m
//  StatusHSMTY
//
//  Created by Danno on 2/22/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "EventCell.h"
#import "NSDate+HSMTYFormats.h"


@implementation EventCell

@synthesize eventNameLabel;
@synthesize dateLabel;
@synthesize imageView;
@synthesize imagePath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDate:(NSDate *)date{
    
    NSString * format=NSLocalizedString(@"Start:", @"Start");
    NSString * dateString=(date!=nil)?[date stringDateWithShortFormat]:NSLocalizedString(@"Date no available",@"Fecha no disponible");
    self.dateLabel.text=[NSString stringWithFormat:format,dateString];
}

-(void)setTimeHumanValue:(NSString *)time
{
    NSString * timeString=NSLocalizedString(@"Since:", @"Since");
    self.dateLabel.text=[timeString stringByAppendingString:time];
}


-(void)imageDownloadFinishedSuccessfully:(DownloadRequest *)request
{
    self.imageView.image=[UIImage imageWithContentsOfFile:self.imagePath];
}

@end

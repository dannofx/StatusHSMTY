//
//  EventCell.m
//  StatusHSMTY
//
//  Created by Danno on 2/22/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "EventCell.h"
#import "NSDate+HSMTYFormats.h"

@interface EventCell()
{
    BOOL borderAdded;
}

@end
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
-(id)initWithCoder:(NSCoder *)aDecoder
{ self = [super initWithCoder:aDecoder];
    if (self) {
        borderAdded=FALSE;
    }
    return self;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




-(void)imageDownloadFinishedSuccessfully:(DownloadRequest *)request
{
    self.imageView.image=[UIImage imageWithContentsOfFile:self.imagePath];
}
-(void)addBorder
{
    if(!borderAdded)
    {
        borderAdded=YES;
        self.imageView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
        self.imageView.layer.borderWidth=1.3;
    }
    
}

@end

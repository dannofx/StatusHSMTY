//
//  SpaceSelectionCell.m
//  StatusHSMTY
//
//  Created by Danno on 3/4/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "SpaceSelectionCell.h"

@implementation SpaceSelectionCell

@synthesize delegate;
@synthesize followingSwitch;
@synthesize selectionImageView;
@synthesize spaceNameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //[self initControls];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //[self initControls];

    }
    return self;
}


-(IBAction)switchValueChanged:(id)sender
{
    if(self.delegate)
    {
        NSIndexPath * indexPath=[(UITableView *)self.superview indexPathForCell:self];
        [self.delegate cellAtIndex:indexPath changeToValue:followingSwitch.on];
    }
}


-(void)configureForAlerts:(BOOL)manageAlerts
{
    self.selectionImageView.hidden=manageAlerts;
    self.followingSwitch.hidden=!manageAlerts;

    
}
-(void)setAsSelectedSpace:(BOOL)selected
{
    self.selectionImageView.image=(selected?[UIImage imageNamed:@"check.png"]:nil);
}

@end

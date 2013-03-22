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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSwitch];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSwitch];

    }
    return self;
}

-(void)addSwitch
{
    followingSwitch=[[UISwitch alloc] initWithFrame:CGRectZero];
    [followingSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.accessoryView=followingSwitch;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)switchValueChanged:(id)sender
{

    if(self.delegate)
    {
        NSIndexPath * indexPath=[(UITableView *)self.superview indexPathForCell:self];
        [self.delegate cellAtIndex:indexPath changeToValue:followingSwitch.on];
    }
}

@end

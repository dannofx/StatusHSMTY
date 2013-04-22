//
//  ContactCell.m
//  StatusHSMTY
//
//  Created by Danno on 22/04/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "ContactCell.h"

@implementation ContactCell
@synthesize contactDelegate;
@synthesize index;

@synthesize contactTypeLabel;
@synthesize contactInfoLabel;
@synthesize contactImageView;
@synthesize specialActionButton;
@synthesize regularActionButton;
@synthesize specialAction=_specialAction;

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

-(void)setSpecialAction:(SpecialAction)specialAction
{
    _specialAction=specialAction;
    self.specialActionButton.hidden=(specialAction==SpecialActionNone);
    
    
}

-(IBAction)copyAction:(id)sender
{
    if(self.contactDelegate&&self.index)
    {
        [self.contactDelegate cellRequestForCopy:self.index];
    }
    
}
-(IBAction)launchUserAction:(id)sender
{
    if(self.contactDelegate&&self.index)
    {
        [self.contactDelegate cellRequestForUserAction:self.index];
    }
}

@end

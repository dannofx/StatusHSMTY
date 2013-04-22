//
//  HSLabel.m
//  StatusHSMTY
//
//  Created by Danno on 21/04/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "HSLabel.h"

@implementation HSLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawTextInRect:(CGRect)rect
{
    CGRect r = [self textRectForBounds:rect
                limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:r];
}


@end

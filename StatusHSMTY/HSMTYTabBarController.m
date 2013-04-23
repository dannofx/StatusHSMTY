//
//  HSMTYTabBarController.m
//  StatusHSMTY
//
//  Created by Danno on 2/28/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "HSMTYTabBarController.h"
#import "ContentManager.h"
#import "SpaceSelectorNavigationController.h"

@interface HSMTYTabBarController ()

@end

@implementation HSMTYTabBarController


-(void)viewDidLoad
{
    [super viewDidLoad];
    [ContentManager contentManager].selectionDelegate=self;
    
}

#pragma mark - HackerSpaceSelectionDelegate
-(void)requestForhackerSpaceSelection
{
    SpaceSelectorNavigationController * spaceController=[self.storyboard instantiateViewControllerWithIdentifier:@"spaceSelector"];
    [self presentViewController:spaceController animated:YES completion:nil];
}

-(BOOL)shouldAutorotate
{
    return NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation==UIInterfaceOrientationPortrait;
}
@end

//
//  AlertManagementSegue.m
//  StatusHSMTY
//
//  Created by Danno on 22/04/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "AlertManagementSegue.h"
#import "SpaceSelectorNavigationController.h"
#import "SpaceSelectorController.h"
@implementation AlertManagementSegue

-(void)perform
{
    UIViewController * sourceController=self.sourceViewController;
    SpaceSelectorNavigationController * navController=self.destinationViewController;
    SpaceSelectorController * selectorController=[[navController viewControllers] objectAtIndex:0];
    selectorController.selectionType=SelectionTypeAlert;
    selectorController.title=@"Manage alerts";
    [sourceController presentViewController:navController animated:YES completion:nil];
}

@end

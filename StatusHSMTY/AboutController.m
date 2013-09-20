//
//  AboutController.m
//  StatusHSMTY
//
//  Created by Danno on 23/04/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "AboutController.h"
#import "HSWebViewController.h"
#import "GlobalConstants.h"

@interface AboutController ()
{
    NSString * siteToOpen;
    UIActionSheet * actionSheet;
}

@end

@implementation AboutController
@synthesize versionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.versionLabel.text= [NSString stringWithFormat: NSLocalizedString( @"Version: %@",@"Version: %@"),[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)designerSite:(id)sender
{
    siteToOpen=@"http://www.thepamrdz.com/";
    [self launchActionSheet];
}
-(IBAction)asihttpSite:(id)sender
{
    siteToOpen=@"http://allseeing-i.com/ASIHTTPRequest/";
    [self launchActionSheet];

}
-(IBAction)stkeychainSite:(id)sender
{
    siteToOpen=@"https://github.com/ldandersen/STUtils";
    [self launchActionSheet];
}
-(IBAction)hudSite:(id)sender
{
    siteToOpen=@"https://github.com/jdg/MBProgressHUD";
    [self launchActionSheet];
}

-(void)launchActionSheet
{
    NSString *actionSheetTitle = NSLocalizedString(@"What do you want to do?",@"What do you want to do?"); //Action Sheet Title
    NSString *cancelTitle = NSLocalizedString(@"Cancel",@"Cancel"); //Action Sheet Button Titles
    NSString *openWebTitle =NSLocalizedString( @"Open web page",@"Open web page");
    NSString *copyToCBTitle=NSLocalizedString( @"Copy to clipboard",@"Copy to clipboard");
    
    if(actionSheet==nil)
    {
        actionSheet = [[UIActionSheet alloc]
                       initWithTitle:actionSheetTitle
                       delegate:self
                       cancelButtonTitle:cancelTitle
                       destructiveButtonTitle:nil
                       otherButtonTitles:openWebTitle,copyToCBTitle, nil];
        actionSheet.delegate=self;
    }
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 if([segue.identifier isEqualToString:WEBVIEW_SEGUE])
    {
        HSWebViewController * hswebController=segue.destinationViewController;
        hswebController.urlAddress=siteToOpen;
        
    }
}

#pragma mark - Action Sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (buttonIndex) {
        case 0:
        {
            [self performSegueWithIdentifier:WEBVIEW_SEGUE sender:self];
        }
            break;
        case 1:
        default:
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = siteToOpen;
        }
            break;
    }
    
}

@end

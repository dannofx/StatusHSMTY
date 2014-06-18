//
//  StatusViewController.m
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "StatusViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HackerSpaceInfo.h"
#import "NSDate+HSMTYFormats.h"
#import "ContentManager.h"
#import "DownloadRequest.h"
#import "GlobalConstants.h"
#import "Notifications.h"
#import "Configuration.h"
#import "Reachability.h"
#import "HackerMapViewController.h"
#import "HSWebViewController.h"
#import <MapKit/MapKit.h>

#ifndef STATUSIDEN
#define STATUSIDEN
#define INDEX_WEBVIEW 2
#define MAP_SEGUE @"showmapssegue"
#endif

@interface StatusViewController ()
{
    HackerSpaceInfo * hackerSpace;
    UIActionSheet *actionSheet;
}

-(void)setLogoViewInLodingState:(BOOL)loadingState;
-(void)setStatusViewInLodingState:(BOOL)loadingState;
@end

@implementation StatusViewController
@synthesize statusLabel;
@synthesize addressLabel;
@synthesize spaceNameLabel;
@synthesize epochLabel;
@synthesize logoImageView;
@synthesize statusImageView;
@synthesize logo_activityIndicator;
@synthesize status_activityIndicator;
@synthesize statusMessageLabel;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLogoViewInLodingState:NO];
    [self setStatusViewInLodingState:NO];
    hackerSpace=[[ContentManager contentManager] spaceInfoForName:[Configuration currentSpaceName]];
    [self performLoadOperations];
    self.title=NSLocalizedString(@"Status",@"Status");
   
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.logoImageView.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    self.logoImageView.layer.borderWidth=1.0;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)performLoadOperations
{
    if(hackerSpace!=nil&&hackerSpace.url!=nil)
    {
        [self loadDataInControls];
    }else
    {
        if([Reachability reachabilityForInternetConnection])
        {
            [[ContentManager contentManager] launchContentUpdate];
        }
    }
    
}

-(void)loadDataInControls{
    self.statusLabel.text=hackerSpace.open?NSLocalizedString(@"Open", @"Open"):NSLocalizedString(@"Closed", @"Closed");
    self.addressLabel.text=hackerSpace.address;
    self.spaceNameLabel.text=hackerSpace.spaceName;
    self.epochLabel.text=[hackerSpace.lastChangeDate stringDateWithCompleteFormat];
    self.statusMessageLabel.text=(hackerSpace.status)?hackerSpace.status:NSLocalizedString(@"No available", @"No available");
    
    UIImage * logoImage=hackerSpace.iconImage;
    if(logoImage==nil)
    {
        ContentManager * contentManager=[ContentManager contentManager];
        DownloadRequest * request=[DownloadRequest requestForFileAt:hackerSpace.iconURL savingOn:hackerSpace.iconPath];
        request.downloadObserver=self;
        request.tag=DOWNLOAD_TAG_LOGOIMAGE;
        request.finishObserverSelector=@selector(imageDownloadFinishedSuccessfully:);
        request.failObserverSelector=@selector(imageDownloadFailed:);
        [contentManager addDownloadItemRequest:request];
        [self setLogoViewInLodingState:YES];
        self.logoImageView.image=nil;
        
    }else{
        self.logoImageView.image=logoImage;
        [self setLogoViewInLodingState:NO];
    }
    
    BOOL isOpen=hackerSpace.open;
    UIImage * closedImage=hackerSpace.closeImage;
    if(closedImage==nil)
    {
        ContentManager * contentManager=[ContentManager contentManager];
        DownloadRequest * request=[DownloadRequest requestForFileAt:hackerSpace.closedIconURL savingOn:hackerSpace.closedIconPath];
        request.downloadObserver=self;
        request.tag=DOWNLOAD_TAG_CLOSEDIMAGE;
        request.finishObserverSelector=@selector(imageDownloadFinishedSuccessfully:);
        request.failObserverSelector=@selector(imageDownloadFailed:);
        [contentManager addDownloadItemRequest:request];
        if(isOpen)
        {
            self.statusImageView.image=nil;
            [self setStatusViewInLodingState:YES];
        }
        
    }else{
        if(!isOpen)
        {
            self.statusImageView.image=closedImage;
            [self setStatusViewInLodingState:NO];
        }
    }
    
    UIImage * openImage=hackerSpace.openImage;
    if(openImage==nil)
    {
        ContentManager * contentManager=[ContentManager contentManager];
        DownloadRequest * request=[DownloadRequest requestForFileAt:hackerSpace.openIconURL savingOn:hackerSpace.openIconPath];
        request.downloadObserver=self;
        request.tag=DOWNLOAD_TAG_OPENIMAGE;
        request.finishObserverSelector=@selector(imageDownloadFinishedSuccessfully:);
        request.failObserverSelector=@selector(imageDownloadFailed:);
        [contentManager addDownloadItemRequest:request];
        if(!isOpen)
        {
            self.statusImageView.image=nil;
            [self setStatusViewInLodingState:YES];
        }
    }else{
        if(isOpen)
        {
            self.statusImageView.image=openImage;
            [self setStatusViewInLodingState:NO];
        }
    }
    
}

-(void)imageDownloadFinishedSuccessfully:(DownloadRequest *)request
{    switch (request.tag) {
        case DOWNLOAD_TAG_LOGOIMAGE:
            [self setLogoViewInLodingState:NO];
            self.logoImageView.image=hackerSpace.iconImage;
            break;
            
        case DOWNLOAD_TAG_CLOSEDIMAGE:
            [self setStatusViewInLodingState:NO];
            if(hackerSpace)
                if(!hackerSpace.open)
                    self.statusImageView.image=hackerSpace.closeImage;
            break;
            
        case DOWNLOAD_TAG_OPENIMAGE:
            [self setStatusViewInLodingState:NO];
            if(hackerSpace)
                if(hackerSpace.open)
                    self.statusImageView.image=hackerSpace.openImage;
            break;
            
        default:
            NSLog(@"Unknown download with tag %d",request.tag);
            break;
    }
}
-(void)imageDownloadFailed:(DownloadRequest *)request
{
    switch (request.tag) {
        case DOWNLOAD_TAG_LOGOIMAGE:
            [self setLogoViewInLodingState:NO];
            //self.logoImageView.image=[UIImage imageNamed:@"noavailablelogo.png"];
            break;
            
        case DOWNLOAD_TAG_CLOSEDIMAGE:
            [self setStatusViewInLodingState:NO];
            self.statusImageView.image=[UIImage imageNamed:@"cerrado.png"];
            break;
            
        case DOWNLOAD_TAG_OPENIMAGE:
            [self setStatusViewInLodingState:NO];
            self.statusImageView.image=[UIImage imageNamed:@"abierto.png"];
            break;
            
        default:
            NSLog(@"Unknown download with tag %d",request.tag);
            break;
    }
}
#pragma mark - User actions
-(IBAction)showLocationInMap:(id)sender
{

    [self performSegueWithIdentifier:MAP_SEGUE sender:self];
}
-(IBAction)showWebSite:(id)sender
{
    [self launchWebActionSheet];
}

#pragma mark - Space updates
-(void)spaceWasUpdatedWithName:(NSString *)spaceName coreDataID:(NSManagedObjectID *)coreDataID
{
    if(hackerSpace)
        [self.coreDataContext refreshObject:hackerSpace mergeChanges:NO];
    
    hackerSpace=(HackerSpaceInfo *)[self.coreDataContext objectWithID:coreDataID];
    [self performLoadOperations];
}

#pragma mark  - Loading views

-(void)setLogoViewInLodingState:(BOOL)loadingState
{
    self.logoImageView.hidden=loadingState;
    if(loadingState)
        [self.logo_activityIndicator startAnimating];
    else
        [self.logo_activityIndicator stopAnimating];
    
}
-(void)setStatusViewInLodingState:(BOOL)loadingState
{
    self.statusImageView.hidden=loadingState;
    if(loadingState)
        [self.status_activityIndicator startAnimating];
    else
        [self.status_activityIndicator stopAnimating];
}

#pragma mark - Segues

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:MAP_SEGUE])
    {
        return (hackerSpace!=nil&&hackerSpace.url!=nil);
        
    }else
        return YES;
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:MAP_SEGUE])
    {
        HackerMapViewController * mapViewController=segue.destinationViewController;
        mapViewController.longitude=hackerSpace.lon;
        mapViewController.latitude=hackerSpace.lat;
        mapViewController.titleLocation=hackerSpace.spaceName;
        mapViewController.subtitle=hackerSpace.address;
        
    }else if([segue.identifier isEqualToString:WEBVIEW_SEGUE])
    {
        HSWebViewController * hswebController=segue.destinationViewController;
        hswebController.urlAddress=hackerSpace.url;
        
    }
}

#pragma mark - Web Action Sheet
-(IBAction)launchWebActionSheet
{
    NSString *actionSheetTitle = NSLocalizedString( @"What do you want to do?",@""); //Action Sheet Title
    NSString *cancelTitle = NSLocalizedString(@"Cancel",@"Cancel"); //Action Sheet Button Titles
    NSString *openWebTitle = NSLocalizedString(@"Open web page",@"Open web page");
    NSString *copyToCBTitle= NSLocalizedString(@"Copy to clipboard",@"Copy to clipboard");

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
            pasteboard.string = hackerSpace.url;
        }
        break;
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end

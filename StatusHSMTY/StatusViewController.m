//
//  StatusViewController.m
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "StatusViewController.h"
#import "HackerSpaceInfo.h"
#import "NSDate+HSMTYFormats.h"
#import "ContentManager.h"
#import "DownloadRequest.h"
#import "GlobalConstants.h"
#import "Notifications.h"
#import "Configuration.h"
#import "Reachability.h"
#import <MapKit/MapKit.h>

@interface StatusViewController ()
{
    HackerSpaceInfo * hackerSpace;
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
   
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*//http://stackoverflow.com/questions/12504294/programmatically-open-maps-app-in-ios-6
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:@"Piccadilly Circus, London, UK"
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         
                         // Convert the CLPlacemark to an MKPlacemark
                         // Note: There's no error checking for a failed geocode
                         CLPlacemark *geocodedPlacemark = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc]
                                                   initWithCoordinate:geocodedPlacemark.location.coordinate
                                                   addressDictionary:geocodedPlacemark.addressDictionary];
                         
                         // Create a map item for the geocoded address to pass to Maps app
                         MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                         [mapItem setName:geocodedPlacemark.name];
                         
                         // Set the directions mode to "Driving"
                         // Can use MKLaunchOptionsDirectionsModeWalking instead
                         NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
                         
                         // Get the "Current User Location" MKMapItem
                         MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
                         
                         // Pass the current location and destination map items to the Maps app
                         // Set the direction mode in the launchOptions dictionary
                         [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
                         
                     }];
    }*/
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
            [self setStatusViewInLodingState:YES];
        
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
            [self setStatusViewInLodingState:YES];
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
            //self.statusImageView.image=[UIImage imageNamed:@"noavailablestatus.png"];
            break;
            
        case DOWNLOAD_TAG_OPENIMAGE:
            [self setStatusViewInLodingState:NO];
            //self.statusImageView.image=[UIImage imageNamed:@"noavailablestatus.png"];
            break;
            
        default:
            NSLog(@"Unknown download with tag %d",request.tag);
            break;
    }
}
#pragma mark - User actions
-(IBAction)showLocationInMap:(id)sender
{

    NSLog(@"Show me the map!!");
}
-(IBAction)showWebSite:(id)sender
{
    NSLog(@"Show me your website, baby!!!");
}

#pragma mark - Data was updated
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

@end

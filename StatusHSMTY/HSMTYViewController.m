//
//  HSMTYViewController.m
//  StatusHSMTY
//
//  Created by Danno on 2/20/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "HSMTYViewController.h"
#import "ContentManager.h"
#import "GlobalConstants.h"
#import "AppDelegate.h"

@interface HSMTYViewController ()

-(void)addBasicButtons;

@end

@implementation HSMTYViewController
@synthesize coreDataContext=_coreDataContext;

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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFinishedWithUserInfo:) name:SPACE_UPDATE_NOTIFICATION_NAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFailed:) name:SPACE_UPDATE_FAILED_NOTIFICATION_NAME object:nil];
    [self addBasicButtons];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fondo.png"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
}

-(void)addBasicButtons
{
    //Right buttons
    UIBarButtonItem * refreshButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(performUpdate:)];
    UIBarButtonItem * selectButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"top-change.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(selectSpace:)];
    self.navigationItem.rightBarButtonItems = @[refreshButton,selectButton];
    UIBarButtonItem * notificationsButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"top-alerts.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(manageAlerts:)];
    self.navigationItem.leftBarButtonItem=notificationsButton;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(performUpdate:)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

}

-(NSManagedObjectContext *)coreDataContext{
    
    if(_coreDataContext==nil)
    {
        _coreDataContext=((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;;
    }
    return _coreDataContext;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)performUpdate:(id)sender
{
    ContentManager * contentManager=[ContentManager contentManager];
    [contentManager launchContentUpdate];
    [self.refreshControl beginRefreshing];

}
-(IBAction)selectSpace:(id)sender
{
    [self performSegueWithIdentifier:@"spaceselectorsegue" sender:self];
}
-(IBAction)manageAlerts:(id)sender
{
    [self performSegueWithIdentifier:@"alertmanagementsegue" sender:self];
}
-(BOOL)isUpdating
{
    return [ContentManager contentManager].updating;
}

-(void)updateFinishedWithUserInfo:(NSNotification *)notification
{
    NSDictionary * userInfo=notification.userInfo;
    NSManagedObjectID * objectID=[userInfo objectForKey:USRINFO_CDOBJID_KEY];
    NSString * spaceName=[userInfo valueForKey:USRINFO_SPACE_KEY];
    [self.refreshControl endRefreshing];
    [self spaceWasUpdatedWithName:spaceName coreDataID:objectID];
    
//    USRINFO_CDOBJID_KEY,
//    spaceName,USRINFO_SPACE_KEY, nil];
//    NSManagedObjectID * cdObjectID=[userInfo ]
    
}
-(void)updateFailed:(NSNotification *)notification
{
    [self.refreshControl endRefreshing];


}

-(void)spaceWasUpdatedWithName:(NSString *)spaceName coreDataID:(NSManagedObjectID *)coreDataID
{
    //optional override method
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

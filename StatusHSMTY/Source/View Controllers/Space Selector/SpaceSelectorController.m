//
//  SpaceSelectorController.m
//  StatusHSMTY
//
//  Created by Danno on 3/1/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "SpaceSelectorController.h"
#import "HackerSpaceInfo.h"
#import "ContentManager.h"
#import "GlobalConstants.h"
#import "Notifications.h"
#import "Configuration.h"
#import "PushEnablerRequest.h"
#import "MBProgressHUD.h"

@interface SpaceSelectorController ()
{
    MBProgressHUD * waitComponent;
    NSIndexPath * updatingIndexPath;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL searchIsActive;
-(BOOL)checkForUpdating;
@end

@implementation SpaceSelectorController
@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize selectionType;

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
    self.searchIsActive=NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(spacesListWasUpdated)
                                                 name:SPACELIST_UPDATE_NOTIFICATION_NAME
                                               object:nil];
    if(self.title==nil)
        self.title=NSLocalizedString( @"Select space", @"Select space");
    
    if(CURRENT_IOS_VERSION<NEW_STYLE_IOS_VERSION)
    {
       // NSArray * topButtons=self.navigationItem.ba
        self.navigationItem.leftBarButtonItem.tintColor=[UIColor blackColor];
        self.navigationItem.rightBarButtonItem.tintColor=[UIColor blackColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    

    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([HackerSpaceInfo class]) inManagedObjectContext:self.coreDataContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:10];
    
    NSSortDescriptor *sortDescriptorByFollow = [[NSSortDescriptor alloc] initWithKey:@"following" ascending:NO];
    NSSortDescriptor *sortDescriptorByName = [[NSSortDescriptor alloc] initWithKey:@"spaceName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByFollow,sortDescriptorByName,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

    // Create the fetched results controller
    NSString * cacheName=@"ListedContent";
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.coreDataContext
                                                                                                  sectionNameKeyPath:@"following" cacheName:cacheName];
    
    
    [NSFetchedResultsController deleteCacheWithName:cacheName];
    
    // Fetch the data
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    __fetchedResultsController=aFetchedResultsController;
    __fetchedResultsController.delegate = self;
    
    return __fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([[self.fetchedResultsController sections] count]==0&&!self.searchIsActive)
        [[ContentManager contentManager] launchSpaceListUpdate];
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];

    return [sectionInfo numberOfObjects];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSString * nativeName=[sectionInfo name];
    if([nativeName isEqualToString:@"0"])
        nativeName=NSLocalizedString(@"Nofollowing", @"No following");
    else
        nativeName=NSLocalizedString(@"Following",@"Following");
    
    return nativeName;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier=@"selectionItemCell";

    SpaceSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    HackerSpaceInfo * hs=[self.fetchedResultsController objectAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[SpaceSelectionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                reuseIdentifier:cellIdentifier] ;
        
    }
    cell.delegate=self;
    [cell configureForAlerts:(SelectionTypeAlert==self.selectionType)];
    //BOOL selected=[@"http://hsmty.org/status.json" isEqualToString:hs.url_status];
    BOOL selected=[[Configuration currentSpaceAPIURL] isEqualToString:hs.url_status];
    [cell setAsSelectedSpace:selected];
    cell.followingSwitch.on=hs.following;
    cell.spaceNameLabel.text=hs.spaceName;
    
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectionType==SelectionTypeAlert)
        return;
    if(![self checkForUpdating])
    {
        HackerSpaceInfo * hs=[self.fetchedResultsController objectAtIndexPath:indexPath];
        [Configuration setCurrentSpaceName:hs.spaceName];     
        [Configuration setCurrentSpaceAPIURL:hs.url_status];
        [[ContentManager contentManager] launchContentUpdateWithURL:hs.url_status];
//        [Configuration setCurrentSpaceAPIURL:@"http://localhost/~danno/status.json" ];//
//        [[ContentManager contentManager] launchContentUpdateWithURL:@"http://localhost/~danno/status.json"];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Fetched Result Controller Delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if ([self searchIsActive])
        [[[self searchDisplayController] searchResultsTableView] beginUpdates];
    else
        [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([self searchIsActive]) 
        [[[self searchDisplayController] searchResultsTableView] endUpdates];
    else
        [self.tableView endUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
            // Data was inserted -- insert the data into the table view
        case NSFetchedResultsChangeInsert:
            
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            // Data was deleted -- delete the data from the table view
        case NSFetchedResultsChangeDelete:
            
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            // Data was updated (changed) -- reconfigure the cell for the data
        case NSFetchedResultsChangeUpdate:
        {
            //No debe de pasar
        }
            break;
            // Data was moved -- delete the data from the old location and insert the data into the new location
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
#pragma mark - Update Notifications
-(void)spacesListWasUpdated
{
    __fetchedResultsController=nil;
    [self.tableView reloadData];
}

-(BOOL)checkForUpdating
{
    BOOL isUpdating=self.isUpdating;
    if(isUpdating)
    {
        [Notifications launchErrorBox:nil message:NSLocalizedString(@"espereactualizacion",@"Espere a que termine la actualización.")];
    }
    return isUpdating;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - User actions

-(IBAction)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)updateList
{
   
    if(![self checkForUpdating])
    {
        [[ContentManager contentManager] launchSpaceListUpdate];
    }

}
#pragma mark - Super Class Patch
-(void)addBasicButtons
{

}

#pragma mark -

#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    __fetchedResultsController=nil;
    NSFetchRequest *aRequest = [[self fetchedResultsController] fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"spaceName CONTAINS[cd] %@", searchText];
    [aRequest setPredicate:predicate];
    NSError *error = nil;
      if (![[self fetchedResultsController] performFetch:&error]) {
          
          NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
          
          abort();
          
      }
    
}
                              
                              
                              
#pragma mark -
                              
#pragma mark UISearchDisplayController Delegate Methods
                              
                              
                              
// this method is used to reload tableView for string introduced in search bar
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:nil];
    return YES;
    
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
  
  [self setSearchIsActive:YES];
  
}

 -(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller                              
{   

    __fetchedResultsController=nil;
    
}

#pragma mark - SpaceSelectionCellDelegate
-(void)cellAtIndex:(NSIndexPath *)indexPath changeToValue:(BOOL)value
{ 
    if(![PushEnablerRequest isPossibleEnablePush])
    {
        NSString * message=NSLocalizedString(@"noPushPossible", @"No es posible realizar esta operacion si no activa las notificaciones en el telefono y/o no tiene acceso a internet.");
        [Notifications launchErrorBox:nil message:message];
        SpaceSelectionCell * cell = (SpaceSelectionCell *)[self.tableView cellForRowAtIndexPath:indexPath] ;
        cell.followingSwitch.on=!value;
        
        return;
    }

    if(updatingIndexPath==nil)
    {
        HackerSpaceInfo * hs=[self.fetchedResultsController objectAtIndexPath:indexPath];
        waitComponent=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        waitComponent.labelText=NSLocalizedString(@"procesando",@"Procesando");
        

        updatingIndexPath=indexPath;
        PushEnablerRequest * request;
        request=[PushEnablerRequest requestToModifyURL:hs.url_status add:value];
        [request setDidFinishSelector:@selector(pushRequestPostedSuccessfully:)];
        [request setDidFailSelector:@selector(pushRequestPostFailed:)];
        [request setDelegate:self];
        [request startAsynchronous];
        
    }
    
}

#pragma mark - Enable Push Operations
-(void)pushRequestPostedSuccessfully:(PushEnablerRequest *)request
{
    [waitComponent hide:YES];
    waitComponent=nil;
    HackerSpaceInfo * hs=[self.fetchedResultsController objectAtIndexPath:updatingIndexPath];
    hs.following=!hs.following;
    [[ContentManager contentManager] saveCoreData];
    updatingIndexPath=nil;
    
}
-(void)pushRequestPostedFailed:(PushEnablerRequest *)request
{
    [waitComponent hide:YES];
    waitComponent=nil;
    SpaceSelectionCell *cell=(SpaceSelectionCell *)[self.tableView cellForRowAtIndexPath:updatingIndexPath];
    cell.followingSwitch.on=!cell.followingSwitch.on;
    updatingIndexPath=nil;
    [Notifications launchErrorBox:nil message:NSLocalizedString(@"erroractualizacion" ,@"Ha ocurrido un error durante la actualización")];
    
}


@end

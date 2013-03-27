//
//  ContactViewController.m
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "ContactViewController.h"
#import <AddressBook/AddressBook.h>
#import "HackerSpaceInfo.h"
#import "ContentManager.h"
#import "Configuration.h"
#import "Notifications.h"
#import "Contact.h"
#import "Notifications.h"

@interface ContactViewController ()
{
    HackerSpaceInfo * hackerSpace;
    Contact * currentContact;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ContactViewController
@synthesize fetchedResultsController=__fetchedResultsController;


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
    hackerSpace=[[ContentManager contentManager] spaceInfoForName:[Configuration currentSpaceName]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    if(hackerSpace==nil||hackerSpace.url==nil)
        return nil;
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Contact class]) inManagedObjectContext:self.coreDataContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:10];

    NSSortDescriptor *sortDescriptorByType = [[NSSortDescriptor alloc] initWithKey:@"contactType" ascending:NO];
    NSSortDescriptor *sortDescriptorByData = [[NSSortDescriptor alloc] initWithKey:@"contactData" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorByType,sortDescriptorByData,nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hackerspace == %@", hackerSpace];
    [fetchRequest setPredicate:predicate];
    
    // Create the fetched results controller
    NSString * cacheName=@"ContactContent";
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.coreDataContext
                                                                                                  sectionNameKeyPath:nil cacheName:cacheName];
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
    if(self.fetchedResultsController==nil)
        return 0;
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.fetchedResultsController==nil)
        return 0;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * cellIdentifier=@"contactItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Contact * contact=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                reuseIdentifier:cellIdentifier] ;
    }
    
    //setea datos
    cell.textLabel.text=contact.contactType;
    cell.detailTextLabel.text=contact.contactData;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    currentContact=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if([currentContact.contactType isEqualToString:@"email"]||
       [currentContact.contactType isEqualToString:@"Mailing list"])
    {
        [self sendEmail];
        
    }else if([currentContact.contactType isEqualToString:@"Telephone" ]||
             [currentContact.contactType isEqualToString:@"keymaster"]||
             [currentContact.contactType isEqualToString:@"keymasters"])
    {
        NSString *actionSheetTitle = @"What do you want to do?"; //Action Sheet Title
        NSString *cancelTitle = @"Cancel"; //Action Sheet Button Titles
        NSString *copyTitle = @"Copy";
        NSString *addContactTitle = @"Add contact";
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:actionSheetTitle
                                      delegate:self
                                      cancelButtonTitle:cancelTitle
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:addContactTitle,copyTitle, nil];
        actionSheet.delegate=self;
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    
    }else
    {
        [self copyToClipboard];
        currentContact=nil;
    }
    

}



#pragma mark - Fetched Result Controller Delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
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

#pragma mark - Data was updated
-(void)spaceWasUpdatedWithName:(NSString *)spaceName coreDataID:(NSManagedObjectID *)coreDataID
{
    if(hackerSpace)
        [self.coreDataContext refreshObject:hackerSpace mergeChanges:NO];
    currentContact=nil;
    hackerSpace=(HackerSpaceInfo *)[self.coreDataContext objectWithID:coreDataID];
    __fetchedResultsController=nil;
    [self.tableView reloadData];
}

#pragma mark - Action Sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [self copyToClipboard];
    }else if (buttonIndex==0)
    {
        [self addToContacts];
    }
    
    currentContact=nil;
    
}

#pragma mark - Email Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send");
            break;
        case MFMailComposeResultFailed:
        default:
            [Notifications launchErrorBox:nil message:@"Mail failed: the email message was not saved or queued, possibly due to an error."];
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions
-(void)copyToClipboard
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = currentContact.contactData;
    [Notifications launchInformationBox:nil message:@"Your data was copied to your clipboard"];
    currentContact=nil;
}
-(void)sendEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObjects:currentContact.contactData, nil];
        [mailer setToRecipients:toRecipients];

        [self presentViewController:mailer animated:YES completion:nil];

    }
    else
    {
        [Notifications launchErrorBox:nil message:@"Your device doesn't support the composer sheet"];
    }
    currentContact=nil;
    
}
-(void)addToContacts
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
    
    ABRecordRef newPerson = ABPersonCreate();
    
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, hackerSpace.spaceName, &error);

    
    ABMutableMultiValueRef multiPhone =     ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiPhone, people.phone, kABPersonPhoneMainLabel, NULL);
    ABMultiValueAddValueAndLabel(multiPhone, people.other, kABOtherLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    // ...
    // Set other properties
    // ...
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    
    ABAddressBookSave(iPhoneAddressBook, &error);
    CFRelease(newPerson);
    CFRelease(iPhoneAddressBook);
    if (error != NULL)
    {
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"Contact not saved: %@", errorDesc);
        CFRelease(errorDesc);        
    }

}
@end

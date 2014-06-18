//
//  ContactViewController.m
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "ContactViewController.h"
#import "HackerSpaceInfo.h"
#import "ContentManager.h"
#import "Configuration.h"
#import "Notifications.h"
#import "Contact.h"
#import "Notifications.h"
#import "MBProgressHUD.h"

@interface ContactViewController ()
{
    HackerSpaceInfo * hackerSpace;
    Contact * currentContact;
}


-(BOOL) contactIsPhoneType:(Contact *)contact;
-(BOOL)contactIsMailType:(Contact *)contact;
-(void)hideSuccessfullCopyDialog;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,readonly) MBProgressHUD *successfullCopyDialog;
@end

@implementation ContactViewController
@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize successfullCopyDialog=_successfullCopyDialog;


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
    self.title=NSLocalizedString(@"Contact",@"Contact");
    hackerSpace=[[ContentManager contentManager] spaceInfoForName:[Configuration currentSpaceName]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(MBProgressHUD *)successfullCopyDialog
{
    if(_successfullCopyDialog==nil)
    {
        _successfullCopyDialog=[[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_successfullCopyDialog];
        _successfullCopyDialog.customView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkcopy.png"]];
        _successfullCopyDialog.mode=MBProgressHUDModeCustomView;
        _successfullCopyDialog.labelText=NSLocalizedString( @"Copied to clipboard",@"Copied to clipboard");
    }
    return _successfullCopyDialog;
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
    
    static NSString * cellIdentifier=@"contactItem";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Contact * contact=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                reuseIdentifier:cellIdentifier] ;
    }
    
    if([self contactIsMailType:contact])
        cell.specialAction=SpecialActionMail;
    else if([self contactIsPhoneType:contact])
        cell.specialAction=SpecialActionPhone;
    else
        cell.specialAction=SpecialActionNone;
        
    cell.contactTypeLabel.text=contact.contactType;
    cell.contactInfoLabel.text=contact.contactData;
    cell.contactImageView.image=[UIImage imageNamed:contact.contactLogo];
    cell.contactDelegate=self;
    cell.index=indexPath;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    currentContact=[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if([self contactIsMailType:currentContact])
    {
        [self sendEmail];
        
    }else if([self contactIsPhoneType:currentContact])
    {
        NSString *actionSheetTitle = NSLocalizedString( @"What do you want to do?",@"What do you want to do?"); //Action Sheet Title
        NSString *cancelTitle = NSLocalizedString(@"Cancel",@"Cancel"); //Action Sheet Button Titles
        NSString *copyTitle = NSLocalizedString(@"Copy",@"Copy");
        NSString *addContactTitle = NSLocalizedString(@"Add contact",@"Add contact");
        
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];


}

-(BOOL) contactIsPhoneType:(Contact *)contact
{
    return [contact.contactType isEqualToString:@"Telephone" ]||
    [contact.contactType isEqualToString:@"keymaster"]||
    [contact.contactType isEqualToString:@"keymasters"];
    
}
-(BOOL)contactIsMailType:(Contact *)contact
{
    return [contact.contactType isEqualToString:@"E-Mail"]||
    [contact.contactType isEqualToString:@"Mailing list"];
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
            [Notifications launchErrorBox:nil message:NSLocalizedString( @"Mail failed: the email message was not saved or queued, possibly due to an error.",@"Mail failed: the email message was not saved or queued, possibly due to an error.")];
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

    [self.view addSubview:self.successfullCopyDialog];
    [self.successfullCopyDialog show:YES];
    [self performSelector:@selector(hideSuccessfullCopyDialog) withObject:nil afterDelay:0.9];
    currentContact=nil;
}
-(void)hideSuccessfullCopyDialog
{
    [self.successfullCopyDialog hide:YES];
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
        [Notifications launchErrorBox:nil message:NSLocalizedString(@"Your device doesn't support the composer sheet",@"Your device doesn't support the composer sheet")];
    }
    currentContact=nil;
    
}
-(void)addToContacts
{
    // Fetch the address book

    NSError *error = nil;
    CFErrorRef cferror=NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &cferror);
    error=(__bridge NSError *)cferror;
    if (error)
    {
        NSLog(@"%@", error);
        [Notifications launchErrorBox:nil message:NSLocalizedString(@"contacterror", @"Tal vez tengas que dar permisos en la seccion de ajustes de tu telefono para acceder a contactos.")];
    }
    // Search for the person named "Appleseed" in the address book
    NSArray *people = (__bridge NSArray *)ABAddressBookCopyPeopleWithName(addressBook, CFSTR("John Smith"));
    // Display "Appleseed" information if found in the address book
    if ((people != nil) && [people count])
    {
        // Show an alert if "Appleseed" is not in Contacts
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",@"Error")
                                                        message:NSLocalizedString(@"The contact already exists",@"The contact already exists")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString( @"Cancel",@"Cancel")
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
        picker.newPersonViewDelegate = self;
        ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        
        ABRecordRef newPerson = ABPersonCreate();
        CFErrorRef error = NULL;
        if(hackerSpace.spaceName)
            ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFStringRef)hackerSpace.spaceName, &error);
        ABRecordSetValue(newPerson, kABPersonLastNameProperty, CFSTR("Hackerspace"), &error);
        
        
        for(Contact * contact in [self.fetchedResultsController fetchedObjects])
        {
            NSLog(@"%@",contact.contactType);
            if([contact.contactType isEqualToString:@"E-Mail"]||
            [contact.contactType isEqualToString:@"Mailing list"])
            {
                
                ABMultiValueAddValueAndLabel(multiEmail, (__bridge CFStringRef)contact.contactData, kABWorkLabel, NULL);
                ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);
                continue;
                
            }
            else if([contact.contactType isEqualToString:@"Telephone"])
            {
                 ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFStringRef)contact.contactData, kABPersonPhoneMainLabel, NULL);
                continue;
                
            }else if([contact.contactType isEqualToString:@"Key Master"]||
                     [contact.contactType isEqualToString:@"keymasters"])
            {
                for(NSString * phone in [contact.contactData componentsSeparatedByString:@","])
                    ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFStringRef)phone, kABPersonPhoneMainLabel, NULL);
                continue;
                
            }
            
            
        }

        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
        
        NSAssert( !error, @"Something bad happened here." );
        
        [picker setDisplayedPerson:newPerson];
        
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
        [self presentViewController:navigation animated:YES completion:nil];
        

        CFRelease(multiEmail);
        CFRelease(multiPhone);
        
    }
    
    CFRelease(addressBook);
}
#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark ABUnknownPersonViewControllerDelegate methods
// Dismisses the picker when users are done creating a contact or adding the displayed person properties to an existing contact.
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


// Does not allow users to perform default actions such as emailing a contact, when they select a contact property.
- (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person
						   property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	return NO;
}

#pragma mark - ContactDelegate
-(void)cellRequestForCopy:(NSIndexPath *)index
{
     currentContact=[self.fetchedResultsController objectAtIndexPath:index];
    [self copyToClipboard];
    
}
-(void)cellRequestForUserAction:(NSIndexPath *)index
{
    currentContact=[self.fetchedResultsController objectAtIndexPath:index];
    
    if([self contactIsMailType:currentContact])
    {
        [self sendEmail];
        
    }else if([self contactIsPhoneType:currentContact])
    {
        [self addToContacts];
    }

}

@end

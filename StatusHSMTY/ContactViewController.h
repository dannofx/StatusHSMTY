//
//  ContactViewController.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "HSMTYViewController.h"

@interface ContactViewController : HSMTYViewController<NSFetchedResultsControllerDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,ABNewPersonViewControllerDelegate>

@end

//
//  GlobalConstants.h
//  StatusHSMTY
//
//  Created by Danno on 2/19/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#ifndef MePaparazzo_GlobalConstants_h
#define MePaparazzo_GlobalConstants_h
//#define HSMTY_URL @"http://hsmty.org/status.json"
#define HSMTY_URL @"http://localhost/~danno/status.json"
#define PUSH_ADDRESS @"http://api.hsmty.org/idevice"
#define SPACE_UPDATE_NOTIFICATION_NAME @"currentSpaceUpdate"
#define SPACE_UPDATE_FAILED_NOTIFICATION_NAME @"currentSpaceFailedUpdate"
#define SPACELIST_UPDATE_NOTIFICATION_NAME @"spaceListUpdate"
#define LIST_SPACES_URL @"http://spaceapi.net/directory.json"

#define TIMEOUT_HIGH_PRIORITY 30
#define TIMEOUT_LOW_PRIORITY 5

#define USRINFO_CDOBJID_KEY @"spaceCoreDataID"
#define USRINFO_SPACE_KEY @"spaceName"
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#define DOWNLOAD_TAG_LOGOIMAGE 0
#define DOWNLOAD_TAG_CLOSEDIMAGE 1
#define DOWNLOAD_TAG_OPENIMAGE 2
#define START_TAG_FOR_EVENT_IMAGES 1000

#define KEY_SPACENAME_SETTINGS @"spaceNameSettings"
#define KEY_SPACEURL_SETTINGS @"spaceURLAPI"

#define PUSH_TOKEN_KEY @"pushTokenKey"
#define PUSH_TOKEN_KEYCHAIN @"pushTokenKeyChain"
#define UUID_KEY @"uuidKey"
#define UUID_KEYCHAIN @"uuidKeyChain"

#define SECRET_FOR_PUSH @"esteesunsecretoparaaquelloquequello"

#define WEBVIEW_SEGUE @"webviewsegue"

#define CURRENT_IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define NEW_STYLE_IOS_VERSION 7.0

#endif
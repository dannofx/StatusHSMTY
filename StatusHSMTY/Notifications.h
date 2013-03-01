//
//  Notifications.h
//  Transli
//
//  Created by Danno on 29/01/11.
//  Copyright 2011 Naranya Apphouse. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This class acts as a wrapper of UIAlertView allowing show different Message Boxes easly.
 */

@interface Notifications : NSObject {

}
/**
Launch an UIAlertView with YES/NO options with the specified message.
 @param target Target to be notified when the user accepts the action.
 @param selector selector than will be performed when the user accepts the action.
 @param message Message than will be displayed.
 */
+(void)launchConfirmationBoxYesNot:(id) object selector:(SEL)selector message:(NSString *)message;
/**
 Launch an UIAlertView with the specified message.
 @param target Target object.
 @param message The message than will be displayed.
 */
+(void)launchInformationBox:(id) obj message:(NSString *)message;
/**
 Launch an UIAlertView with the word "Warning" in the title with a specified message.
 @param obj The target object.
 @param message Message than will be showed.
 */
+(void)launchWarningBox:(id) obj message:(NSString *)message;
/**
 Launch an UIAlertView with YES/NO options with the specified message with the word "Warning" in the title.
 @param target Target to be notified when the user accepts the action.
 @param selector selector than will be performed when the user accepts the action.
 @param message Message than will be displayed.
 */
+(void)launchWarningConfirmationBox:(id) obj selector:(SEL)sel message:(NSString *)message;
/**
 Launch an UIAlertView with the word "Error" in the title with a specified message.
 @param obj The target object.
 @param message Message than will be showed.
 */
+(void)launchErrorBox:(id) obj message:(NSString *)message;
/**
 Launch an UIAlertView with YES/NO options with the specified message with the word "Error" in the title.
 @param target Target to be notified when the user accepts the action.
 @param selector selector than will be performed when the user accepts the action.
 @param message Message than will be displayed.
 */
+(void)launchErrorConfirmationYesNot:(id) obj selector:(SEL)sel message:(NSString *)message;

@end


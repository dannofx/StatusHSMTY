//
//  Notifications.m
//  Transli
//
//  Created by Danno on 29/01/11.
//  Copyright 2011 Naranya Apphouse. All rights reserved.
//

#import "Notifications.h"

static id object;
static SEL selector;
@implementation Notifications
+(void)launchConfirmationBoxYesNot:(id) obj selector:(SEL)sel message:(NSString *)message
{
	object=obj;
	selector=sel;
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:NSLocalizedString(@"confirmacion",@"Confirmación")];
	[alert setMessage:message];
	[alert setDelegate:self];
	[alert addButtonWithTitle:NSLocalizedString(@"si",@"Si")];
	[alert addButtonWithTitle:NSLocalizedString(@"no",@"No")];
	[alert setTag:1];
	[alert show];
	//[alert release];
}
+(void)launchInformationBox:(id) obj message:(NSString *)message
{
	object=obj;

	UIAlertView *alert = [[UIAlertView alloc] init] ;
	[alert setTitle:NSLocalizedString(@"informacion",@"Información")];
	[alert setMessage:message];
	[alert setDelegate:self];
	[alert addButtonWithTitle:NSLocalizedString(@"aceptar",@"Aceptar")];
	[alert setTag:2];
	[alert show];
	//[alert release];
}
+(void)launchWarningBox:(id) obj message:(NSString *)message
{
	object=obj;

	UIAlertView *alert = [[UIAlertView alloc] init] ;
	[alert setTitle:NSLocalizedString(@"alerta",@"Alerta")];
	[alert setMessage:message];
	[alert setDelegate:self];
	[alert addButtonWithTitle:NSLocalizedString(@"aceptar",@"Aceptar")];
	[alert setTag:3];
	[alert show];
	//[alert release];
}
+(void)launchWarningConfirmationBox:(id) obj selector:(SEL)sel message:(NSString *)message
{
	object=obj;
	selector=sel;
	UIAlertView *alert = [[UIAlertView alloc] init] ;
	[alert setTitle:NSLocalizedString(@"alerta",@"Alerta")];
	[alert setMessage:message];
	[alert setDelegate:self];
	[alert addButtonWithTitle:NSLocalizedString(@"aceptar",@"Aceptar")];
	[alert addButtonWithTitle:NSLocalizedString(@"cancelar",@"Cancelar")];
	[alert setTag:4];
	[alert show];
	//[alert release];
}
+(void)launchErrorBox:(id) obj message:(NSString *)message
{
	object=obj;

	UIAlertView *alert = [[UIAlertView alloc] init] ;
	[alert setTitle:NSLocalizedString(@"error",@"Error")];
	[alert setMessage:message];
	[alert setDelegate:self];
	[alert addButtonWithTitle:NSLocalizedString(@"aceptar",@"Aceptar")];
	[alert setTag:5];
	[alert show];
	//[alert release];
}
+(void)launchErrorConfirmationYesNot:(id) obj selector:(SEL)sel message:(NSString *)message
{
	object=obj;
	selector=sel;
	UIAlertView *alert = [[UIAlertView alloc] init] ;
	[alert setTitle:NSLocalizedString(@"error",@"Error")];
	[alert setMessage:message];
	[alert setDelegate:self];
	[alert addButtonWithTitle:NSLocalizedString(@"si",@"Si")];
	[alert addButtonWithTitle:NSLocalizedString(@"no",@"No")];
	[alert setTag:6];
	[alert show];
	//[alert release];
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch(alertView.tag)
	{
		case 1:
			//confirmation yesnot
		case 4:
			//warningBoxConfirmation
		case 6:
			//error confirmation
			if (buttonIndex==0) {
                if([object respondsToSelector:selector])
                {
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [object performSelector:selector];
                    #pragma clang diagnostic pop
                    object=nil;
                }
			}
			break;
		case 2:
			//informationBox
			break;
		case 3: 
			//warningBox
			break;
		case 5:
			//error
			break;

	}
		
}
@end

//
//  HSWebViewController.h
//  StatusHSMTY
//
//  Created by Danno on 3/23/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView * webView;
@property (nonatomic,retain)  NSString * urlAddress;

-(IBAction)hide:(id)sender;
@end


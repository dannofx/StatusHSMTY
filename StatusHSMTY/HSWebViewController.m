//
//  HSWebViewController.m
//  StatusHSMTY
//
//  Created by Danno on 3/23/13.
//  Copyright (c) 2013 Danno. All rights reserved.
//

#import "HSWebViewController.h"

@interface HSWebViewController ()

@end

@implementation HSWebViewController
@synthesize urlAddress;
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		
	}
	return self;
}

-(void)loadBasicComponents
{
    if(urlAddress==nil)
        return;
    webView.delegate=self;
    
	//Create a URL object.
	NSURL *url = [NSURL URLWithString:urlAddress];
	
	//URL Requst Object
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	
	//Load the request in the UIWebView.
	[webView loadRequest:requestObj];
    
}

- (void)viewDidLoad {
	[super viewDidLoad];
    [self loadBasicComponents];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
    [self loadBasicComponents];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(IBAction)hide:(id)sender
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)dealloc
{
    webView=nil;
    urlAddress=nil;
}
/*
 -(void)didReceiveMemoryWarning
 {
 [self dismissModalViewControllerAnimated:NO];
 webView=nil;
 urlAddress=nil;
 [super didReceiveMemoryWarning];
 }*/


@end

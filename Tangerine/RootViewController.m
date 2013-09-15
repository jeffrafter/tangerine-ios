//
//  RootViewController.m
//  Tangerine
//
//  Created by Jeff Rafter on 7/13/13.
//  Copyright (c) 2013 Jeff Rafter. All rights reserved.
//

#import "RootViewController.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import <CouchbaseLiteListener/CBLListener.h>

@interface RootViewController ()

@property (nonatomic, strong) CBLListener *listener;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CBLManager* manager = [CBLManager sharedInstance];
    self.listener = [[CBLListener alloc] initWithManager: manager port: 8088];
    self.listener.readOnly = NO;
    NSError* error;
    if ([self.listener start:&error])
    {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        NSLog(@"%@", manager.internalURL);

        self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:self.webView];

        UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame= CGRectMake(15, 15, 100, 40);
        [button setTitle:@"Load" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect webFrame = self.view.bounds;
    webFrame.origin.y += 20;
    webFrame.size.height -= 20;
    self.webView.frame = webFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(id)sender
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8088/tangerine/_design/tangerine/index.html"]]];
    ((UIButton *)sender).hidden = YES;
}

@end

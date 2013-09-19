//
//  RootViewController.m
//  Tangerine
//
//  Created by Jeff Rafter on 7/13/13.
//  Copyright (c) 2013 Jeff Rafter. All rights reserved.
//

#import "RootViewController.h"
#import "KeychainItemWrapper.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import <CouchbaseLiteListener/CBLListener.h>

@interface RootViewController () <UIWebViewDelegate>

@property (nonatomic, retain) KeychainItemWrapper *keychain;
@property (nonatomic, strong) CBLListener *listener;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CBLManager* manager = [CBLManager sharedInstance];
    self.listener = [[CBLListener alloc] initWithManager: manager port: 8088];
    self.listener.authSecret = [self getAuthSecret];
    self.listener.passwords = @{@"admin": @"password"};
    self.listener.requiresAuth = NO;
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
        self.webView.delegate = self;
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

/** The authSecret can be stored anywhere (including directly in the code) but if you want to generate a per device
 secret then it is helpful to store that in the keychain for later reuse */
- (NSString *)getAuthSecret
{
    // Setup the keychain
    self.keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.tangerine" accessGroup:nil];
    [self.keychain setObject:(__bridge id)(kSecAttrAccessibleWhenUnlocked) forKey:(__bridge id)(kSecAttrAccessible)];
    
    // Get the secret
    NSString *authSecret = [self.keychain objectForKey:(__bridge id)kSecValueData];
    
    // If there is no secret, create one and set it in the keychain
    if (!authSecret || [authSecret isEqualToString:@""])
    {
        // TODO: Do something way more fancy here
        authSecret = @"7801cb63b2bf0cd09ce7d313a34f7f9d";

        [self.keychain setObject:authSecret forKey:(__bridge id)kSecValueData];
    }
    
    return authSecret;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

@end

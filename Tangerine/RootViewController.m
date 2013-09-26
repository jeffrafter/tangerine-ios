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

@implementation RootViewController {
    BOOL _appLoaded;
    BOOL _databaseLoaded;
    BOOL _viewLoaded;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    CBLManager* manager = [CBLManager sharedInstance];
    self.listener = [[CBLListener alloc] initWithManager: manager port: 59840];
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
    
        NSLog(@"Listening on %@", [self url]);
        
        self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        self.webView.delegate = self;
        [self.view addSubview:self.webView];
    }
}

- (void)databaseDidLoad
{
    NSLog(@"Database loaded");
    _databaseLoaded = YES;
    
    [self loadApp];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect webFrame = self.view.bounds;
    webFrame.origin.y += 20;
    webFrame.size.height -= 20;
    self.webView.frame = webFrame;
    
    NSLog(@"View loaded");
    _viewLoaded = YES;
    
    [self loadApp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadApp
{
    if (_appLoaded || !_databaseLoaded || !_viewLoaded) return;
    _appLoaded = YES;
    
    // Although having this button is very silly, it allows us to
    // wait as long as needed and not rely on the progress if we are syncing.
    // Also, it allows you to attach a Safari Developer inspector before
    // launching the HTML views
    UIButton *button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame= CGRectMake(15, 15, 100, 40);
    [button setTitle:@"Start" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (IBAction)buttonClicked:(id)sender
{
    [self loadRequest];
    ((UIButton *)sender).hidden = YES;
}

- (NSString *)url
{
    NSString *domain = @"http://localhost";
    NSString *path = @"/tangerine/_design/tangerine/index.html#login";
    return [NSString stringWithFormat:@"%@:%i%@", domain, self.listener.port, path];
}

- (void)loadRequest
{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self url]]]];
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
        authSecret = @"7801cb63b2bf0cd6653bf9afedf7f9d";

        [self.keychain setObject:authSecret forKey:(__bridge id)kSecValueData];
    }
    
    return authSecret;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

@end

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
    self.listener = [[CBLListener alloc] initWithManager: manager port: 0];
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
    
    [NSTimer scheduledTimerWithTimeInterval:2
                                     target:self
                                   selector:@selector(loadRequest)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)loadRequest
{
    NSString *domain = @"http://127.0.0.1";
    NSString *path = @"/tangerine/_design/tangerine/index.html";
    NSString *url = [NSString stringWithFormat:@"%@:%i%@", domain, self.listener.port, path];
    NSLog(@"Listening on %@", url);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
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

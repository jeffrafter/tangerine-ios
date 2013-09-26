//
//  AppDelegate.m
//  Tangerine
//
//  Created by Jeff Rafter on 7/13/13.
//  Copyright (c) 2013 Jeff Rafter. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import <CouchbaseLite/CouchbaseLite.h>

#import "CBLJSViewCompiler.h"

#define noreplicate 1
#define nobundled 1

@interface AppDelegate()

@property (nonatomic) CBLReplication *pull;
@property (nonatomic) CBLReplication *push;
@property (nonatomic) RootViewController *rvc;

@end

@implementation AppDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.rvc = [[RootViewController alloc] init];
    [[self window] setRootViewController:self.rvc];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [CBLView setCompiler: [[CBLJSViewCompiler alloc] init]];

    CBLManager* server = [CBLManager sharedInstance];
    NSError* error;
    self.database = [server databaseNamed: @"tangerine" error: &error];
    
    [self preload];
    [self.rvc databaseDidLoad];
    
    return YES;
}

- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal {
    if (error) {
        message = [NSString stringWithFormat: @"%@\n\n%@", message, error.localizedDescription];
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle: (fatal ? @"Fatal Error" : @"Error")
                                                    message: message
                                                   delegate: (fatal ? self : nil)
                                          cancelButtonTitle: (fatal ? @"Quit" : @"Continue")
                                          otherButtonTitles: nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    exit(0);
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == self.pull || object == self.push) {
        unsigned completed = self.pull.completed + self.push.completed;
        unsigned total = self.pull.total + self.push.total;
        if (total > 0 && completed < total) {
            NSLog(@"Progress: %f", (completed / (float)total));
        } else {
            NSLog(@"Done");
            [self syncComplete];
        }
    }
}

- (void)preload
{
#ifdef bundled
    if (!self.database) {
        NSString* bundledDbPath = [[NSBundle mainBundle] pathForResource: @"tangerine" ofType: @"cblite"];
        NSString* bundledAttPath = [[NSBundle mainBundle] pathForResource: @"tangerine attachments" ofType: @""];
        
        BOOL ok = [server replaceDatabaseNamed: @"tangerine"
                              withDatabaseFile: bundledDbPath
                               withAttachments: bundledAttPath
                                         error: &error];
        
        NSAssert(ok, @"Failed to install database: %@", error);
        
        self.database = [server databaseNamed: @"tangerine" error: &error];
        
        NSAssert(self.database, @"Failed to open database");
    }
#endif
    
#ifdef replicate
    NSURL *db = [NSURL URLWithString:@"http://admin:password@localhost:5984/tangerine"];
    NSArray* repls = [self.database replicateWithURL: db exclusively: YES];
    self.pull = [repls objectAtIndex: 0];
    self.push = [repls objectAtIndex: 1];
    
    [self.pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    [self.push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
#endif
}

- (void)syncComplete
{
    [self.rvc databaseDidLoad];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    CBLManager* server = [CBLManager sharedInstance];
    [server close];
}

@end

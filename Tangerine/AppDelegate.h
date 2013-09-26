//
//  AppDelegate.h
//  Tangerine
//
//  Created by Jeff Rafter on 7/13/13.
//  Copyright (c) 2013 Jeff Rafter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) CBLDatabase *database;


- (void)showAlert: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal;

@end

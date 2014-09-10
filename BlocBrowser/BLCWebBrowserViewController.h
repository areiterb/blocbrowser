//
//  BLCWebBrowserViewController.h
//  BlocBrowser
//
//  Created by ALEJANDRO REITER B on 9/5/14.
//  Copyright (c) 2014 Alejandro Reiter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCWebBrowserViewController : UIViewController

/**
 Replaces the web view with a fresh one, erasing all history.  Also updates the URL field and toolbar buttons appropriately.
 */
- (void) resetWebView;
 

@end

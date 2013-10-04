//
//  HWViewController.h
//  HelloWorld
//
//  Created by cpinera on 10/4/13.
//  Copyright (c) 2013 Cesar Pinera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol HWViewController <JSExport>

- (void)updateGreeting:(NSString*)someText;
- (NSString*)name;

@end

@interface HWViewController : UIViewController <HWViewController, UITextFieldDelegate>

@end

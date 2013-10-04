//
//  HWViewController.m
//  HelloWorld
//
//  Created by cpinera on 10/4/13.
//  Copyright (c) 2013 Cesar Pinera. All rights reserved.
//

#import "HWViewController.h"

@interface HWViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UILabel *label;
- (IBAction)greet:(id)sender;


@property JSContext *context; // Hold a reference to the JavaScriptCore context
@property JSValue *hello; // The cljs namespace we're interested in

@end

@implementation HWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setContext:[[JSContext alloc] init]];
    
    // Load the ClojureScript module
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hello" ofType:@"js"];
    NSString *scriptString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [[self context] evaluateScript:scriptString];
    NSAssert(_context != nil, @"The JavaScript context should not be nil");
    // At this point our ClojureScript module has been loaded into the context.

    // We should be able to get a reference to it named "hello"
    [self setHello:[_context globalObject][@"hello"]];
    
    // Test it
    NSAssert(_hello != nil, @"Failed to load the ClojureScript object");
    NSAssert(![_hello isUndefined], @"Unable to load the hello namespace");
    // The script is now loaded

    [self greet:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)greet:(id)sender
{
    // Retrieve the greet function
    JSValue *greetFunction = [self hello][@"greet"];
    
    // Call the function, passing self as the only parameter
    [greetFunction callWithArguments:@[self]];
}

// This function is invoked by ClojureScript when the label needs to be updated
- (void)updateGreeting:(NSString*)someText
{
    [self label].text = someText;
}

// This function is invoked by ClojurScript when it needs to retrieve the value of the name textfield
- (NSString*)name
{
    return [self nameField].text;
}

@end

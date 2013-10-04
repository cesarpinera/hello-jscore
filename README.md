hello-jscore
============

JavaScriptCore integration with ClojureScript in iOS

## Intro

JavaScriptCore enables evaluat of JavaScript code in Mac OS X and iOS. It also implements an idiomatic way of calling JavaScript from Objective-C and vice-versa. Though it has been present in Mac OS X for some time now, it's only now in iOS 7 that it has been officially ported to iOS. 

Proper documentation for JavaScriptCore is sadly lacking. Apple refers developers to the framwork headers, which are not enough to clearly grasp what is going on, and especially to gain a healthy understanding of how the framework is intended to be used. I was fortunate enough to be present during a WWDC talk about the framework, and the full video and source code for that talk is available in the Apple Developer portal. 

 * [WWDC 2013 Videos](https://developer.apple.com/wwdc/videos/). Look for "Integrating JavaScript into Native Apps"
 * [Color My Words sample code](https://developer.apple.com/downloads/index.action?name=WWDC%202013#). This is the sample project that is presented in the talk. 
 
## Goal

It would be interesting to be able to run Clojure (ClojureScript, in fact) programs in iOS, without the need to wrap it in a web application, or to make a web application pass as a native application. To achieve this, I wrote a trivial HelloWorld application that loads a ClojureScript program and calls a Clojure function, which in turn calls Objective-C to complete its task. 

Short version: **it works**. 

Long version: although it works, there will be some heavy lifting on the Objective-C side to expose existing functionality so that it can be called from ClojureScript. Whether this will be practical or not stands to be seen, but that is outside of the scope of this experiment. 

## How it is done

Start with an iOS application that targets iOS 7. One of the Objective-C classes will create an instance of JSContext, which initializes a JavaScript Virtual Machine behind the scenes. Once a JSContext has been acquired, the compiled CloureScript program is loaded, a handle to the target ClojureScript namespace is acquired, from which any exported ClojureScript functions can be called. 

Calls from ClojureScript into Objective-C are straitforward, using plain JavaScript interop. JSCore takes care of the bridge between the two languages. It's actually pretty neat. The main caveat is that on the Objective-C side we need to declare and implement a Protocol, which inherits from the JSExport protocol (defined in JSCore). Finally, since there's some impedance between Objective-C's reference counting and JavaScript garbage collection, it's better to pass a reference to the Objective-C objects that will need to be called back, to avoid retain cycles between the two runtimes that would leak memory. That's actually idiomatic in Clojure, so we're pretty much fine. 

This is how it looks like step-by-step. 

1. In Objective-C, create a Protocol that inherits from JSExport, and declare the functions that will be exported.

		@protocol HWViewController <JSExport>
		
		- (void)updateGreeting:(NSString*)someText;
		- (NSString*)name;
		
		@end


2.  Implement the protocol in one of your classes:

		@interface HWViewController : UIViewController <HWViewController, UITextFieldDelegate>
		
		@end

3.  Add the compiled js file to your project. Then add the js file to the "Copy Bundle Resources" phase in XCode, to make sure the js file makes into the actual .app bundle that's uploaded to the iOS device or simulator. 

4.  Create an instance of JSContext, read the js file and get a hold of the ClojureScript namespace (which is exported as a JavaScript object). In the following snippet, "context" and "hello" are defined as two @properties of the class (JSContext and JSValue respectively). 

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

5.  Finally, to call the ClojureScript function, we invoke the function in the "hello" property. Note that *greetFunction* expects an Objective-C object, and so it is invoked by passsing *self* as the argument. This allows ClojureScript to call back the Objective-C class. 

		// Retrieve the greet function
		JSValue *greetFunction = [self hello][@"greet"];
		
		// Call the function, passing self as the only parameter
		[greetFunction callWithArguments:@[self]];

6.  On the ClojureScript side, create a namespace and export the *greet* function. Using interop, call back into Objective-C as if it was JavaScript. It's very clean and straightforward. Note how the Objective-C class is automatically bridged to a JS object, and how the ClojureScript returned string is bridged to an NSString instance. 

		(ns hello)
		
		(defn ^:export greet
		  [view]
		  (let [name (.name view)]
		    (.updateGreeting view
		     (if (> (count name) 0)
		       (str "From cljs: Hello " name)
		       (str "From cljs: Hello World!")))))

7.  Compile and run. For ClojureScript I've only tried :whitespace optimizations. I have absolutely no idea if it will work with advanced optimizations or not. 

That is it. There is great WIN to be had. Next I will work on a less trivial project, which will allow me to get a sense of the performance of the JSCore bridge and how much of a heavy lifting we're looking at from the Objective-C side. 

Do contact me with your comments and ideas. cesar.pinera at gmail dot com. 

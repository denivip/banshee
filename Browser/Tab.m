//
//  Tab.m
//
//  Created by Alexandru Catighera on 4/28/11.
//  Copyright 2011 Evidon. All rights reserved.
//

#import "Tab.h"
#import "BrowserViewController.h"
#import "BookmarksFormController.h"
#import "UIMainView.h"

#import "ARBJavascriptBridgeCallback.h"

@implementation Tab

@synthesize tabButton, webView, closeButton, tabTitle, history, traverse, history_position, scrollPosition, currentURLString, currentURL, current, urlConnection, connectionURLString, actionSheetVisible, loadStartTime, loadEndTime, pageInfoJS, response, viewController, loading, pageData;

-(id) initWithFrame:(CGRect)frame addTarget:(BrowserViewController *) vc {
	if ((self = [super initWithFrame:frame])) {
        viewController = vc;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"page_info" ofType:@"js"];
        pageInfoJS = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        
		// Create tab button
		[self setTabButton:[UIButton buttonWithType:UIButtonTypeCustom]];
	
		// Style tab button
		[[tabButton layer] setCornerRadius: 5.0f];
		[[tabButton layer] setMasksToBounds:YES];
		[[tabButton layer] setBorderWidth: 0.5f];
	
		[tabButton setBackgroundColor:[UIColor grayColor]];
	
		tabButton.titleLabel.font = [UIFont systemFontOfSize: 11];
		[tabButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

		tabButton.contentEdgeInsets = UIEdgeInsetsMake(0.0, 8.0, 3.0, 0.0);
		tabButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		tabButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	
		tabButton.frame = CGRectMake(0.0, 0.0, 100.0, 26.0);
	
		// Create close tab button
		[self setCloseButton:[UIButton buttonWithType:UIButtonTypeCustom]];

        [closeButton setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
        [closeButton setAccessibilityLabel:@"close tab"];
		closeButton.frame = CGRectMake(77.0, -1.0, 25.0, 25.0);

		// append views
		[self addSubview:tabButton];
		[self addSubview:closeButton];
	
		// Set up webview
        UIWebView *wvTemplate = (UIWebView *)[viewController webViewTemplate];
        int minWebViewSize = wvTemplate.frame.size.height;
        int maxWebViewSize = minWebViewSize + [viewController bottomBar].frame.size.height;
        int height = [viewController bottomBar].alpha > 0.0 ? minWebViewSize : maxWebViewSize;
        CGRect frame = CGRectMake(wvTemplate.frame.origin.x, wvTemplate.frame.origin.y, wvTemplate.frame.size.width, height);
		webView = [[UIWebView alloc] initWithFrame:frame];
		webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		webView.scalesPageToFit = true;
        webView.scrollView.scrollEnabled = YES; 
        webView.scrollView.bounces = YES;
        webView.backgroundColor = [UIColor whiteColor];
		[webView sizeToFit];
		[webView setDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextualMenuAction:) name:@"TapAndHoldNotification" object:nil];
        
        // Scroll topbar
        [[webView scrollView] setDelegate:viewController];
        [[webView scrollView] setContentInset:UIEdgeInsetsMake([viewController topBar].frame.size.height, 0, 0, 0)];
        [[webView scrollView] setContentOffset:CGPointMake(0, - [viewController topBar].frame.size.height)];
        
		[[viewController view] addSubview:webView];
		[[viewController view] sendSubviewToBack:webView];
        [[viewController view] sendSubviewToBack:[viewController webViewTemplate]];
	
		// Set up interactions
		[tabButton addTarget:viewController 
					action:@selector(selectTab:)
					forControlEvents:UIControlEventTouchUpInside];
		[closeButton addTarget:viewController 
					action:@selector(removeTab:)
					forControlEvents:UIControlEventTouchUpInside];
		
        //Set history
        [self setHistory:[[NSMutableArray alloc] initWithCapacity:0]];
        traverse = 0;
        history_position = 0;
	
		//Set title
		[tabButton setTitle:@"New Tab" forState:UIControlStateNormal];
		[tabButton setTitle:@"New Tab" forState:UIControlStateHighlighted];
        

	}
	return self;
}

-(void) setTitle:(NSString *)title {
	if ([title length] > 11) {
		title = [[title substringToIndex:11] stringByAppendingString:@".."];
	}
	[[self tabButton] setTitle:title forState:UIControlStateNormal];
	[[self tabButton] setTitle:title forState:UIControlStateHighlighted];
    [[self tabButton] setAccessibilityLabel:[NSString stringWithFormat:@"Tab with title %@", title]];
    [[self closeButton] setAccessibilityLabel:[NSString stringWithFormat:@"Close Tab with title %@", title]];

}

-(void) select {
    current = YES;
	[tabButton setBackgroundColor:[UIColor whiteColor]];
	tabButton.selected = YES;
	tabButton.enabled = NO;
	[webView.superview bringSubviewToFront:webView];
	[self.superview bringSubviewToFront:self];
}

-(void) deselect {
    current = NO;
	[tabButton setBackgroundColor:[UIColor lightGrayColor]];
	tabButton.selected = NO;
	tabButton.enabled = YES;
	[webView.superview sendSubviewToBack:webView];
	[self.superview sendSubviewToBack:self];
}

-(void) incrementOffset {
	self.frame = CGRectOffset(self.frame, -100.0, 0.0);
}

-(void) hideText {
    [tabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(void) showText {
    [tabButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

// CONNECTION
#pragma mark -
#pragma mark urlConnection delegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    self.loading =YES;
    self.urlConnection = connection;
    self.connectionURLString = [[[connection currentRequest] URL] absoluteString];
    if (![self.connectionURLString hasSuffix:@"/"]) {
        self.connectionURLString = [self.connectionURLString stringByAppendingString:@"/"];
    }
    
    if (redirectResponse) {
        NSMutableURLRequest *r = [[connection currentRequest] mutableCopy]; // original request
        [r setURL: [request URL]];
        self.currentURL = [request URL];
        self.currentURLString = [[request URL] absoluteString];
        return r;
    } else {
        return request;
    }
}

- (void)connection: (NSURLConnection*) connection didReceiveResponse: (NSHTTPURLResponse*) response_
{
    self.currentURL = [response_ URL];
    self.currentURLString = [[response_ URL] absoluteString];
    [self setResponse:response_];
    if (current) {
        [[self progressBar] setProgress:0.25 animated:NO];
    }
    pageData = [[NSMutableData alloc] initWithLength:0];
}

- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data
{
    [pageData appendData: data];
    if ([[self progressBar] progress] < 0.75) {
        [[self progressBar] setProgress:[[self progressBar] progress] + .05 animated:NO];
    }
    // Broadcast a notification with the progress change, or call a delegate
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([pageData length] == 0) {
        [[self history] removeLastObject];
        self.currentURL = [[[self history] lastObject] URL];
        self.currentURLString = [[[[self history] lastObject] URL] absoluteString];
        if (current && ![currentURLString isEqualToString:@"about:blank"] && [currentURLString rangeOfString:@"https://duckduckgo.com"].location == NSNotFound) {
            [[viewController addressBar] setText:self.currentURLString];
        }
        
        [[self progressBar] setHidden:YES];
        return;
    }
    if ([[response MIMEType] isEqualToString:@"text/html"] || [[response MIMEType] isEqualToString:@"application/xhtml+xml"] || [[response MIMEType] isEqualToString:@"text/vnd.wap.wml"]) {
        NSStringEncoding enc;
        if ([response textEncodingName] != nil) {
            CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]);
            enc = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]));
        } else {
            enc = NSUTF8StringEncoding;
        }
        NSString *page = (NSString *)[[NSString alloc] initWithData:pageData encoding:enc];
        
        [[self webView] stopLoading];
        [[self webView] loadHTMLString:page baseURL:self.currentURL];
        
    } else {
        [[self webView] stopLoading];
        [[self webView] loadData:pageData MIMEType:[response MIMEType] textEncodingName:[response textEncodingName] baseURL:self.currentURL];
        //[whiteView setHidden:YES];
    }
    
    [[self progressBar] setProgress:0.75 animated:NO];
    pageData = nil;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[self progressBar] setHidden:YES];
    if ([[connection currentRequest] URL] != NULL) {
        [viewController cannotConnect:webView];
    } else {
     [[self webView] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"launch" ofType:@"html"]isDirectory:NO]]];
     [[viewController addressBar] setText:@""];
    }
}

-(UIProgressView *) progressBar {
    return current ? [viewController progressBar] : nil;
}

#pragma mark -
#pragma mark webview delegate

-(BOOL) webView:(UIWebView*)webView_ shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (request == nil) {
        return NO;
    }

    NSURL *URL = [request URL];
    ARBJavascriptBridgeCallback *callback = [[ARBJavascriptBridgeCallback alloc] initWithURL:URL];
    if (callback) {
        switch (callback.method) {
            case ARBJavascriptBridgeCallbackMethodPageLoaded:
                // CAPTURE PAGE LOAD
                [self webViewDidFinishFinalLoad:webView_];
                return NO;

            case ARBJavascriptBridgeCallbackMethodWindowOpen:
                if (viewController.popupsEnabled) {
                    [viewController addTabWithURL:callback.windowOpenURL];
                }
                return NO;

            default:
                break;
        }
    }

    if (! [viewController tabWebView:webView_ shouldStartLoadWithRequest:request]) {
        return NO;
    }
    
	//CAPTURE USER LINK-CLICK.
	if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted) {
        if ([[[request URL] absoluteString] isEqualToString:[[request mainDocumentURL] absoluteString]]) {
            NSURL *URL = [request URL];
            if ([[URL absoluteString] isEqualToString:@"about:blank"]) {
                return YES;
            }
            if ([[URL scheme] isEqualToString:@"http"] || [[URL scheme] isEqualToString:@"https"]) {
                if (current) {
                    [[viewController addressBar] setText:[URL absoluteString]];
                }
                [viewController loadRequest:request inTab:self updateHistory:YES];
            }
            return NO;
        }
	}
	return YES;
}

-(void) webViewDidStartLoad:(UIWebView *)webView {
}

-(void) webViewDidFinishFinalLoad:(UIWebView *)webView_ {
    self.loading = NO;
    if (current) {
        [viewController currentWebViewDidFinishFinalLoad:webView_];
    }
    
    // set title
    NSString *tabTitle_ = [webView_ stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([tabTitle_ length] == 0) {
        [self setTitle:@"Untitled"];
    } else {
        [self setTitle:tabTitle_];
    }
}

- (void)contextualMenuAction:(NSNotification*)notification
{
    if (actionSheetVisible || webView != [viewController webView]) {
        return;
    }
    CGPoint pt;
    NSDictionary *coord = [notification object];
    pt.x = [[coord objectForKey:@"x"] floatValue];
    pt.y = [[coord objectForKey:@"y"] floatValue];
    
    // convert point from window to view coordinate system
    pt = [webView convertPoint:pt fromView:nil];
    
    // convert point from view to HTML coordinate system
    CGSize viewSize = [webView frame].size;
    CGSize windowSize = [self windowSize];
    
    CGFloat f = windowSize.width / viewSize.width;
    pt.x = pt.x * f;// + offset.x;
    pt.y = pt.y * f;// + offset.y;
    
    [self openContextualMenuAt:pt];
}

- (void)openContextualMenuAt:(CGPoint)pt
{
    // Load the JavaScript code from the Resources and inject it into the web page
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JSTools" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString: jsCode];
    
    NSInteger topOffset;
    if ([viewController isPad]) {
        topOffset = ((NSInteger)[viewController topBar].frame.size.height) +
        ((NSInteger)[(UIMainView *)[viewController view] statusBarView].frame.size.height);
    } else {
        topOffset = ((NSInteger)[(UIMainView *)[viewController view] statusBarView].frame.size.height);
    }
    
    // get the Tags at the touch location
    NSArray *r = [[webView stringByEvaluatingJavaScriptFromString:
                      [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%li,%li);",(long)pt.x,(long)pt.y - topOffset]] componentsSeparatedByString:@"|"];
    
    NSString *tags = [r objectAtIndex:0];
    NSString *url = [r objectAtIndex:1];
    
    // create the UIActionSheet and populate it with buttons related to the tags
    if ([url isEqualToString:@""]) {
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[url isEqualToString:@""] ? @"Menu" : url
                                                       delegate:self cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil otherButtonTitles:nil];
    
    
    // If a link was touched, add link-related buttons
    if ([tags rangeOfString:@",A,"].location != NSNotFound) {
        [sheet addButtonWithTitle:@"Open Link"];
        [sheet addButtonWithTitle:@"Open Link in New Tab"];
        [sheet addButtonWithTitle:@"Copy Link"];
    }
    // If an image was touched, add image-related buttons
    if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
        [sheet addButtonWithTitle:@"Save Image"];
    }
    // Add buttons which should be always available
    [sheet addButtonWithTitle:@"Save Page as Bookmark"];
    [sheet addButtonWithTitle:@"Open Page in Safari"];
    
    [sheet showInView:webView];
}

- (CGSize)windowSize
{
    CGSize size;
    size.width = [[webView stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] integerValue];
    size.height = [[webView stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] integerValue];
    return size;
}

- (CGPoint)scrollOffset
{
    CGPoint pt;
    pt.x = [[webView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] integerValue];
    pt.y = [[webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
    return pt;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSURL *url = [NSURL URLWithString:[actionSheet title]];
    NSString *clickedButton = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([clickedButton isEqualToString:@"Open Link"]) {
        [viewController loadRequest:[[NSURLRequest alloc] initWithURL:url] inTab:self updateHistory:YES];
    } else if ([clickedButton isEqualToString:@"Open Link in New Tab"]) {
        [viewController addTabWithURL:[NSURL URLWithString:[actionSheet title]]];
    } else if ([clickedButton isEqualToString:@"Copy Link"]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [url absoluteString];
        [actionSheet resignFirstResponder];
    } else if ([clickedButton isEqualToString:@"Save Image"]) {
        UIImage *imageToBeSaved = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
        UIImageWriteToSavedPhotosAlbum(imageToBeSaved, nil, nil, nil);
    } else if ([clickedButton isEqualToString:@"Save Page as Bookmark"]) {
        [[viewController bookmarksFormController] setDefaultUrlFieldText:[url absoluteString]];
        [viewController addBookmarkFromSheet:actionSheet];
        [actionSheet resignFirstResponder];
    } else if ([clickedButton isEqualToString:@"Open Page in Safari"]) {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    actionSheetVisible = YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    actionSheetVisible = NO;
}


// HISTORY

-(BOOL) canGoBack {
    return history.count > 0 && history_position > 0;
}

-(BOOL) canGoForward {
    return history.count > 0 && history_position < history.count - 1;
}

-(void) goBack {
    [self go:-1];
}

-(void) goForward {
    [self go:1];
}

-(void) go:(int)t {
    NSURLRequest *req;
    [viewController forwardButton].enabled = FALSE;
    [viewController backButton].enabled = FALSE;
    traverse = t;
    history_position += traverse;
    req = [history objectAtIndex:history_position];
    
    //[[viewController addressBar] setText:[[req URL] absoluteString]];
    if (req != nil) {
        [viewController loadRequest:req inTab:self updateHistory:YES];
    }
}

-(void) updateHistory {
    if (traverse == 0) {
        if (history_position + 1 < history.count) {
            [history removeObjectsInRange:NSMakeRange(history_position + 1, history.count - history_position - 1)];
        }
        NSURLRequest *req = [[[self urlConnection] currentRequest] mutableCopy];
        
        [history addObject:req];
        history_position = history.count - 1;
    }
    traverse = 0;
}


@end

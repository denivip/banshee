//
//  BrowserViewController.h
//
//  Created by Alexandru Catighera on 3/5/13.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
@class Tab, BookmarksController, BookmarksFormController, Reachability;

@interface BrowserViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
	   
    IBOutlet UIView *webViewTemplate;
	IBOutlet UIScrollView *tabsView;
    IBOutlet UIView *topBar;
    IBOutlet UIToolbar *bottomBar;
	IBOutlet UIToolbar *navBar;
	
	IBOutlet UITextField *addressBar;
	NSMutableString *oldAddressText;
	
	IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIView *addressBarButtonsView;
	IBOutlet UIButton *refreshButton;
	IBOutlet UIButton *stopButton;
	
	IBOutlet UIBarButtonItem *forwardButton;
	IBOutlet UIBarButtonItem *backButton;
	IBOutlet UIBarButtonItem *addressItem;
	IBOutlet UIBarButtonItem *searchItem;
	IBOutlet UIBarButtonItem *moreButton;
	IBOutlet UIBarButtonItem *bookmarkButton;
    
    UIBarButtonItem *barItemPopoverPresenter;
	UIActionSheet *popupQuery;
    UIPopoverController *padPopover;
	
	IBOutlet UIButton *addTab;
	Tab *selectedTab;
	NSMutableArray *tabs;
    
    NSURL *gotoUrl;
    
	UINavigationController *bookmarksController;
	BookmarksFormController *bookmarksFormController;	
        
    BOOL reloadOnPageLoad;
    BOOL initialPageLoad;
    BOOL saveScrollPosition;
    
    NSString *userAgent;
    
    
    IBOutlet UIProgressView *progressBar;
    float contentSize;
    
}
@property(nonatomic,strong) UIView *webViewTemplate;

@property(nonatomic,strong) UIScrollView *tabsView;
@property(nonatomic,strong) UIView *topBar;
@property(nonatomic,strong) UIToolbar *bottomBar;

@property(nonatomic,strong) UIToolbar *navBar;
@property(nonatomic,strong) UIToolbar *bugListNavBar;
@property(nonatomic,strong) UITextField *addressBar;
@property(nonatomic,strong) UITextField *searchBar;
@property(nonatomic,strong) NSMutableString *oldAddressText;

@property(nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic,strong) UIView *addressBarButtonsView;
@property(nonatomic,strong) UIButton *refreshButton;
@property(nonatomic,strong) UIButton *stopButton;

@property(nonatomic,strong) UIBarButtonItem *forwardButton;
@property(nonatomic,strong) UIBarButtonItem *backButton;
@property(nonatomic,strong) UIBarButtonItem *addressItem;
@property(nonatomic,strong) UIBarButtonItem *searchItem;
@property(nonatomic,strong) UIBarButtonItem *moreButton;
@property(nonatomic,strong) UIBarButtonItem *bookmarkButton;

@property(nonatomic,strong) UIBarButtonItem *barItemPopoverPresenter;
@property(nonatomic,strong) UIActionSheet *popupQuery;
@property(nonatomic,strong) UIPopoverController *padPopover;

@property(nonatomic,strong) UIButton *addTab;
@property(nonatomic,strong) Tab *selectedTab;
@property(nonatomic,strong) NSMutableArray *tabs;

@property(nonatomic,strong) NSURL *gotoUrl;

@property(nonatomic,strong) UINavigationController *bookmarksController;
@property(nonatomic,strong) BookmarksFormController *bookmarksFormController;
@property(nonatomic,strong) BrowserViewController *browserController;

@property(nonatomic,assign) BOOL reloadOnPageLoad;
@property(nonatomic,assign) BOOL initialPageLoad;
@property(nonatomic,assign) BOOL saveScrollPosition;
@property(nonatomic, assign) NSInteger lastScrollContentOffset;

@property(nonatomic,strong) NSString *userAgent;

@property(nonatomic,strong) UIProgressView *progressBar;
@property(nonatomic,assign) float contentSize;

-(IBAction) gotoAddress:(id)sender;
-(IBAction) didStartEditingAddressBar:(id)sender;
-(IBAction) searchWeb:(id)sender;
-(IBAction) goBack:(id)sender;
-(IBAction) goForward:(id)sender;
-(IBAction) stopLoading:(id)sender;
-(IBAction) showBookmarks:(id)sender;
-(IBAction) scrollToTop:(id)sender;

-(NSArray *) actionSheetButtons;
-(IBAction) showActionSheet:(id)sender;
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

-(IBAction) addTab:(id)sender;
- (void)addTabWithURL:(NSURL *)URL;
-(IBAction) selectTab:(id)sender;
-(IBAction) removeTab:(id)sender;
-(IBAction) toggleTabsView:(id)sender;

-(void) loadTabs:(UIWebView *) webView;
-(void) switchTabFrom:(Tab *)fromTab ToTab:(Tab *)toTab;

-(void) showBookmarksView:(id)sender;
-(void) addBookmarkFromSheet:(UIActionSheet *) sheet;

-(UIWebView *) webView;
-(UIWebView *) setWebView:(UIWebView *) newWebView;
-(void) currentWebViewDidFinishFinalLoad:(UIWebView *) webView;

-(BOOL)isPad;

-(BOOL) checkNetworkStatus;

-(void) cannotConnect:(UIWebView *) cnWebView;

- (void)loadRequest:(NSURLRequest *)request inTab:(Tab *)tab updateHistory:(BOOL)updateHistory;

-(void) saveOpenTabs;
-(void) openSavedTabs;
-(void) deleteSavedTabs;

#pragma mark - Override in subclass

- (BOOL)tabWebView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request;

@end

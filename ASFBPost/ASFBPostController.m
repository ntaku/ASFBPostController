//
//  Copyright (c) 2012 AppStair LLC. All rights reserved.
//  http://appstair.com
//

// Facebook
#define FB_APP_ID             @"1234567"

// UserDefault for Facebook
#define FB_ACCESS_TOKEN       @"FBAccessTokenKey"
#define FB_EXPIRATION_DATE    @"FBExpirationDateKey"
#define FB_LOGINNAME          @"FBLoginName"

#import "ASFBPostController.h"
#import "FBConnect.h"
#import "AppDelegate.h"
#import "ASColor+Hex.h"

@interface ASFBPostController () <FBSessionDelegate, FBRequestDelegate>

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSString *loginName;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIAlertView *loadingAlert;

- (void)createFbInstance;
- (void)setViewStyle;
- (void)loading:(BOOL)isLoading;
- (BOOL)isIpad;

@end


@implementation ASFBPostController

@synthesize facebook        = _facebook;
@synthesize loginName       = _loginName;
@synthesize textView        = _textView;
@synthesize loadingAlert    = _loadingAlert;
@synthesize originalImage   = _originalImage;
@synthesize thumbnailImage  = _thumbnailImage;


- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)dealloc{
    [UIAppDelegate setFacebook:nil];
    
    [_facebook release], _facebook = nil;
    [_loginName release], _loginName = nil;
    [_textView release], _textView = nil;
    [_loadingAlert release], _loadingAlert = nil;
    [_thumbnailImage release], _thumbnailImage = nil;
    [_originalImage release], _originalImage = nil;
    [super dealloc];
}

- (id)init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        self.title = @"Facebook";
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View LifeCycle
///////////////////////////////////////////////////////////////////////////////////////////////////


- (void)viewDidLoad{
    [super viewDidLoad];
    [self createFbInstance];

    self.tableView.backgroundColor = [UIColor colorWithHex:0xE1E6EF];
    self.tableView.scrollEnabled = NO;

    // navi buttons
    UIBarButtonItem *btn;    
    btn = [[UIBarButtonItem alloc]
           initWithTitle:NSLocalizedString(@"FB_POST", @"")
           style:UIBarButtonItemStyleBordered
           target:self
           action:@selector(actionSave)];
    self.navigationItem.rightBarButtonItem = btn;
    [btn release];
    
    btn = [[UIBarButtonItem alloc]
           initWithTitle:NSLocalizedString(@"FB_CANCEL", @"")
           style:UIBarButtonItemStyleBordered
           target:self 
           action:@selector(actionCancel)];
    self.navigationItem.leftBarButtonItem = btn;
    [btn release];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setViewStyle];
}

- (void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
    [self setViewStyle];
    [self.textView becomeFirstResponder];
}

- (void)setViewStyle{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHex:0x2C4287];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    if([self isIpad]){
        return YES;
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Delegate (UITableView)
///////////////////////////////////////////////////////////////////////////////////////////////////


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return 45;
    }
    return [self isIpad] ? 120 : 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"indexCell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"indexCell"] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
 	}
    
    // accout
    if(indexPath.row == 0){        
        UIButton *_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image;
        
        if([self.facebook isSessionValid]){
            image = [UIImage imageNamed:@"FBConnect.bundle/images/LogoutNormal.png"];
            [_btn addTarget:self action:@selector(fbLogout) forControlEvents:UIControlEventTouchUpInside];
            cell.textLabel.text = self.loginName;
        }else{
            image = [UIImage imageNamed:@"FBConnect.bundle/images/LoginNormal.png"];        
            [_btn addTarget:self action:@selector(fbLogin) forControlEvents:UIControlEventTouchUpInside];
            cell.textLabel.text = NSLocalizedString(@"FB_NEED_LOGIN", @"");
        }
        
        [_btn setBackgroundImage:image forState:UIControlStateNormal];
        [_btn setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];        
        cell.accessoryView = _btn;

    // message
    }else{
        CGFloat thumbSize = [self isIpad] ? 100 : 60;
        CGFloat textSzie = [self isIpad] ? 348 : 210;
        
        UIImageView *_back = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, thumbSize, thumbSize)];
        _back.image = self.thumbnailImage;
        [cell.contentView addSubview:_back];
        [_back release];
        
        if(!self.textView){
            UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(thumbSize + 20, 10, textSzie, thumbSize)];
            tv.font = [UIFont systemFontOfSize:16];
            tv.backgroundColor = [UIColor colorWithHex:0xefefef];
            self.textView = tv;
            [tv release];
        }else{
            [self.textView removeFromSuperview];
        }
        [cell.contentView addSubview:self.textView];
    }    
	return cell;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Action
///////////////////////////////////////////////////////////////////////////////////////////////////


- (void)actionSave{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.originalImage, @"source", 
                                   self.textView.text, @"message",
                                   nil];
    
    [self.facebook requestWithGraphPath:@"me/photos"
                              andParams:params
                          andHttpMethod:@"POST"
                            andDelegate:self];
}

- (void)actionCancel{
    [self dismissModalViewControllerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Facebook Login/Logout
///////////////////////////////////////////////////////////////////////////////////////////////////


- (void)createFbInstance{
    if(self.facebook){
        return;
    }
    Facebook *fb = [[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:self];
    self.facebook = fb;
    [UIAppDelegate setFacebook:self.facebook];
    [fb release];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:FB_ACCESS_TOKEN];
    NSDate *expire = [defaults objectForKey:FB_EXPIRATION_DATE];
    NSString *name = [defaults objectForKey:FB_LOGINNAME];
    
    if(token && expire && name){
        self.facebook.accessToken = token;
        self.facebook.expirationDate = expire;
        self.loginName = name;
    }
    if (![self.facebook isSessionValid]) {
        [self clearFbSession];
    }
}

- (void)fbLogin{
    [self createFbInstance];
    
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"publish_stream", nil];
    [self.facebook authorize:permissions];
    [permissions release];
}

- (void)fbLogout{
    [self loading:YES];
    [self.facebook logout];
    [_facebook release], _facebook = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Delegate (FBSessionDelegate)
///////////////////////////////////////////////////////////////////////////////////////////////////


// get user info and check requried permission
// API explorer
// http://developers.facebook.com/tools/explorer/?method=GET&path=me%2Fpermissions

- (void)fbDidLogin {
    NSLog(@"facebook: did login");
    [self saveFbSession:self.facebook.accessToken expiresAt:self.facebook.expirationDate];
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
    [self.facebook requestWithGraphPath:@"me/permissions" andDelegate:self];
}

- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt{
    NSLog(@"facebook: token extended");
    [self saveFbSession:accessToken expiresAt:expiresAt];
}

- (void)fbDidLogout{
    NSLog(@"facebook: did logout");
    [self loading:NO];
    [self clearFbSession];
    [self.tableView reloadData];
}

- (void)fbDidNotLogin:(BOOL)cancelled{
    // nothing todo
}

- (void)fbSessionInvalidated{
    [self clearFbSession];
    [self fbLogout];
}

- (void)saveFbSession:(NSString*)accessToken expiresAt:(NSDate*)expiresAt{
    NSLog(@"facebook: save session");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(accessToken && expiresAt){
        [defaults setObject:accessToken forKey:FB_ACCESS_TOKEN];
        [defaults setObject:expiresAt forKey:FB_EXPIRATION_DATE];
        [defaults synchronize];
    }
}

- (void)clearFbSession{
    NSLog(@"facebook: clear session");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:FB_ACCESS_TOKEN];
    [defaults removeObjectForKey:FB_EXPIRATION_DATE];
    [defaults removeObjectForKey:FB_LOGINNAME];
    [defaults synchronize];
    self.loginName = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Delegate (FBRequestDelegate)
///////////////////////////////////////////////////////////////////////////////////////////////////


- (void)requestLoading:(FBRequest *)request{
    if([request.url isEqual:@"https://graph.facebook.com/me/photos"]){
        [self loading:YES];
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"%@", [error description]);
    [self loading:NO];
    
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle:@""
                          message:NSLocalizedString(@"FB_ERROR", @"")
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}

- (void)request:(FBRequest *)request didLoad:(id)result{
    NSLog(@"%@ : %@", request.url, [result description]);
    [self loading:NO];
    
    if(!result){
        return;
    }
    
    // permission check
    if([request.url isEqual:@"https://graph.facebook.com/me/permissions"]){
        NSArray *data = [((NSDictionary *)result) objectForKey:@"data"];
        if(data.count > 0){
            int isPermitted = [[(NSDictionary *)[data objectAtIndex:0] objectForKey:@"publish_stream"] intValue];
            if(!isPermitted){
                UIAlertView *alert = [[UIAlertView alloc] 
                                      initWithTitle:@""
                                      message:NSLocalizedString(@"FB_NO_PERMISSION", @"")
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"OK", nil];
                [alert show];
                [alert release];
                [self fbLogout];
            }
        }
        
    // user info
    }else if([request.url isEqual:@"https://graph.facebook.com/me"]){
        self.loginName = [((NSDictionary *)result) objectForKey:@"name"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.loginName forKey:FB_LOGINNAME];
        [defaults synchronize]; 
        [self.tableView reloadData];
        
    // post
    }else if([request.url isEqual:@"https://graph.facebook.com/me/photos"]){
        NSString *postId = [((NSDictionary *)result) objectForKey:@"post_id"];
        if(postId){
            [self actionCancel];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] 
                                  initWithTitle:@""
                                  message:NSLocalizedString(@"FB_NO_PERMISSION2", @"")
                                  delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];            
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Util
///////////////////////////////////////////////////////////////////////////////////////////////////


- (void)loading:(BOOL)isLoading{    
    // start loading
    if(isLoading){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if(self.loadingAlert){
            return;
        }    
        UIAlertView *_alert = [[UIAlertView alloc] initWithTitle: @"Loading"
                                                         message: @""
                                                        delegate: nil
                                               cancelButtonTitle: nil
                                               otherButtonTitles: nil];
        self.loadingAlert = _alert;
        [_alert release];
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake(139.0f-18.0f, 51.0f, 37.0f, 37.0f);
        [self.loadingAlert addSubview:activityView];
        [activityView startAnimating];
        [activityView release];
        
        [self.loadingAlert show];
        
    // stop loading
    }else{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.loadingAlert dismissWithClickedButtonIndex:0 animated:NO];
        [_loadingAlert release], _loadingAlert = nil;
    }
}

- (BOOL)isIpad{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

@end

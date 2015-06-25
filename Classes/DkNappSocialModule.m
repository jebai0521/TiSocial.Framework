/**
 * Module developed by Napp CMS
 * Mads Møller
 * 
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "DkNappSocialModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "NappCustomActivity.h"
#import "NappItemProvider.h"
#import "UIActivityLocationtemProvider.h"
#import "UIActivityMultiChannelTextItemProvider.h"
#import "SSUtil.h"

#import "SSNetworkModule.h"
#import "SSActivityModule.h"

//include Social and Accounts Frameworks
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation DkNappSocialModule

# pragma mark Activties

MAKE_SYSTEM_PROP(ACTIVITY_FACEBOOK, UIActivityTypePostToFacebook);
MAKE_SYSTEM_PROP(ACTIVITY_TWITTER, UIActivityTypePostToTwitter);
MAKE_SYSTEM_PROP(ACTIVITY_WEIBO, UIActivityTypePostToWeibo);
MAKE_SYSTEM_PROP(ACTIVITY_MESSAGE, UIActivityTypeMessage);
MAKE_SYSTEM_PROP(ACTIVITY_MAIL, UIActivityTypeMail);
MAKE_SYSTEM_PROP(ACTIVITY_PRINT, UIActivityTypePrint);
MAKE_SYSTEM_PROP(ACTIVITY_COPY, UIActivityTypeCopyToPasteboard);
MAKE_SYSTEM_PROP(ACTIVITY_ASSIGN_CONTACT, UIActivityTypeAssignToContact);
MAKE_SYSTEM_PROP(ACTIVITY_SAVE_CAMERA, UIActivityTypeSaveToCameraRoll);

// iOS7+
MAKE_SYSTEM_PROP(ACTIVITY_READING_LIST, UIActivityTypeAddToReadingList);
MAKE_SYSTEM_PROP(ACTIVITY_FLICKR, UIActivityTypePostToFlickr);
MAKE_SYSTEM_PROP(ACTIVITY_VIMEO, UIActivityTypePostToVimeo);
MAKE_SYSTEM_PROP(ACTIVITY_AIRDROP, UIActivityTypeAirDrop);
MAKE_SYSTEM_PROP(ACTIVITY_TENCENT_WEIBO, UIActivityTypePostToTencentWeibo);

// Custom
MAKE_SYSTEM_PROP(ACTIVITY_CUSTOM, 100);


#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"8152d7fc-6edb-4c40-8d6f-bc2cef87bc1a";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"dk.napp.social";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	popoverController = nil;
	accountStore = nil;

	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module (project uses ARC now)
//	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

-(NSNumber*)isTwitterSupported:(id)args {
    if(NSClassFromString(@"SLComposeViewController") != nil){
        return [SSNetworkModule isNetworkSupported:SLServiceTypeTwitter];
    }else if(NSClassFromString(@"TWTweetComposeViewController") != nil){
        return NUMBOOL(YES);
    }else{
        return NUMBOOL(NO);
    }
}

-(NSNumber*)isRequestTwitterSupported:(id)args { //for iOS6 twitter
    return [TiUtils isIOS6OrGreater]?[SSNetworkModule isNetworkSupported:SLServiceTypeTwitter]:NUMBOOL(NO);
}

-(NSNumber*)isFacebookSupported:(id)args {
    return [TiUtils isIOS6OrGreater]?[SSNetworkModule isNetworkSupported:SLServiceTypeFacebook]:NUMBOOL(NO);
}

-(NSNumber*)isSinaWeiboSupported:(id)args {
    return [TiUtils isIOS6OrGreater]?[SSNetworkModule isNetworkSupported:SLServiceTypeSinaWeibo]:NUMBOOL(NO);
}

-(NSNumber*)isActivityViewSupported:(id)args {
    return [TiUtils isIOS6OrGreater]?[SSActivityModule isActivitySupported]:NUMBOOL(NO);
}

/*
 * Accounts
 */
-(void)twitterAccountList:(id)args
{
    if(accountStore == nil){
        accountStore =  [[ACAccountStore alloc] init];
    }
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
    
    // request access
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
         if (granted == YES) {
             NSArray * arrayOfAccounts = [accountStore accountsWithAccountType:accountType];
//             [arrayOfAccounts retain];
             
             NSMutableArray *accounts = [[NSMutableArray alloc] init];
             NSMutableDictionary * dictAccounts = [[NSMutableDictionary alloc] init];
             for( int i = 0; i < [arrayOfAccounts count]; i++ )
             {
                 ACAccount * account = [arrayOfAccounts objectAtIndex:i];
                 NSString *userID = [[account valueForKey:@"properties"] valueForKey:@"user_id"];
                 NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                        userID, @"userId",
                                        [NSString stringWithString:account.username], @"username",
                                        [NSString stringWithString:account.identifier], @"identifier",
                                        nil];
                 [accounts addObject:dict];
             }
             [dictAccounts setObject:accounts forKey:@"accounts"];
             [self fireEvent:@"accountList" withObject:dictAccounts];
         } else {
             NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"No account",@"status",[error localizedDescription], @"message", @"twitter",@"platform",nil];
             [self fireEvent:@"error" withObject:event];
         }
    }];
}

- (void) shareToNetwork:(id)args
{
    ENSURE_UI_THREAD(shareToNetwork, args);
    
    
    []
}


-(void)grantFacebookPermissions:(id)args {
    NSDictionary *arguments = [args objectAtIndex:0];
    
    NSArray *permissionsArray = nil;
        
    if(accountStore == nil){
        accountStore =  [[ACAccountStore alloc] init];
    }
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSString *appId = [arguments objectForKey:@"appIdKey"];
    NSString *permissions = [arguments objectForKey:@"permissionsKey"];
    
    // Append permissions
    if(permissions != nil) {
        permissionsArray = [permissions componentsSeparatedByString:@","];
    }
    
    NSDictionary *options = @{
                              ACFacebookAppIdKey: appId,
                              ACFacebookAudienceKey: ACFacebookAudienceEveryone,
                              ACFacebookPermissionsKey: permissionsArray
                              };
    
    // request access
    [accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error){
        if (granted == YES) {
            NSArray *arrayOfAccounts = [accountStore accountsWithAccountType:accountType];
            
            if ([arrayOfAccounts count] > 0) {
                ACAccount *fbAccount = [arrayOfAccounts lastObject];

                // Get the access token. It could be used in other scenarios
                ACAccountCredential *fbCredential = [fbAccount credential];
                NSString *accessToken = [fbCredential oauthToken];
                
                NSDictionary * account = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSString stringWithString:fbAccount.username], @"username",
                                       [NSString stringWithString:fbAccount.identifier], @"identifier",
                                       [NSString stringWithString:accessToken], @"accessToken",
                                       nil];
                
                NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: NUMBOOL(YES),@"success", account,@"account", @"facebook",@"platform", nil];
                [self fireEvent:@"facebookAccount" withObject:event];
                
            } else {
                NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"No account",@"status", @"facebook",@"platform", nil];
                [self fireEvent:@"error" withObject:event];
            }
        } else {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"Permission denied",@"status",[error localizedDescription], @"message", @"facebook",@"platform", nil];
            [self fireEvent:@"error" withObject:event];
        }
    }];
}

-(void)renewFacebookAccessToken:(id)args {
    if(accountStore == nil){
        accountStore =  [[ACAccountStore alloc] init];
    }
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSArray *arrayOfAccounts = [accountStore accountsWithAccountType:accountType];
    if ([arrayOfAccounts count] > 0) {
        ACAccount *fbAccount = [arrayOfAccounts lastObject];
        [accountStore renewCredentialsForAccount:fbAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
            if (error){
                NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"renew failed",@"status",[error localizedDescription], @"message", @"facebook",@"platform",nil];
                [self fireEvent:@"error" withObject:event];
            } else {
                ACAccountCredential *fbCredential = [fbAccount credential];
                NSString *accessToken = [fbCredential oauthToken];
                NSDictionary * account = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithString:fbAccount.username], @"username",
                                          [NSString stringWithString:fbAccount.identifier], @"identifier",
                                          [NSString stringWithString:accessToken], @"accessToken",
                                          nil];
                NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: NUMBOOL(YES),@"success", account,@"account", @"facebook",@"platform", nil];
                [self fireEvent:@"facebookAccount" withObject:event];
            }
        }];
    } else {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"No account",@"status", @"facebook",@"platform", nil];
        [self fireEvent:@"error" withObject:event];
    }
}


-(void)requestFacebookWithIdentifier:(id)args {
    NSDictionary *arguments = [args objectAtIndex:0];
    
    // Defaults
    NSDictionary *requestParameter = nil;
    NSArray *permissionsArray = nil;
    
    if([args count] > 1){
        requestParameter = [args objectAtIndex:1];
    }
    
    NSString *selectedAccount = [TiUtils stringValue:@"accountWithIdentifier" properties:arguments def:nil];
    NSString *callbackEventName = [TiUtils stringValue:@"callbackEvent" properties:arguments def:@"facebookRequest"];
    
    if(selectedAccount != nil){
        //requestType: GET, POST, DELETE
        NSInteger facebookRequestMethod = SLRequestMethodPOST;
        NSString *requestType = [[TiUtils stringValue:@"requestType" properties:arguments def:@"POST"] uppercaseString];
        
        if( [requestType isEqualToString:@"POST"] ){
            facebookRequestMethod = SLRequestMethodPOST;
        } else if( [requestType isEqualToString:@"GET"] ){
            facebookRequestMethod = SLRequestMethodGET;
        } else if( [requestType isEqualToString:@"DELETE"] ) {
            facebookRequestMethod = SLRequestMethodDELETE;
        } else {
            NSLog(@"[Social] no valid request method found - using POST");
        }
        
        //args
        NSString *requestURL = [arguments objectForKey:@"url"];
        
        if(requestURL != nil ){
            SLRequest *fbRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:facebookRequestMethod URL:[NSURL URLWithString:requestURL] parameters:requestParameter];
            [fbRequest setAccount:[accountStore accountWithIdentifier:selectedAccount]];
            [fbRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
                NSNumber *isSuccess;
                
                if ([urlResponse statusCode] == 200) {
                    isSuccess = NUMBOOL(YES);
                } else {
                    isSuccess = NUMBOOL(NO);
                }
                
                NSArray *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: isSuccess,@"success", response,@"response", @"facebook",@"platform", nil];
                [self fireEvent:callbackEventName withObject:event];
            }];
            
        } else {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"Missing arguments",@"status", @"facebook",@"platform", nil];
            [self fireEvent:@"error" withObject:event];
        }
        
    } else {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"Missing arguments",@"status", @"facebook",@"platform", nil];
        [self fireEvent:@"error" withObject:event];
    }
    
}

-(void)requestFacebook:(id)args{
    NSDictionary *arguments = [args objectAtIndex:0];
    
    // Defaults
    NSDictionary *requestParameter = nil;
    NSArray *permissionsArray = nil;
    
    if([args count] > 1){
        requestParameter = [args objectAtIndex:1];
    }

    if(accountStore == nil){
        accountStore =  [[ACAccountStore alloc] init];
    }
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSString *appId = [arguments objectForKey:@"appIdKey"];
    NSString *permissions = [arguments objectForKey:@"permissionsKey"];
    NSString *callbackEventName = [TiUtils stringValue:@"callbackEvent" properties:arguments def:@"facebookRequest"];
    
    
    // Append permissions
    if(permissions != nil) {
       permissionsArray = [permissions componentsSeparatedByString:@","];
    }
    
    NSDictionary *options = @{
        ACFacebookAppIdKey: appId,
        ACFacebookAudienceKey: ACFacebookAudienceEveryone,
        ACFacebookPermissionsKey: permissionsArray
    };
    
    
    [accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error){
        if (granted){
            NSArray *arrayOfAccounts = [accountStore accountsWithAccountType:accountType];
            
            if ([arrayOfAccounts count] > 0) {
                ACAccount *fbAccount = [arrayOfAccounts lastObject];
                
                
                // Get the access token. It could be used in other scenarios
                ACAccountCredential *fbCredential = [fbAccount credential];
                NSString *accessToken = [fbCredential oauthToken];
                
                //requestType: GET, POST, DELETE
                NSInteger facebookRequestMethod = SLRequestMethodPOST;
                NSString *requestType = [[TiUtils stringValue:@"requestType" properties:arguments def:@"POST"] uppercaseString];
                
                if( [requestType isEqualToString:@"POST"] ){
                    facebookRequestMethod = SLRequestMethodPOST;
                } else if( [requestType isEqualToString:@"GET"] ){
                    facebookRequestMethod = SLRequestMethodGET;
                } else if( [requestType isEqualToString:@"DELETE"] ) {
                    facebookRequestMethod = SLRequestMethodDELETE;
                } else {
                    NSLog(@"[Social] no valid request method found - using POST");
                }
                
                //args
                NSString *requestURL = [arguments objectForKey:@"url"];
                
                if(requestURL != nil ){
 
                    SLRequest *fbRequest = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                                   requestMethod:facebookRequestMethod
                                                                             URL:[NSURL URLWithString:requestURL]
                                                                      parameters:requestParameter];
                    
                    [fbRequest setAccount:fbAccount];
                    
                    [fbRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
                        NSNumber *isSuccess;
                                        
                        if ([urlResponse statusCode] == 200) {
                            isSuccess = NUMBOOL(YES);
                        } else {
                            isSuccess = NUMBOOL(NO);
                        }
                        
                        NSArray *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: isSuccess,@"success", response,@"response", accessToken,@"accessToken", @"facebook",@"platform", nil];
                        [self fireEvent:callbackEventName withObject:event];
                    }];
                    
                } else {
                    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"Missing arguments",@"status", @"facebook",@"platform", nil];
                    [self fireEvent:@"error" withObject:event];
                }
            }
        } else {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"No account",@"status",[error localizedDescription], @"message", @"facebook",@"platform", nil];
            [self fireEvent:@"error" withObject:event];
        }
    }];
}



///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
//                  TWITTER API
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

#pragma mark - TWITTER API
#pragma mark -

/**
 * args[0] - requestType, url, accountWithIdentifier
 * args[1] - requestParameter
 *
 */
-(void)requestTwitter:(id)args {
    NSDictionary *arguments = [args objectAtIndex:0];
    
    // Defaults
    NSDictionary *requestParameter = nil;
    
    if([args count] > 1){
        requestParameter = [args objectAtIndex:1];
    }
    
    if(accountStore == nil){
        accountStore =  [[ACAccountStore alloc] init];
    }

    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
    
    NSString *callbackEventName = [TiUtils stringValue:@"callbackEvent" properties:arguments def:@"twitterRequest"];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted == YES){
            NSArray *arrayOfAccounts = [accountStore accountsWithAccountType:accountType];
            
            if ([arrayOfAccounts count] > 0) {
                NSString *selectedAccount = [TiUtils stringValue:@"accountWithIdentifier" properties:arguments def:nil];
                ACAccount *twitterAccount;
                if(selectedAccount !=nil){
                    //user selected
                    twitterAccount = [accountStore accountWithIdentifier:selectedAccount];
                    if(twitterAccount == nil){
                        //fallback
                        NSLog(@"[ERROR] Account with identifier does not exist");
                        twitterAccount = [arrayOfAccounts lastObject];
                    }
                } else {
                    //use last account in array
                    twitterAccount = [arrayOfAccounts lastObject];
                }
                
                
                //requestType: GET, POST, DELETE
                NSInteger requestMethod = SLRequestMethodPOST;
                NSString *requestType = [[TiUtils stringValue:@"requestType" properties:arguments def:@"POST"] uppercaseString];
                
                if( [requestType isEqualToString:@"POST"] ){
                    requestMethod = SLRequestMethodPOST;
                } else if( [requestType isEqualToString:@"GET"] ){
                    requestMethod = SLRequestMethodGET;
                } else if( [requestType isEqualToString:@"DELETE"] ) {
                    requestMethod = SLRequestMethodDELETE;
                } else {
                    NSLog(@"[Social] no valid request method found - using POST");
                }
                
                //args
                NSString *requestURL = [TiUtils stringValue:@"url" properties:arguments def:nil];
                if(requestURL != nil){
                    
                    SLRequest *twitterRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                            requestMethod:requestMethod
                                                                            URL:[NSURL URLWithString:requestURL]
                                                                            parameters:requestParameter];
                    [twitterRequest setAccount:twitterAccount];
                    [twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
                         NSNumber *isSuccess;
                         if ([urlResponse statusCode] == 200) {
                             isSuccess = NUMBOOL(YES);
                         } else {
                             isSuccess = NUMBOOL(NO);
                         }
                         //NSString *response = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                         NSArray *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                         NSString *rawData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                         NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys: isSuccess,@"success", response,@"response", rawData,@"rawResponse", @"twitter",@"platform", nil];
                         [self fireEvent:callbackEventName withObject:event];
                     }];
                    
                } else {
                    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"Missing arguments",@"status", @"twitter",@"platform",nil];
                    [self fireEvent:@"error" withObject:event];
                }
            }
        } else {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",@"No account",@"status",[error localizedDescription], @"message",  @"twitter",@"platform", nil];
            [self fireEvent:@"error" withObject:event];
        }
    }];
}


/*
 *  Twitter
 */

-(void)twitter:(id)args{
    ENSURE_UI_THREAD(twitter, args);
    
    if(NSClassFromString(@"SLComposeViewController") != nil){
        [self shareToNetwork:SLServiceTypeTwitter args:args];
    }
}

/*
 *  Sina Weibo
 */

-(void)sinaweibo:(id)args{
    ENSURE_UI_THREAD(sinaweibo, args);
    [self shareToNetwork:SLServiceTypeSinaWeibo args:args];
}

/*
 *  Facebook
 */

-(void)facebook:(id)args{
    ENSURE_UI_THREAD(facebook, args);
    [self shareToNetwork:SLServiceTypeFacebook args:args];
}

#pragma mark - UIActivityViewController
#pragma mark -

- (NSMutableArray*) getActivityItems:(id)args
{
    NSLog(@"args ==> %@", args);
    
    NSDictionary *arguments = nil;
    NSArray *customActivities = nil;
    
    if([args count] > 1){
        customActivities = [args objectAtIndex:1];
        arguments = [args objectAtIndex:0];
    } else {
        arguments = [args objectAtIndex:0];
    }
    
    // Get Properties from JavaScript
    NSObject * shareText = nil;
    if ([[arguments allKeys] containsObject:@"text"]) {
        shareText = [arguments objectForKey:@"text"];
    }
    NSLog(@"shareText ==> %@", shareText);
    
    NSURL *shareURL = [NSURL URLWithString:[TiUtils stringValue:@"url" properties:arguments def:nil]];
    NSURL *vcardURL = [NSURL URLWithString:[TiUtils stringValue:@"vcf" properties:arguments def:nil]];
    NSString *removeIcons = [TiUtils stringValue:@"removeIcons" properties:arguments def:nil];
    BOOL emailIsHTML = [TiUtils boolValue:@"emailIsHTML" properties:arguments def:NO];
    
    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    
    //added M Hudson 22/10/14 to allow for blob support
    id TiImageObject = [arguments objectForKey:@"image"];
    if(TiImageObject != nil) {
        //see if we passed in a string reference to the file or a TiBlob object
        if([TiImageObject isKindOfClass:[TiBlob class]]) {
            UIImage *image = [(TiBlob*)TiImageObject image];
            if(image){
                [activityItems addObject:image];
            }
        } else {
            NSString *shareImage = [TiUtils stringValue:@"image" properties:arguments def:nil];
            if (shareImage != nil) {
                UIImage *image = [self findImage:shareImage];
                if(image){
                    [activityItems addObject:image];
                }
            }
        }
    }
    
    if(shareURL && vcardURL){
        [activityItems addObject:[[UIActivityLocationtemProvider alloc] initWithVCardURL:vcardURL normalURL:shareURL]];
    } else if (shareURL) {
        [activityItems addObject:shareURL];
    } else if (vcardURL) {
        [activityItems addObject:vcardURL];
    }
    
    return activityItems;
}

- (NSMutableArray*) getApplicationActivities:(id)args
{
    return nil;
}

- (NSMutableArray*) getExcludedActivityTypes:(id)args
{
    return nil;
}

- (KrollCallback*) getSuccessCallbacks:(id)args
{
    return nil;
}

- (KrollCallback*) getCanncelCallback:(id)args
{
    return nil;
}

- (KrollCallback*) getErrorCallback:(id)args
{
    return nil;
}

- (UIActivityViewController*)getActivityViewController:(id)args {
    
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:[self getActivityItems:args] applicationActivities:[self getApplicationActivities:args]];
    [avc setExcludedActivityTypes:[self getExcludedActivityTypes:args]];
    
    KrollCallback* successCallback = [self getSuccessCallbacks:args];
    KrollCallback* cancelCallback = [self getCanncelCallback:args];
    KrollCallback* errorCallback = [self getErrorCallback:args];
    
    
    NSLog(@"Try to set complete Handler");
    
    if ([TiUtils isIOS8OrGreater]) {
        [avc setCompletionWithItemsHandler:^(NSString *act, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            NSLog(@"on Complete activityType %@", act);
            NSLog(@"on Complete completed %d", completed);
            NSLog(@"on Complete returnedItems %@", returnedItems);
            NSLog(@"on Complete activityError %@", activityError);
            
            if (!completed) {
                NSDictionary *event = @{ @"success": @NO, @"platform": @"activityView"};
                [self _fireEventToListener:@"error" withObject:event listener:cancelCallback thisObject:nil];
            } else {
                NSInteger activity;
                activity = 100;
                NSDictionary *event = @{
                                        @"success": @YES,
                                        @"platform": @"activityView",
                                        @"activity": NUMLONG(activity),
                                        @"activityName": act
                                        };
                [self _fireEventToListener:@"error" withObject:event listener:successCallback thisObject:nil];
            }
            
        }];
    } else {
        
        // Completion Block Handler
        [avc setCompletionHandler:^(NSString *act, BOOL completed) {
            
            NSLog(@"on Complete %@, %d", act, completed);
            
            if (!completed) {
                NSDictionary *event = @{
                                        @"success": @NO,
                                        @"platform": @"activityView",
                                        };
                
                [self fireEvent:@"cancelled" withObject:event];
            } else {
                // RKS NOTE: Here we must verify if is a CustomActivity or not
                // to returns ACTIVITY_CUSTOM constant
                NSInteger activity;
                if ([act rangeOfString:@"com.apple.UIKit.activity"].location == NSNotFound) {
                    activity = 100;
                } else {
                    activity = act;
                }
                
                NSDictionary *event = @{
                                        @"success": @YES,
                                        @"platform": @"activityView",
                                        @"activity": NUMLONG(activity),
                                        @"activityName": act
                                        };
                [self fireEvent:@"complete" withObject:event];
            }
        }];
    }

}

-(void)activityView:(id)args {
    ENSURE_UI_THREAD(activityView, args);
    [[TiApp app] showModalController:[self getActivityViewController:args] animated:YES];
}

-(void)activityPopover:(id)args
{
    if (![TiUtils isIPad]) {
        NSLog(@"[ERROR] activityPopover is an iPad Only feature");
        return;
    }
    
    ENSURE_UI_THREAD(activityPopover, args);
    
    NSDictionary *arguments = nil;
    NSArray *customActivities = nil;
    if([args count] > 1){
        customActivities = [args objectAtIndex:1];
        arguments = [args objectAtIndex:0];
    } else {
        arguments = [args objectAtIndex:0];
    }
    
    if(popoverController.popoverVisible){
        [popoverController dismissPopoverAnimated:YES];
        return;
    }
    
    // Get Properties from JavaScript
    NSString *shareText = [TiUtils stringValue:@"text" properties:arguments def:@""];
	NSURL *shareURL = [NSURL URLWithString:[TiUtils stringValue:@"url" properties:arguments def:nil]];
    NSString *shareImage = [TiUtils stringValue:@"image" properties:arguments def:nil];
    NSString *removeIcons = [TiUtils stringValue:@"removeIcons" properties:arguments def:nil];
    NSArray *passthroughViews = [arguments objectForKey:@"passthroughViews"];
    BOOL emailIsHTML = [TiUtils boolValue:@"emailIsHTML" properties:arguments def:NO];
    
    UIBarButtonItem * senderButton = [arguments objectForKey:@"view"];
    
    if (senderButton == nil) {
        NSLog(@"[ERROR] You must specify a source button - property: view");
        return;
    }

    NSMutableArray *activityItems = [[NSMutableArray alloc] init];
    
    if(shareText){
        if (emailIsHTML) {
            NappItemProvider *textItem = [[NappItemProvider alloc] initWithPlaceholderItem:@""];
            textItem.customText = shareText;
            [activityItems addObject:textItem];
        } else {
            [activityItems addObject:shareText];
        }
    }

	if(shareURL){
		[activityItems addObject:shareURL];
	}
	
	UIImage *image;
	if (shareImage) {
		image = [self findImage:shareImage];
		[activityItems addObject:image];
    }

    UIActivityViewController *avc;
    
    // Custom Activities
    if (customActivities != nil){
		NSMutableArray * activities = [[NSMutableArray alloc] init];
        for (int i = 0; i < [customActivities count]; i++) {
            NSDictionary *activityDictionary = [customActivities objectAtIndex:i];
            NSString * activityImage = [TiUtils stringValue:@"image" properties:activityDictionary def:nil];
            NSDictionary *activityStyling = [NSDictionary dictionaryWithObjectsAndKeys:
                [TiUtils stringValue:@"type" properties:activityDictionary def:@""], @"type",
                [TiUtils stringValue:@"title" properties:activityDictionary def:@""], @"title",
                [self findImage:activityImage], @"image",
				[activityDictionary objectForKey:@"callback"], @"callback",
                self, @"module",
            nil];

            NappCustomActivity *nappActivity = [[NappCustomActivity alloc] initWithSettings:activityStyling];
            [activities addObject:nappActivity];
            
        }

        avc = [[UIActivityViewController alloc] initWithActivityItems: activityItems applicationActivities:activities];
	} else {
		avc = [[UIActivityViewController alloc] initWithActivityItems: activityItems applicationActivities:nil];
	}

	NSString *subject = [TiUtils stringValue:@"subject" properties:arguments def:nil];
	if (subject) {
		[avc setValue:subject forKey:@"subject"];
	}

    // Custom Icons
    if (removeIcons != nil) {
        NSMutableArray * excludedIcons = [self activityIcons:removeIcons];
        [avc setExcludedActivityTypes:excludedIcons];
    }
    
	[avc setCompletionHandler:^(NSString *act, BOOL done) {
		if (!done) {
			NSDictionary *event = @{
				@"success": @NO,
				@"platform": @"activityPopover",
			};
			[self fireEvent:@"cancelled" withObject:event];
		} else {
			// Here we must verify if is a CustomActivity or not
			// to returns ACTIVITY_CUSTOM constant
			NSInteger activity;
			if ([act rangeOfString:@"com.apple.UIKit.activity"].location == NSNotFound) {
				activity = 100;
			} else {
				activity = act;
			}
			
			NSDictionary *event = @{
				@"success": @YES,
				@"platform": @"activityPopover",
				@"activity": NUMLONG(activity),
				@"activityName": act
			};
			[self fireEvent:@"complete" withObject:event];
		}
	}];
    
    // popOver
    popoverController = [[UIPopoverController alloc] initWithContentViewController:avc];

	if (passthroughViews != nil) {
        [self setPassthroughViews:passthroughViews];
    }

    [popoverController presentPopoverFromBarButtonItem:senderButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)setPassthroughViews:(id)args
{
    NSMutableArray* views = [NSMutableArray arrayWithCapacity:[args count]];
    for (TiViewProxy* proxy in args) {
        if (![proxy isKindOfClass:[TiViewProxy class]]) {
            [self throwException:[NSString stringWithFormat:@"Passed non-view object %@ as passthrough view",proxy] subreason:nil location:CODELOCATION];
        }
        [views addObject:[proxy view]];
    }
    [popoverController setPassthroughViews:views];
}

-(NSMutableArray *)activityIcons:(NSString *)removeIcons
{
    NSMutableDictionary *iconMapping = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
        UIActivityTypePostToTwitter, @"twitter",
        UIActivityTypePostToFacebook, @"facebook",
        UIActivityTypeMail, @"mail",
        UIActivityTypeMessage, @"sms",
        UIActivityTypeCopyToPasteboard, @"copy",
        UIActivityTypeAssignToContact, @"contact",
        UIActivityTypePostToWeibo, @"weibo",
        UIActivityTypePrint, @"print",
        UIActivityTypeSaveToCameraRoll, @"camera",
        nil
    ];
    
    if (&UIActivityTypeAddToReadingList) {
        [iconMapping setValue:UIActivityTypeAddToReadingList forKey:@"readinglist"];
    }
    
    if (&UIActivityTypePostToFlickr) {
        [iconMapping setValue:UIActivityTypePostToFlickr forKey:@"flickr"];
    }
    
    if (&UIActivityTypePostToVimeo) {
        [iconMapping setValue:UIActivityTypePostToVimeo forKey:@"vimeo"];
    }
    
    if (&UIActivityTypeAirDrop) {
        [iconMapping setValue:UIActivityTypeAirDrop forKey:@"airdrop"];
    }
    
    if (&UIActivityTypePostToTencentWeibo) {
        [iconMapping setValue:UIActivityTypePostToTencentWeibo forKey:@"tencentweibo"];
    }

    NSArray *icons = [removeIcons componentsSeparatedByString:@","];
    NSMutableArray *excludedIcons = [[NSMutableArray alloc] init];

	for (int i = 0; i < [icons count]; i++ ) {
        NSString *str = [icons objectAtIndex:i];
        [excludedIcons addObject:[iconMapping objectForKey:str]];
    }

    return excludedIcons;
}
@end

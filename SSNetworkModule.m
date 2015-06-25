//
//  SSNetworkModule.m
//  social
//
//  Created by mingchen on 6/25/15.
//
//

#import "SSNetworkModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

@implementation SSNetworkModule

+ (NSNumber*)isNetworkSupported:(NSString *)service {
    BOOL available = NO;
    if(NSClassFromString(@"SLComposeViewController")){
        if([SLComposeViewController isAvailableForServiceType:service]) {
            available=YES;
        }
    }
    return NUMBOOL(available); //This can call this to let them know if this feature is supported
}

+ (void)shareToNetwork:(NSString*)service args:(NSDictionary*)args {
    
    NSString *platform = nil;
    
    if (service == SLServiceTypeFacebook) {
        platform = @"facebook";
    }
    if (service == SLServiceTypeTwitter) {
        platform = @"twitter";
    }
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:service];
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled) {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"success",platform, @"platform",nil];
            [self fireEvent:@"cancelled" withObject:event];
        } else {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(YES),@"success",platform, @"platform",nil];
            [self fireEvent:@"complete" withObject:event];
        }
        [controller dismissViewControllerAnimated:YES completion:Nil];
    };
    controller.completionHandler = myBlock;
    
    //get the properties from javascript
    NSString * shareText = [TiUtils stringValue:@"text" properties:args def:nil];
    NSString * shareUrl = [TiUtils stringValue:@"url" properties:args def:nil];
    
    //added M Hudson 22/10/14 to allow for blob support
    //see if we passed in a string reference to the file or a TiBlob object
    
    id TiImageObject = [args objectForKey:@"image"];
    
    if([TiImageObject isKindOfClass:[TiBlob class]]){
        NSLog(@"[INFO] Found an image", nil);
        UIImage* blobImage = [(TiBlob*)TiImageObject image];
        if (blobImage != nil) {
            NSLog(@"[INFO] blob is not null", nil);
            [controller addImage: blobImage];
        }
    } else {
        NSLog(@"[INFO] Think it is a string", nil);
        NSString * shareImage = [TiUtils stringValue:@"image" properties:args def:nil];
        if (shareImage != nil) {
            [controller addImage: [self findImage:shareImage]];
        }
    }
    
    BOOL animated = [TiUtils boolValue:@"animated" properties:args def:YES];
    
    if (shareText != nil) {
        [controller setInitialText:shareText];
    }
    
    if (shareUrl != nil) {
        [controller addURL:[NSURL URLWithString:shareUrl]];
    }
    
    [[TiApp app] showModalController:controller animated:animated];
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:platform, @"platform",nil];
    [self fireEvent:@"dialogOpen" withObject:nil];
}

@end

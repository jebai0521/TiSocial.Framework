//
//  UIActivityShareTextItemProvider.m
//  Share
//
//  Created by mingchen on 6/9/15.
//  Copyright (c) 2015 森云软件. All rights reserved.
//

#import "UIActivityMultiChannelTextItemProvider.h"

@interface UIActivityMultiChannelTextItemProvider ()

@property (strong, nonatomic) NSMutableDictionary* shareTextDictionary;

@end

@implementation UIActivityMultiChannelTextItemProvider

- (instancetype) init{
    self = [super init];
    if (self) {
        _shareTextDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) setText:(NSString*)text forType:(NSString*)type {
    [_shareTextDictionary setObject:text forKey:text];
}

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType {
    NSString* shareText;
    @try {
        
        NSLog(@"try to present shareText for %@", activityType);
        
        if ( [activityType isEqualToString:UIActivityTypePostToTwitter] )
        {
            shareText = [_shareTextDictionary objectForKey:@"twitter"];
        }
        else if ( [activityType isEqualToString:UIActivityTypePostToFacebook] )
        {
            shareText = [_shareTextDictionary objectForKey:@"facebook"];
        }
        else
        {
            shareText = [_shareTextDictionary objectForKey:@"common"];
        }
        
        NSLog(@"share Text ===> %@", shareText);
    }
    @catch (NSException *exception) {
        NSLog(@"exception ==> %@", exception);
        
        if ([[_shareTextDictionary allKeys] containsObject:@"common"]) {
            shareText = [_shareTextDictionary objectForKey:@"common"];
        } else {
            shareText = @"share text is invalid!";
        }
    }
    @finally {
        return shareText;
    }
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

@end

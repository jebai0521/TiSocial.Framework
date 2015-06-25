//
//  UIActivityILocationtemProvider.m
//  social
//
//  Created by mingchen on 6/4/15.
//
//

#import "UIActivityLocationtemProvider.h"

@implementation UIActivityLocationtemProvider

- (id) initWithVCardURL:(NSURL*)vcardURL normalURL:(NSURL*)normalURL
{
    self = [super init];
    
    if (self) {

        _vcardURL = vcardURL;
        _normalURL = normalURL;
    }
    
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if ([activityType isEqualToString:UIActivityTypeMail] || [activityType isEqualToString:UIActivityTypeMessage]) {
        return _vcardURL;
    } else {
        return _normalURL;
    }
    
    return @"";
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}
@end

//
//  UIActivityILocationtemProvider.h
//  social
//
//  Created by mingchen on 6/4/15.
//
//

#import <UIKit/UIKit.h>

@interface UIActivityLocationtemProvider : UIActivityItemProvider

- (id) initWithVCardURL:(NSURL*)vcardURL normalURL:(NSURL*)normalURL;

@property (nonatomic, strong) NSURL *vcardURL;

@property (nonatomic, strong) NSURL *normalURL;

@end

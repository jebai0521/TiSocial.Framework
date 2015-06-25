//
//  UIActivityShareTextItemProvider.h
//  Share
//
//  Created by mingchen on 6/9/15.
//  Copyright (c) 2015 森云软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityMultiChannelTextItemProvider : UIActivityItemProvider

- (void) setText:(NSString*)text forType:(NSString*)type;

@end

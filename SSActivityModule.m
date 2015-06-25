//
//  SSActivityModule.m
//  social
//
//  Created by mingchen on 6/25/15.
//
//

#import "SSActivityModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation SSActivityModule


+ (NSNumber*) isActivitySupported {
    BOOL available = NO;
    if(NSClassFromString(@"UIActivityViewController")){
        available=YES;
    }
    return NUMBOOL(available); //This can call this to let them know if this feature is supported
}

@end

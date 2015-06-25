//
//  SSUtil.m
//  social
//
//  Created by mingchen on 6/25/15.
//
//


#import <UIKit/UIKit.h>
#import "SSUtil.h"

@implementation SSUtil

+ (UIImage *)findImage:(NSString *)imagePath
{
    if(imagePath != nil){
        UIImage *image = nil;
        
        // Load the image from the application assets
        NSString *fileNamePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imagePath];;
        image = [UIImage imageWithContentsOfFile:fileNamePath];
        if (image != nil) {
            return image;
        }
        
        //Load local image by extracting the filename without extension
        NSString* newImagePath = [[imagePath lastPathComponent] stringByDeletingPathExtension];
        image = [UIImage imageNamed:newImagePath];
        if(image != nil){
            return image;
        }
        
        //image from URL
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]];
        if(image != nil){
            return image;
        }
        
        //load remote image
        image = [UIImage imageWithContentsOfFile:imagePath];
        if(image != nil){
            return image;
        }
        NSLog(@"image NOT found %@", imagePath);
    }
    return nil;
}

@end

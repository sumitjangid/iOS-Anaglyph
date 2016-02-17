//
//  BlendMode.m
//  Anaglyph
//
//  Created by Sumit Jangid on 11/14/15.
//  Copyright © 2015 Sumit Jangid. All rights reserved.
//

#import "BlendMode.h"

@implementation BlendMode

+ (UIImage *)blendImage:(UIImage *)baseImage blendImage:(UIImage *)blendImage blendMode:(CGBlendMode)blendMode blendAlpha:(CGFloat)blendAlpha rect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    
    [baseImage drawInRect:rect];
    [blendImage drawInRect:rect blendMode:blendMode alpha:blendAlpha];
    
    UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compositeImage;
}

@end

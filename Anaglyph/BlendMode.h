//
//  BlendMode.h
//  Anaglyph
//
//  Created by Sumit Jangid on 11/14/15.
//  Copyright © 2015 Sumit Jangid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlendMode : UIImage

+ (UIImage *)blendImage:(UIImage *)baseImage blendImage:(UIImage *)blendImage blendMode:(CGBlendMode)blendMode blendAlpha:(CGFloat)blendAlpha rect:(CGRect)rect;

@end

//
//  SingletonCIContext.h
//  Anaglyph
//
//  Created by Sumit Jangid on 11/14/15.
//  Copyright © 2015 Sumit Jangid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface SingletonCIContext : NSObject

+(CIContext*)context;

@end

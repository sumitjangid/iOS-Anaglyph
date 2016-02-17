//
//  SingletonCIContext.m
//  Anaglyph
//
//  Created by Sumit Jangid on 11/14/15.
//  Copyright © 2015 Sumit Jangid. All rights reserved.
//

#import "SingletonCIContext.h"

@interface SingletonCIContext ()

@property CIContext *context;

@end

@implementation SingletonCIContext

static SingletonCIContext *contextObject = nil;

+(CIContext*) context;
{
    if (contextObject != nil) {
        
        return contextObject.context;
    }
    else{
        contextObject = [[SingletonCIContext alloc]init];
        return contextObject.context;
    }
}

-(id)init {
    if(self = [super init])
    {
        self.context = [CIContext contextWithOptions:nil];
    }
    
    return self;
}@end

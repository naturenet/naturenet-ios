//
//  Wrappy.m
//  naturenet
//
//  Created by Jinyue Xia on 2/9/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wrappy.h"

@implementation Wrappy

+ (CLUploader*)create:(CLCloudinary *)cl delegate:(id <CLUploaderDelegate> )delegate
{
    return [[CLUploader alloc] init:cl delegate:delegate];
}

@end
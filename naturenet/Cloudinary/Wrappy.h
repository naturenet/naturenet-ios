//
//  Wrappy.h
//  naturenet
//
//  Created by Jinyue Xia on 2/9/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

#ifndef naturenet_Wrappy_h
#define naturenet_Wrappy_h

#import "Cloudinary.h"

@interface Wrappy : NSObject
+ (CLUploader*)create:(CLCloudinary *)cl delegate:(id <CLUploaderDelegate> )delegate;
@end
#endif

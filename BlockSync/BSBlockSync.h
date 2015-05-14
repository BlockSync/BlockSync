//
//  Async.h
//  Async
//
//  Created by Ryan Copley on 5/6/15.
//  Copyright (c) 2015 Ryan Copley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSIterator.h"

@interface BSBlockSync : NSObject

+(void)waterfall:(NSArray*)calls
           error:(void (^)())error
         success:(void (^)())success;

+(void)forEach:(NSArray*)array
          call:(void (^)(id obj, void (^cb)()))eachCall
         error:(void (^)(id error, id failedObject))error
          done:(void (^)())done;

+(void)forEach:(NSArray*)array
concurrentLimit: (NSUInteger)concurrentLimit
          call:(void (^)(id obj, void (^cb)()))eachCall
         error:(void (^)(id error, id failedObject))error
          done:(void (^)())done;

+(BSIterator*)forEachCall: (void (^)(id obj, void (^cb)()))eachCall
          concurrentLimit:(NSUInteger)concurrentLimit;

+(void)race:(NSArray*)tasks
    trophies:(NSUInteger)trophies
    results:(NSArray*)results;

@end

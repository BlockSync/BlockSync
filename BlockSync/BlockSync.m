//
//  Async.m
//  Async
//
//  Created by Ryan Copley on 5/6/15.
//  Copyright (c) 2015 Ryan Copley. All rights reserved.
//

#import "BlockSync.h"

@implementation BlockSync

+(void)waterfall:(NSArray*)calls error:(void (^)())error success:(void (^)())success{
    void (^callback)(void (^insideCB)()) = [calls firstObject];
    __block int something = 0;
    __block int nothing = 0;
    if (!callback){
        if (success){
            return success();
        }else{
            return;
        }
    }
    
    NSMutableArray* mutableCalls = [calls mutableCopy];
    [mutableCalls removeObject:callback];
    calls = [NSArray arrayWithArray:mutableCalls];
    mutableCalls = nil;
    callback(^(id err){
        if (!err){
                nothing = 0;
            [BlockSync waterfall:calls error: error success:success];
        }else{
            if (error){
                something = 1;
                error(err);
            }
        }
    });
    
    if (something && nothing){
        NSLog(@"Lulz");
    }
}


+(void)forEach:(NSArray*)array call:(void (^)(id obj, void (^cb)()))eachCall error:(void (^)(id error, id failedObject))error done:(void (^)())done {
    
    __block NSUInteger i = 0;
    __block NSUInteger max = array.count;
    void (^doneCounter)() = ^void() {
        i++;
        if (i >= max){
            done();
        }
    };
    
    for (id obj in array) {
        eachCall(obj, ^(id err){
                doneCounter();
            if (err && error){
                error(err, obj);
            }
        });
    }
}

@end

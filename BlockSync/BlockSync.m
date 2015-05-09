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
            [BlockSync waterfall:calls error: error success:success];
        }else{
            if (error){
                error(err);
            }
        }
    });
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

+(void)forEach:(NSArray*)array concurrentLimit: (int)concurrentLimit call:(void (^)(id obj, void (^cb)()))eachCall error:(void (^)(id error, id failedObject))error done:(void (^)())done {
    __block int i = 0;
    __block BOOL hasFinished = NO;
    __weak __block void (^weaklyStartTask)() = nil;
     __block void (^startTask)() = ^void(){
        __block void (^stronglyStartTask)() = weaklyStartTask;
        id obj = nil;
        if (i >= 0 && i < array.count){
            obj = [array objectAtIndex:i];
        }
        i++;
        if (!obj){
            if (!hasFinished){
                hasFinished = YES;
                return done();
            }
        }else{
            eachCall(obj, ^(id err){
                stronglyStartTask();
                if (err){
                    if (error){
                        error(err, obj);
                    }
                }
            });
        }
    };
    //We need to weakly reference the block, then re-capture it strongly inside the block.
    weaklyStartTask = startTask;
    
    //Spin up task runners
    for (int j=0;j<concurrentLimit;j++){
        startTask();
    }
}


@end

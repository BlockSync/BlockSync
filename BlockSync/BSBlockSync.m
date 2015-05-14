//
//  Async.m
//  Async
//
//  Created by Ryan Copley on 5/6/15.
//  Copyright (c) 2015 Ryan Copley. All rights reserved.
//

#import "BSBlockSync.h"
#include <pthread.h>

@implementation BSBlockSync

+(void)waterfall:(NSArray*)calls error:(void (^)())error success:(void (^)())success{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    /**
     *  For doing the task we want, we need to use a deprecated function.
     *  Apple deprecated this because the thread you're currently on "may" be
     *  a low priority queue, but this is the exact behavior we want.
     *  BlockSync is designed to *not* interfer with threads, and to return
     *  and run its block on the queue it was made on. The callbacks themselves
     *  can dispatch to a different queue if need be.
     */
    dispatch_queue_t startedOnThread = dispatch_get_current_queue();
#pragma clang diagnostic pop
    
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
        dispatch_async(startedOnThread, ^{
            if (!err){
                [BSBlockSync waterfall:calls error: error success:success];
            }else{
                if (error){
                    error(err);
                }
            }
        });
    });
}

+(void)forEach:(NSArray*)array call:(void (^)(id obj, void (^cb)()))eachCall error:(void (^)(id error, id failedObject))error done:(void (^)())done {
    if (!array){
        @throw [NSException exceptionWithName:@"BSEMPTYTASK" reason:@"Your tasks were nil." userInfo:nil];
    }
    if ([array isKindOfClass:[NSArray class]] == FALSE){
        @throw [NSException exceptionWithName:@"BSTASKSMUSTBEARRAY" reason:@"Tasks must be an array." userInfo:nil];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //See comments in waterfall:
    dispatch_queue_t startedOnThread = dispatch_get_current_queue();
#pragma clang diagnostic pop

    __block NSUInteger i = 0;
    __block NSUInteger max = array.count;
    void (^doneCounter)() = ^void() {
        dispatch_async(startedOnThread, ^{
            i++;
            if (i == max){
                done();
            }
        });
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

+(void)forEach:(NSArray*)array concurrentLimit: (NSUInteger)concurrentLimit call:(void (^)(id obj, void (^cb)()))eachCall error:(void (^)(id error, id failedObject))error done:(void (^)())done {
    if (concurrentLimit == 0){
        @throw [NSException exceptionWithName:@"BSCONCURRENTLIMITZERO" reason:@"Concurrency limit must be higher than 0." userInfo:nil];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    //See comments in forEach:call:error:done:
    dispatch_queue_t startedOnThread = dispatch_get_current_queue();
#pragma clang diagnostic pop
    
    __block NSUInteger i = 0;
    __block NSUInteger callbackCount = 0;
    __block NSUInteger expectedCallbackCount = [array count];
    __block BOOL hasFinished = NO;
    
    __weak __block void (^weaklyStartTask)() = nil;
     __block void (^startTask)() = ^void(){
        __block void (^stronglyStartTask)() = weaklyStartTask;
        id obj = nil;
        if (i < array.count){
            obj = [array objectAtIndex:i];
        }
        i++;
        if (!obj){
            if (!hasFinished && callbackCount == expectedCallbackCount){
                hasFinished = YES;
                return done();
            }
        }else{
            eachCall(obj, ^(id err){
                callbackCount++;
                if (err){
                    if (error){
                        error(err, obj);
                    }
                }
                dispatch_async(startedOnThread, ^{
                    stronglyStartTask();
                });
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

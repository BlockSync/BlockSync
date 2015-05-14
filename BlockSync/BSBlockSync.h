//
//  Async.h
//  Async
//
//  Created by Ryan Copley on 5/6/15.
//  Copyright (c) 2015 Ryan Copley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSForEachIterator.h"

@interface BSBlockSync : NSObject

/**
 *  Waterfalling is if you have a set of tasks that have to happen one after each other.
 *  Say you need to download data from a then depending on data from that request
 *  you need to download data, this is what "flattens" your block pyramid.
 *
 *  @param calls   An array of callbacks, the only parameter to the CB is an NSError object.
 *                 If you pass `nil`, the task is considered a success and the next task executes.
 *                 If you pass anything NON-nil, the error block is thrown and execution of the waterfall
 *                 halts.
 *                 Callbacks are guaranteed to be called on the thread that this function was called on.
 *                 It is encouraged to dispatch_async off the main thread, if you start it on the main thread.
 *  @param error   A callback that calls with the error that occured.
 *  @param success If all tasks complete successfully, this callback is called (without parameters)
 */
+(void)waterfall:(NSArray*)calls
           error:(void (^)())error
         success:(void (^)())success;

/**
 *  <#Description#>
 *
 *  @param array    <#array description#>
 *  @param eachCall <#eachCall description#>
 *  @param error    <#error description#>
 *  @param done     <#done description#>
 */
+(void)forEach:(NSArray*)array
          call:(void (^)(id obj, void (^cb)()))eachCall
         error:(void (^)(id error, id failedObject))error
          done:(void (^)())done;

/**
 *  <#Description#>
 *
 *  @param array           <#array description#>
 *  @param concurrentLimit <#concurrentLimit description#>
 *  @param eachCall        <#eachCall description#>
 *  @param error           <#error description#>
 *  @param done            <#done description#>
 */
+(void)forEach:(NSArray*)array
concurrentLimit: (NSUInteger)concurrentLimit
          call:(void (^)(id obj, void (^cb)()))eachCall
         error:(void (^)(id error, id failedObject))error
          done:(void (^)())done;

//Incomplete functionality
/**
 *  If you need to run tasks with a concurrency limit, but you do not know how many
 *  tasks, or even *what* the tasks are at the exact time, you would use this.
 *  you can add tasks at a later point, and the tasks will be called a maximum of
 *  `concurrentLimit` at a time. It is advised that you dispatch_async off of the callback
 *  or else you will lose a lot of functionality.
 *
 *  @param eachCall        <#eachCall description#>
 *  @param concurrentLimit <#concurrentLimit description#>
 *
 *  @return <#return value description#>
 */
+(BSForEachIterator*)forEachCall: (void (^)(id obj, void (^cb)()))eachCall
          concurrentLimit:(NSUInteger)concurrentLimit;

/**
 *  Given a set of tasks, run them all as quickly as possible.
 *  Award the first `trophies` tasks to complete with a trophy and return the results of those trophied tasks.
 *  The rest of the tasks are ignored.
 *
 *  @param tasks    <#tasks description#>
 *  @param trophies <#trophies description#>
 *  @param results  <#results description#>
 */
+(void)race:(NSArray*)tasks
    trophies:(NSUInteger)trophies
    results:(NSArray*)results;

@end

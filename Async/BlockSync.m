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

+(void)runtest {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [BlockSync forEach:@[@"1a", @"2b", @"3c", @"4d"] call:^(NSString* thing, void (^insideCB)()){
            NSLog(@"%@", thing);
            insideCB(nil);
        }
        error:^(NSError* err, NSString* failedObject){
            NSLog(@"Error %@ %@", err, failedObject);
        }
        done:^(){
            NSLog(@"Success in forEach");
        }];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [BlockSync waterfall:@[
            ^(void (^insideCB)(id failure)){
                NSLog(@"1");
                insideCB(nil);
            },
            ^(void (^insideCB)(id failure)){
                NSLog(@"2");
                insideCB(nil);
            },
            ^(void (^insideCB)(id failure)){
                NSLog(@"3");
                insideCB(nil);
            },
            ^(void (^insideCB)(id failure)){
                NSLog(@"4");
                insideCB(nil);
            }
        ]
        error:^(NSError* err){
           NSLog(@"Error");
        }
        success:^(){
            NSLog(@"Success in waterfall");
        }];
    });
}

@end

//
//  Async.m
//  Async
//
//  Created by Ryan Copley on 5/6/15.
//  Copyright (c) 2015 Ryan Copley. All rights reserved.
//

#import "Async.h"

@implementation Async

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
            [Async waterfall:calls error: error success:success];
        }else{
            if (error){
                error(err);
            }
        }
    });
}


+(void)forEach:(NSArray*)array call:(void (^)(id obj, void (^cb)()))eachCall error:(void (^)(id error, id failedObject))error success:(void (^)())success {
    
    __block NSUInteger i = 0;
    __block NSUInteger max = array.count;
    void (^done)() = ^void() {
        i++;
        if (i >= max){
            success();
        }
    };
    
    for (id obj in array) {
        eachCall(obj, ^(id err){
            if (!err){
                done();
            }else{
                if (error){
                    error(err, obj);
                }
            }
        });
    }
}

+(void)runtest {
    
    [Async forEach:@[@"1", @"2", @"3", @"4"] call:^(NSString* thing, void (^insideCB)()){
        NSLog(@"%@", thing);
        insideCB(nil);
    }
    error:^(NSError* err, NSString* failedObject){
        NSLog(@"Error %@ %@", err, failedObject);
    }
    success:^(){
        NSLog(@"Success");
    }];
    
//    
//    [Async waterfall:@[
//        ^(void (^insideCB)(id failure)){
//            NSLog(@"1");
//            insideCB(nil);
//        },
//        ^(void (^insideCB)(id failure)){
//            NSLog(@"2");
//            insideCB(nil);
//        },
//        ^(void (^insideCB)(id failure)){
//            NSLog(@"3");
//            insideCB(nil);
//        },
//        ^(void (^insideCB)(id failure)){
//            NSLog(@"4");
//            insideCB(nil);
//        }
//    ]
//    error:^(NSError* err){
//       NSLog(@"Error");
//    }
//    success:^(){
//        NSLog(@"Success");
//    }];
}

@end

//
//  AsyncTests.m
//  AsyncTests
//
//  Created by Ryan Copley on 5/6/15.
//  Copyright (c) 2015 Ryan Copley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BSBlockSync.h"

@interface AsyncForEachTests : XCTestCase

@end

@implementation AsyncForEachTests

/**
 *  Standard forEach tests
 */
- (void)testForEachSuccess {
    NSArray* tests = @[@"1a", @"2b", @"3c", @"4d"];
    NSMutableArray* results = [NSMutableArray new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];
    
    [BSBlockSync forEach:tests
                    call:^(NSString* thing, void (^cb)()){
                        [results addObject:thing];
                        cb(nil);
                    }
                   error:^(NSError* err, NSString* failedObject){
                       XCTAssert(NO, @"An error should not occur.");
                   }
                    done:^(){
                        [expectation fulfill];
                    }];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    
    XCTAssert([tests isEqualToArray:results], @"The results should be the same as the input");
}

- (void)testForEachWithNilTasks {
    XCTAssertThrowsSpecific([BSBlockSync forEach:nil
                                            call:^(NSString* thing, void (^cb)()){
                                                XCTAssert(NO, @"The call block should not occur.");
                                            }
                                           error:^(NSError* err, NSString* failedObject){
                                               XCTAssert(NO, @"An error should not occur.");
                                           }
                                            done:^(){
                                                XCTAssert(NO, @"The done block should not occur.");
                                            }]
                            , NSException, @"Should throw an error exception");;
}

- (void)testForEachWithNonArrayTasks {
    
    //Much troll
    XCTAssertThrowsSpecific([BSBlockSync forEach:(NSArray*)@{}
                                            call:^(NSString* thing, void (^cb)()){
                                                XCTAssert(NO, @"The call block should not occur.");
                                            }
                                           error:^(NSError* err, NSString* failedObject){
                                               XCTAssert(NO, @"An error should not occur.");
                                           }
                                            done:^(){
                                                XCTAssert(NO, @"The done block should not occur.");
                                            }]
                            , NSException, @"Should throw an error exception");;
}

- (void)testForEachSomeFailures {
    NSArray* tests = @[@"1a", @"2b", @"3c", @"4d"];
    
    NSArray* expectedFailures = @[@"1a", @"3c"];
    __block NSMutableArray* results = [NSMutableArray new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];
    
    __block int failures = 0;
    __block BOOL shouldFail = NO;
    [BSBlockSync forEach:tests
                    call:^(NSString* thing, void (^cb)()){
                        shouldFail = !shouldFail;
            if (shouldFail){
                cb([NSError new]);
            }else{
                cb(nil);
            }
        }
        error:^(NSError* err, NSString* failedObject){
            [results addObject:failedObject];
            failures ++;
        }
        done:^(){
            [expectation fulfill];
        }];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    XCTAssertEqual(failures, 2, @"We should have failed twice.");
    XCTAssert([expectedFailures isEqualToArray:results], @"The failed block should return the failed object.");

}

/**
 *  Concurrency tests
 */

- (void)testForEachWithConcurrentLimitSuccess {
    NSArray* tests = @[@"1a", @"2b", @"3c", @"4d"];
    NSMutableArray* results = [NSMutableArray new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];
    
    [BSBlockSync forEach:tests concurrentLimit:2 call:^(NSString* obj, void (^cb)()) {
        [results addObject:obj];
        cb(nil);
    } error:^(id error, id failedObject) {
        XCTAssert(NO, @"An error should not occur.");
    } done:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    
    XCTAssert([tests isEqualToArray:results], @"The results should be the same as the input");
}

- (void)testForEachWithConcurrentLimitWithHigherConcurrentLimitThanTasks {
    NSArray* tests = @[@"1a", @"2b", @"3c", @"4d"];
    NSMutableArray* results = [NSMutableArray new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];
    
    [BSBlockSync forEach:tests concurrentLimit:5 call:^(NSString* obj, void (^cb)()) {
        [results addObject:obj];
        cb(nil);
    } error:^(id error, id failedObject) {
        XCTAssert(NO, @"An error should not occur.");
    } done:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    
    XCTAssert([tests isEqualToArray:results], @"The results should be the same as the input");
}

- (void)testForEachWithConcurrentLimitZeroConcurrentLimitThanTasks {
    NSArray* tests = @[@"1a", @"2b", @"3c", @"4d"];
    XCTAssertThrowsSpecific([BSBlockSync forEach:tests concurrentLimit:0 call:^(NSString* obj, void (^cb)()) {
        XCTAssert(NO, @"The iterator should not run");
    } error:^(id error, id failedObject) {
        XCTAssert(NO, @"An error should not occur.");
    } done:^{
        XCTAssert(NO, @"The done block should not run");
    }], NSException, @"Should throw a concurrency error exception");
}

- (void)testForEachWithConcurrentLimitFailure {
    NSArray* tests = @[@"1a", @"2b", @"3c", @"4d"];
    NSMutableArray* results = [NSMutableArray new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];
    NSArray* expectedFailures = @[@"1a", @"3c"];

    __block int failures = 0;
    __block BOOL shouldFail = NO;
    [BSBlockSync forEach:tests concurrentLimit:2 call:^(NSString* obj, void (^cb)()) {
        shouldFail = !shouldFail;
        if (shouldFail){
            cb([NSError new]);
        }else{
            cb(nil);
        }
    } error:^(id error, id failedObject) {
        [results addObject:failedObject];
        failures ++;
    } done:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    
    XCTAssertEqual(failures, 2, @"We should have failed twice.");
    XCTAssert([expectedFailures isEqualToArray:results], @"The failed block should return the failed object.");
}

/**
 *  Tests the concurrent block in a way that if the concurrent limit is different (or wrong)
 *  the result would fail. This test can not have break points added to it, as that affects
 *  time. This should not fail unless you're on a really messed up system.
 */
- (void)testForEachWithConcurrentLimitSuccessTrueOrder {
    NSArray* tests = @[@(7),@(1), @(1), @(2), @(1), @(3)];
    NSArray* expectedResults = @[@(1), @(1), @(2), @(1), @(7), @(3)];
    NSMutableArray* results = [NSMutableArray new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];
    
    [BSBlockSync forEach:tests concurrentLimit:2 call:^(NSNumber* obj, void (^cb)()) {
        NSAssert([NSThread isMainThread] , @"ForEach should always be called on the thread with which it was started on.");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([obj intValue] * NSEC_PER_SEC)),
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul),
                       ^{
                           [results addObject:obj];
                           cb(nil);
                       });
    } error:^(id error, id failedObject) {
        XCTAssert(NO, @"An error should not occur.");
    } done:^{
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    
    XCTAssert([results isEqualToArray:expectedResults], @"The results should be the same as the input");
}

/**
 *  Standard forEach tests, multi threaded
 */
- (void)testForEachSuccessThreaded {
    NSArray* tests = @[@"1a", @"2b", @"3c", @"4d"];
    NSMutableArray* results = [NSMutableArray new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];
    
    [BSBlockSync forEach:tests
                    call:^(NSString* thing, void (^cb)()){
                        NSAssert([NSThread isMainThread] , @"ForEach should always be called on the thread with which it was started on.");
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
                            [results addObject:thing];
                            cb(nil);
                        });
                    }
                   error:^(NSError* err, NSString* failedObject){
                       NSAssert([NSThread isMainThread] , @"ForEach:error should always be called on the thread with which it was started on.");
                       XCTAssert(NO, @"An error should not occur.");
                   }
                    done:^(){
                        NSAssert([NSThread isMainThread] , @"ForEach:done should always be called on the thread with which it was started on.");
                        [expectation fulfill];
                    }];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    
    XCTAssert([tests isEqualToArray:results], @"The results should be the same as the input");
}

@end

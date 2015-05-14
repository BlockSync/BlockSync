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

@end

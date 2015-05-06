//
//  AsyncTests.m
//  AsyncTests
//
//  Created by Ryan Copley on 5/6/15.
//  Copyright (c) 2015 Ryan Copley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BlockSync.h"

@interface AsyncForEachTests : XCTestCase

@end

@implementation AsyncForEachTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testForEachSuccess {
    NSArray* tests = @[@"1a", @"2b", @"3c", @"4d"];
    NSMutableArray* results = [NSMutableArray new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];
    
    [BlockSync forEach:tests
        call:^(NSString* thing, void (^insideCB)()){
            [results addObject:thing];
            insideCB(nil);
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

- (void)testForEachSomeFailures {
    NSArray* tests = @[@"1a", @"2b", @"3c", @"4d"];
    
    NSArray* expectedFailures = @[@"2b", @"4d"];
    __block NSMutableArray* results = [NSMutableArray new];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];
    
    __block int failures = 0;
    
    __block BOOL shouldFail = NO;
    [BlockSync forEach:tests
        call:^(NSString* thing, void (^insideCB)()){
            if (shouldFail){
                insideCB([NSError new]);
            }else{
                insideCB(nil);
            }
            shouldFail = !shouldFail;
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

//[BlockSync waterfall:@[
//    ^(void (^insideCB)(id failure)){
//        NSLog(@"1");
//        insideCB(nil);
//    },
//    ^(void (^insideCB)(id failure)){
//        NSLog(@"2");
//        insideCB(nil);
//    },
//    ^(void (^insideCB)(id failure)){
//        NSLog(@"3");
//        insideCB(nil);
//    },
//    ^(void (^insideCB)(id failure)){
//        NSLog(@"4");
//        insideCB(nil);
//    }
//]
//error:^(NSError* err){
//   NSLog(@"Error");
//}
//success:^(){
//    NSLog(@"Success in waterfall");
//}];
@end

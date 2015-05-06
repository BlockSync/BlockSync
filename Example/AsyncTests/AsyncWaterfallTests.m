//
//  AsyncWaterfallTests.m
//  Async
//
//  Created by Ryan Copley on 5/6/15.
//  Copyright (c) 2015 Ryan Copley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BlockSync.h"

@interface AsyncWaterfallTests : XCTestCase

@end

@implementation AsyncWaterfallTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSuccessfulWaterfall {
    __block unsigned int i = 0;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];

    [BlockSync waterfall:@[
        ^(void (^insideCB)(id failure)){
            i++;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i+=2;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i+=4;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i+=8;
            insideCB(nil);
        }
    ]
    error:^(NSError* err){
        XCTAssert(err == nil, @"Errors should not happen");
    }
    success:^(){
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    XCTAssertEqual(i, 15, @"We should have called all 4 blocks");
}


- (void)testSuccessfulWaterfallWithoutSuccess {
    __block unsigned int i = 0;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];

    [BlockSync waterfall:@[
        ^(void (^insideCB)(id failure)){
            i++;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i+=2;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i+=4;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i+=8;
            insideCB(nil);
            [expectation fulfill];
        }
    ]
    error:^(NSError* err){
        XCTAssert(err == nil, @"Errors should not happen");
    }
    success:nil];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    XCTAssertEqual(i, 15, @"We should have called all 4 blocks");
}

- (void)testSuccessfulWaterfallWithoutError {
    __block unsigned int i = 0;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];

    [BlockSync waterfall:@[
        ^(void (^insideCB)(id failure)){
            i++;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i+=2;
            insideCB([NSError new]);
            [expectation fulfill];
        },
        ^(void (^insideCB)(id failure)){
            i+=4;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i+=8;
            insideCB(nil);
            [expectation fulfill];
        }
    ]
    error:nil
    success:nil];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    XCTAssertEqual(i, 3, @"We should have called all 2 blocks, then errored");
}

- (void)testErroredWaterfall {
    __block int i = 0;
    XCTestExpectation *expectation = [self expectationWithDescription:@"Done called"];

    [BlockSync waterfall:@[
        ^(void (^insideCB)(id failure)){
            i++;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i++;
            insideCB([NSError new]);
        },
        ^(void (^insideCB)(id failure)){
            i++;
            insideCB(nil);
        },
        ^(void (^insideCB)(id failure)){
            i++;
            insideCB(nil);
            [expectation fulfill];
        }
    ]
    error:^(NSError* err){
        XCTAssert(err != nil, @"Errors should happen");
        [expectation fulfill];
    }
    success:^(){
        XCTAssert(NO, @"since we errored, we were not successful.");
    }];
    
    [self waitForExpectationsWithTimeout:1.0f handler:^(NSError* err){
        if (err){
            XCTAssert(NO, @"We should have fulfilled.");
        }
    }];
    XCTAssertEqual(i, 2, @"We should have called the first 2 blocks");
}


@end

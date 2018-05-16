//
//  Test_Enviroment.swift
//  Test-Shared
//
//  Created by BB9z on 2018/4/27.
//  Copyright © 2018 RFUI. All rights reserved.
//

import XCTest

class Test_Enviroment: XCTestCase {
    func testFlag() {
        let env = MBEnvironment()
        XCTAssertFalse(env.meetFlags(Flag.A.rawValue))
        
        env.setFlagOn(Flag.A.rawValue)
        XCTAssertTrue(env.meetFlags(Flag.A.rawValue))

        env.setFlagOff(Flag.A.rawValue)
        XCTAssertFalse(env.meetFlags(Flag.A.rawValue))
    }
    
    func testWait() {
        var callFlag = false
        let env = MBEnvironment()
        let exp = XCTestExpectation(description: "do")
        env.waitFlags((Flag.A.rawValue | Flag.B.rawValue), do: {
            callFlag = true
            exp.fulfill()
        }, timeout: 0)
        
        env.setFlagOn(Flag.A.rawValue)
        XCTAssertFalse(callFlag)
        env.setFlagOn(Flag.B.rawValue)
        
        wait(for: [exp], timeout: 1)
        XCTAssertTrue(callFlag)
    }
    
    func testWaitTimeout() {
        var callFlag = false
        let env = MBEnvironment()
        let exp = XCTestExpectation(description: "do")
        env.waitFlags((Flag.A.rawValue | Flag.B.rawValue), do: {
            callFlag = true
            exp.fulfill()
        }, timeout: 0.1)
        
        dispatch_after_seconds(0.2) {
            env.setFlagOn(Flag.A.rawValue)
            env.setFlagOn(Flag.B.rawValue)
        }
        dispatch_after_seconds(0.4) {
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        XCTAssertFalse(callFlag)
    }
    
    func testWaitMeetBefore() {
        var callFlag = false
        let env = MBEnvironment()
        env.setFlagOn(Flag.A.rawValue)
        env.setFlagOn(Flag.B.rawValue)
        env.waitFlags((Flag.A.rawValue | Flag.B.rawValue), do: {
            callFlag = true
        }, timeout: 0)
        XCTAssertTrue(callFlag)
    }
    
    func testWaitDoubld() {
        var callFlag = 0
        let exp = XCTestExpectation(description: "do")
        let env = MBEnvironment()
        env.setFlagOn(Flag.A.rawValue)
        env.waitFlags(Flag.A.rawValue, do: {
            callFlag = callFlag + 1
            env.setFlagOn(Flag.A.rawValue)
        }, timeout: 0)

        dispatch_after_seconds(0.2) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        XCTAssert(callFlag == 1)
    }
}

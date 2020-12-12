//
//  Test_Enviroment.swift
//  Test-Shared
//
//  Created by BB9z on 2018/4/27.
//  Copyright © 2018 RFUI. All rights reserved.
//

import XCTest

extension MBENVFlag {
    static let flagA = MBENVFlag(rawValue: 1 << 0)
    static let flagB = MBENVFlag(rawValue: 1 << 1)
    static let flagC = MBENVFlag(rawValue: 1 << 2)
    static let flagD = MBENVFlag(rawValue: 1 << 3)
}

class Test_Enviroment: XCTestCase {
    func testFlag() {
        let env = MBEnvironment()
        XCTAssertFalse(env.meetFlags(.flagA))
        
        env.setFlagOn(.flagA)
        XCTAssertTrue(env.meetFlags(.flagA))

        env.setFlagOff(.flagA)
        XCTAssertFalse(env.meetFlags(.flagA))
    }

    func testMultiFlag() {
        let env = MBEnvironment()
        env.setFlagOn(.flagA)
        XCTAssertFalse(env.meetFlags([.flagA, .flagB]))

        env.setFlagOn(.flagB)
        XCTAssertTrue(env.meetFlags([.flagA, .flagB]))

        env.setFlagOff(.flagA)
        XCTAssertFalse(env.meetFlags([.flagA, .flagB]))
    }
    
    func testWait() {
        var callFlag = false
        let env = MBEnvironment()
        let exp = XCTestExpectation(description: "do")
        env.waitFlags([.flagA, .flagB], do: {
            callFlag = true
            exp.fulfill()
        }, timeout: 0)
        
        env.setFlagOn(.flagA)
        XCTAssertFalse(callFlag)
        env.setFlagOn(.flagB)
        XCTAssertFalse(callFlag)

        wait(for: [exp], timeout: 1)
        XCTAssertTrue(callFlag)
    }

    func testWaitTimeoutForever() {
        var callFlag = false
        let env = MBEnvironment()
        let exp = XCTestExpectation(description: "do")
        env.waitFlags([.flagA], do: {
            callFlag = true
            exp.fulfill()
        }, timeout: 0)

        dispatch_after_seconds(0.9) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        XCTAssertFalse(callFlag)
    }
    
    func testWaitTimeout() {
        var callFlag = false
        let env = MBEnvironment()
        let exp = XCTestExpectation(description: "do")
        env.waitFlags(.flagA, do: {
            callFlag = true
        }, timeout: 0.1)

        dispatch_after_seconds(0.2) {
            XCTAssertTrue(callFlag)
            exp.fulfill()
        }
        XCTAssertFalse(callFlag)

        wait(for: [exp], timeout: 1)
    }
    
    func testWaitMeetBefore() {
        var callFlag = false
        let env = MBEnvironment()
        env.setFlagOn(.flagA)
        env.setFlagOn(.flagB)
        env.waitFlags([.flagA, .flagB], do: {
            callFlag = true
        }, timeout: 0)
        XCTAssertTrue(callFlag)
    }
    
    func testWaitDoubld() {
        var callFlag = 0
        let exp = XCTestExpectation(description: "do")
        let env = MBEnvironment()
        env.setFlagOn(.flagA)
        env.waitFlags(.flagA, do: {
            callFlag = callFlag + 1
            env.setFlagOn(.flagA)
        }, timeout: 0)

        dispatch_after_seconds(0.2) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        XCTAssert(callFlag == 1)
    }

    func testStaticRegister() {
        globalCounter = 0

        MBEnvironment.staticObserve(.flagA, selector: #selector(MBEnvironment.staticRegisterMethod), handleOnce: false)
        let env = MBEnvironment()
        MBEnvironment.setAsApplicationDefault(env)

        env.setFlagOn(.flagA)
        let exp = XCTestExpectation(description: "do")

        dispatch_after_seconds(0.2) {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(globalCounter, 1)
    }
}

var globalCounter = 0

extension MBEnvironment {
     @objc func staticRegisterMethod() {
        globalCounter += 1
    }
}

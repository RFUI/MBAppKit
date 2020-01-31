//
//  TestAPI.swift
//  Test-iOS
//
//  Created by BB9z on 2020/1/28.
//  Copyright © 2020 RFUI. All rights reserved.
//

import XCTest

class TestAPI: XCTestCase {

    override class func setUp() {
        if MBAPI.global == nil {
            MBAPI.global = MBAPI()
        }
    }

    func testDeineLoad() {
        let api = MBAPI.global!
        let defineFile = Bundle(for: type(of: self)).path(forResource: "test_defines", ofType: "plist")!
        api.setupAPIDefine(withPlistPath: defineFile)
        XCTAssert(api.defineManager.defines.count >= 3)
    }
}

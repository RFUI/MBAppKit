//
//  Test_Worker.swift
//  Test-Shared
//
//  Created by BB9z on 2018/4/24.
//  Copyright © 2018 RFUI. All rights reserved.
//

import XCTest

class Test_Worker: XCTestCase {

    // MARK: -
    func testThread() {
        let q = MBWorkerQueue()
        let workMain = MainThreadWork()
        workMain.completionBlock = { _,_,_ in
            let workBackground = BackgroundThreadWork()
            q.dispatchQueue = DispatchQueue.global(qos: .background)
            q.add(workBackground)
        }
        q.add(workMain)
    }
    
    class MainThreadWork: MBWorker {
        override func perform() {
            XCTAssertTrue(Thread.isMainThread)
            finish()
            if let cb = completionBlock {
                cb(true, nil, nil)
            }
        }
    }
    
    class BackgroundThreadWork: MBWorker {
        override func perform() {
            XCTAssertFalse(Thread.isMainThread)
            finish()
        }
    }
    
    // MARK: - User Required
    func testUserRequired() {
        
    }
}

class TestWorker: MBWorker {
    var executionDuration: TimeInterval = 0
    override func perform() {
        dispatch_after_seconds(executionDuration) {
            self.finish()
        }
    }
}


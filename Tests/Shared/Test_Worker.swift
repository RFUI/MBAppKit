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
        let timeout = XCTestExpectation(description: "work done")
        let endWorker = WaitEndWorker(expectation: timeout)
        let q = MBWorkerQueue()
        defer {
            print(q)
            wait(for: [timeout], timeout: 2)
        }
        let w1 = TestWorker()
        w1.requiresUserContext = true
        q.add(w1)
        XCTAssertNil(q.executingWorker, "No current user, the worker should be dropped.")
        XCTAssertTrue(q.currentWorkerQueue().isEmpty)
        
        MBUser.current = MBUser(id: 1)
        q.add(w1)
        XCTAssertNotNil(q.executingWorker)
        
        q.add(endWorker)
        print(q)
    }
    
    // MARK: - Parameter
    func testEdgeParameter() {
        let q = MBWorkerQueue()
        q.add(nil)
        do {
            try RTHelper.catchException {
                q.add(MBWorker.fromAny([]))
            }
        } catch {
            XCTAssertNotNil(error)
        }
        XCTAssert(q.currentWorkerQueue().isEmpty, "Queue should be empty.")
        XCTAssertNil(q.executingWorker)
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

class WaitEndWorker: MBWorker {
    var xcExpectation: XCTestExpectation
    init(expectation: XCTestExpectation) {
        xcExpectation = expectation
    }
    override func perform() {
        xcExpectation.fulfill()
        finish()
    }
}

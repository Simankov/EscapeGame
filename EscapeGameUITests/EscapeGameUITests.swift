//
//  EscapeGameUITests.swift
//  EscapeGameUITests
//
//  Created by sergey on 06.08.16.
//  Copyright © 2016 Sergey Simankov. All rights reserved.
//

import XCTest

class EscapeGameUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testStart() {
        XCUIApplication().buttons["2"].tap()
        snapshot("begin");
    }
    
    func testInFly(){
        let app = XCUIApplication()
        app.buttons["2"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.pressForDuration(7);
        NSThread.sleepForTimeInterval(0.5);
        snapshot("inAction")
    }
    
    func testPause(){
        let app = XCUIApplication()
        app.buttons["2"].tap()
        app.buttons["pause"].tap()
        NSThread.sleepForTimeInterval(0.4);
        snapshot("pause")
    }
    
}

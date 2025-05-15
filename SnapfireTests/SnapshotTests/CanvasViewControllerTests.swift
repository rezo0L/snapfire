//
//  ViewControllerTests.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import XCTest
import SnapshotTesting
import UIKit

@testable import Snapfire

class CanvasViewControllerTests: XCTestCase {

    func testGuidelineShown_whenSnapsToCenterVertically() {
        let viewController = CanvasViewController()

        // Below numbers are to replicated the issue with guideline being shown on top of the item instead of its bottom
        let testItem = UIView()
        testItem.frame = CGRect(x: 0, y: 0, width: 85.86195652173912, height: 58.949999999999996)
        testItem.backgroundColor = .red
        viewController.addTestItem(testItem)

        viewController.simulatePan(from: CGPoint(x: 0, y: 0), to: CGPoint(x: 10, y: 58.66))
        assertSnapshot(of: viewController.view, as: .image)
    }
}

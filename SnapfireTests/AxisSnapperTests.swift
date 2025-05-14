//
//  AxisSnapperTests.swift
//  SnapfireTests
//
//  Created by Reza on 2025-05-14.
//

import XCTest

@testable import Snapfire

final class AxisSnapperTests: XCTestCase {

    let snapper = AxisSnapper()
    let threshold: CGFloat = 5.0

    func testSnapsToHorizontalAnchor_minX() {
        let frame = CGRect(x: 95, y: 100, width: 20, height: 20)
        let anchor = Anchor(point: CGPoint(x: 100, y: 0), angle: .zero)

        let result = snapper.calculateSnap(for: frame, anchors: [anchor], threshold: threshold)

        XCTAssertEqual(result.origin.x, 100)
        XCTAssertEqual(result.origin.y, 100)
    }

    func testSnapsToVerticalAnchor_minY() {
        let frame = CGRect(x: 100, y: 95, width: 20, height: 20)
        let anchor = Anchor(point: CGPoint(x: 0, y: 100), angle: .pi / 2)

        let result = snapper.calculateSnap(for: frame, anchors: [anchor], threshold: threshold)

        XCTAssertEqual(result.origin.x, 100)
        XCTAssertEqual(result.origin.y, 100)
    }

    func testDoesNotSnap_whenOutsideThreshold() {
        let frame = CGRect(x: 50, y: 50, width: 20, height: 20)
        let anchor = Anchor(point: CGPoint(x: 80, y: 80), angle: .zero)

        let result = snapper.calculateSnap(for: frame, anchors: [anchor], threshold: threshold)

        XCTAssertEqual(result.origin.x, 50)
        XCTAssertEqual(result.origin.y, 50)
    }

    func testSnapsToBothHorizontalAndVertical() {
        let frame = CGRect(x: 95, y: 96, width: 20, height: 20)
        let anchors = [
            Anchor(point: CGPoint(x: 100, y: 0), angle: .zero),
            Anchor(point: CGPoint(x: 0, y: 100), angle: .pi / 2)
        ]

        let result = snapper.calculateSnap(for: frame, anchors: anchors, threshold: threshold)

        XCTAssertEqual(result.origin.x, 100)
        XCTAssertEqual(result.origin.y, 100)
    }

    func testNoAnchorsResultsInNoSnap() {
        let frame = CGRect(x: 40, y: 40, width: 10, height: 10)

        let result = snapper.calculateSnap(for: frame, anchors: [], threshold: threshold)

        XCTAssertEqual(result.origin.x, 40)
        XCTAssertEqual(result.origin.y, 40)
    }
}

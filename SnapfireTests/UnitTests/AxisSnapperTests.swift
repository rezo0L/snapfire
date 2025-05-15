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

    func testSnapsFrameMinX_ToVerticalAnchor() {
        let frame = CGRect(x: 95, y: 100, width: 20, height: 20)
        let expectedAnchor = Anchor(point: CGPoint(x: 100, y: 0), angle: .pi / 2)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 5, "Delta X should snap frame.minX (95) to anchor.point.x (100)")
        XCTAssertEqual(result.delta.y, 0, "Delta Y should be 0")
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }

    func testSnapsFrameMinY_ToHorizontalAnchor() {
        let frame = CGRect(x: 100, y: 95, width: 20, height: 20)
        let expectedAnchor = Anchor(point: CGPoint(x: 0, y: 100), angle: .zero)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 0, "Delta X should be 0")
        XCTAssertEqual(result.delta.y, 5, "Delta Y should snap frame.minY (95) to anchor.point.y (100)")
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }

    func testSnapsFrameMaxX_ToVerticalAnchor() {
        let frame = CGRect(x: 75, y: 100, width: 20, height: 20)
        let expectedAnchor = Anchor(point: CGPoint(x: 100, y: 0), angle: .pi / 2)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 5, "Delta X should snap frame.maxX (95) to anchor.point.x (100)")
        XCTAssertEqual(result.delta.y, 0)
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }

    func testSnapsFrameMaxY_ToHorizontalAnchor() {
        let frame = CGRect(x: 100, y: 75, width: 20, height: 20)
        let expectedAnchor = Anchor(point: CGPoint(x: 0, y: 100), angle: .zero)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 0)
        XCTAssertEqual(result.delta.y, 5, "Delta Y should snap frame.maxY (95) to anchor.point.y (100)")
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }

    func testSnapsFrameMidX_ToVerticalAnchor() {
        let frame = CGRect(x: 85, y: 100, width: 10, height: 20)
        let expectedAnchor = Anchor(point: CGPoint(x: 100, y: 0), angle: .pi / 2)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 5, "Delta X should snap frame.midX (95) to anchor.point.x (100)")
        XCTAssertEqual(result.delta.y, 0)
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }

    func testSnapsFrameMidY_ToHorizontalAnchor() {
        let frame = CGRect(x: 100, y: 85, width: 20, height: 10)
        let expectedAnchor = Anchor(point: CGPoint(x: 0, y: 100), angle: .zero)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 0)
        XCTAssertEqual(result.delta.y, 5, "Delta Y should snap frame.midY (95) to anchor.point.y (100)")
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }

    func testDoesNotSnap_WhenFrameIsOutsideThreshold() {
        let frame = CGRect(x: 50, y: 50, width: 20, height: 20)
        let anchor = Anchor(point: CGPoint(x: 0, y: 80), angle: .zero)

        let result = snapper.calculateSnap(for: frame, anchors: [anchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 0)
        XCTAssertEqual(result.delta.y, 0)
        XCTAssertTrue(result.snappedAnchors.isEmpty)
    }

    func testSnapsWhenDistanceIsExactlyThreshold_Vertical() {
        let frame = CGRect(x: 100, y: 95, width: 20, height: 20)
        let expectedAnchor = Anchor(point: CGPoint(x: 0, y: 100), angle: .zero)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: 5.0)

        XCTAssertEqual(result.delta.x, 0)
        XCTAssertEqual(result.delta.y, 5, "Should snap as distance (5) equals threshold (5)")
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }

    func testSnapsWhenDistanceIsExactlyThreshold_Horizontal() {
        let frame = CGRect(x: 95, y: 100, width: 20, height: 20)
        let expectedAnchor = Anchor(point: CGPoint(x: 100, y: 0), angle: .pi / 2)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: 5.0)

        XCTAssertEqual(result.delta.x, 5, "Should snap as distance (5) equals threshold (5)")
        XCTAssertEqual(result.delta.y, 0)
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }

    func testSnapsToBothVerticalAndHorizontalAnchors() {
        let frame = CGRect(x: 95, y: 96, width: 20, height: 20)
        let verticalAnchor = Anchor(point: CGPoint(x: 100, y: 0), angle: .pi / 2)
        let horizontalAnchor = Anchor(point: CGPoint(x: 0, y: 100), angle: .zero)
        let anchors = [verticalAnchor, horizontalAnchor]

        let result = snapper.calculateSnap(for: frame, anchors: anchors, threshold: threshold)

        XCTAssertEqual(result.delta.x, 5)
        XCTAssertEqual(result.delta.y, 4)
        XCTAssertEqual(result.snappedAnchors.count, 2)

        XCTAssertTrue(result.snappedAnchors.contains(verticalAnchor), "Should contain vertical anchor")
        XCTAssertTrue(result.snappedAnchors.contains(horizontalAnchor), "Should contain horizontal anchor")
        if result.snappedAnchors.count == 2 {
             XCTAssertEqual(result.snappedAnchors[0], verticalAnchor, "Vertical anchor should be first if processed first")
             XCTAssertEqual(result.snappedAnchors[1], horizontalAnchor, "Horizontal anchor should be second if processed second")
        }
    }

    func testChoosesClosest_AmongMultipleVerticalAnchors_ForFrameMidX() {
        let frame = CGRect(x: 90, y: 100, width: 20, height: 20)

        let furtherAnchor = Anchor(point: CGPoint(x: 94, y: 0), angle: .pi / 2)
        let closestAnchor = Anchor(point: CGPoint(x: 102, y: 0), angle: .pi / 2)
        let anotherAnchor = Anchor(point: CGPoint(x: 106, y: 0), angle: .pi / 2)

        let anchors = [furtherAnchor, closestAnchor, anotherAnchor]
        let result = snapper.calculateSnap(for: frame, anchors: anchors, threshold: threshold)

        XCTAssertEqual(result.delta.x, 2, "Should snap to the closest anchor with delta 2 for midX")
        XCTAssertEqual(result.delta.y, 0)
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, closestAnchor)
    }

    func testChoosesClosest_AmongMultipleHorizontalAnchors_ForFrameMidY() {
        let frame = CGRect(x: 100, y: 90, width: 20, height: 20)

        let furtherAnchor = Anchor(point: CGPoint(x: 0, y: 94), angle: .zero)
        let closestAnchor = Anchor(point: CGPoint(x: 0, y: 102), angle: .zero)
        let anotherAnchor = Anchor(point: CGPoint(x: 0, y: 106), angle: .zero)

        let anchors = [furtherAnchor, closestAnchor, anotherAnchor]
        let result = snapper.calculateSnap(for: frame, anchors: anchors, threshold: threshold)

        XCTAssertEqual(result.delta.x, 0)
        XCTAssertEqual(result.delta.y, 2, "Should snap to the closest anchor with delta 2 for midY")
        XCTAssertEqual(result.snappedAnchors.count, 1)
        XCTAssertEqual(result.snappedAnchors.first, closestAnchor)
    }

    func testNoAnchors_ResultsInNoSnap() {
        let frame = CGRect(x: 40, y: 40, width: 10, height: 10)

        let result = snapper.calculateSnap(for: frame, anchors: [], threshold: threshold)

        XCTAssertEqual(result.delta.x, 0)
        XCTAssertEqual(result.delta.y, 0)
        XCTAssertTrue(result.snappedAnchors.isEmpty)
    }

    func testNoSnap_WhenAnchorAngleIsIncorrectForHorizontalSnap() {
        let frame = CGRect(x: 95, y: 100, width: 20, height: 20)
        let wrongAngleAnchor = Anchor(point: CGPoint(x: 100, y: 0), angle: .zero)

        let result = snapper.calculateSnap(for: frame, anchors: [wrongAngleAnchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 0, "Should not snap horizontally with incorrect anchor angle")
        XCTAssertEqual(result.delta.y, 0, "Should not snap vertically if other axis also doesn't match or is out of threshold")
        XCTAssertTrue(result.snappedAnchors.isEmpty)
    }

    func testNoSnap_WhenAnchorAngleIsIncorrectForVerticalSnap() {
        let frame = CGRect(x: 100, y: 95, width: 20, height: 20)
        let wrongAngleAnchor = Anchor(point: CGPoint(x: 0, y: 100), angle: .pi / 2)

        let result = snapper.calculateSnap(for: frame, anchors: [wrongAngleAnchor], threshold: threshold)
        XCTAssertEqual(result.delta.y, 0, "Should not snap vertically with incorrect anchor angle")
        XCTAssertEqual(result.delta.x, 0)
        XCTAssertTrue(result.snappedAnchors.isEmpty)
    }

    func testSnapToAlreadyAlignedFrame_ResultsInZeroDeltaAndSnappedAnchor_Horizontal() {
        let frame = CGRect(x: 100, y: 100, width: 20, height: 20)
        let expectedAnchor = Anchor(point: CGPoint(x: 100, y: 0), angle: .pi / 2)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 0, "Delta X should be 0 as frame.minX is already aligned")
        XCTAssertEqual(result.delta.y, 0)
        XCTAssertEqual(result.snappedAnchors.count, 1, "Should still report the anchor it's aligned with")
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }

    func testSnapToAlreadyAlignedFrame_ResultsInZeroDeltaAndSnappedAnchor_Vertical() {
        let frame = CGRect(x: 100, y: 100, width: 20, height: 20)
        let expectedAnchor = Anchor(point: CGPoint(x: 0, y: 100), angle: .zero)

        let result = snapper.calculateSnap(for: frame, anchors: [expectedAnchor], threshold: threshold)

        XCTAssertEqual(result.delta.x, 0)
        XCTAssertEqual(result.delta.y, 0, "Delta Y should be 0 as frame.minY is already aligned")
        XCTAssertEqual(result.snappedAnchors.count, 1, "Should still report the anchor it's aligned with")
        XCTAssertEqual(result.snappedAnchors.first, expectedAnchor)
    }
}

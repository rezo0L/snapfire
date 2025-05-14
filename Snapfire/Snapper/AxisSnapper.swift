//
//  AxisSnapper.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import Foundation

struct AxisSnapper: Snapper {

    func calculateSnap(for proposedFrame: CGRect, anchors: [Anchor], threshold: CGFloat) -> SnapResult {
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        var snappedAnchors: [Anchor] = []

        let minHorizontalDistance = anchors.filter { $0.angle == .pi / 2 }.flatMap {[
            ($0, $0.point.x - proposedFrame.minX),
            ($0, $0.point.x - proposedFrame.maxX),
            ($0, $0.point.x - proposedFrame.midX)
        ]}.min { abs($0.1) < abs($1.1) }

        let minVerticalDistance = anchors.filter { $0.angle == .zero }.flatMap {[
            ($0, $0.point.y - proposedFrame.minY),
            ($0, $0.point.y - proposedFrame.maxY),
            ($0, $0.point.y - proposedFrame.midY)
        ]}.min { abs($0.1) < abs($1.1) }

        if let minHorizontalDistance, abs(minHorizontalDistance.1) <= threshold {
            dx = minHorizontalDistance.1
            snappedAnchors.append(minHorizontalDistance.0)
        }

        if let minVerticalDistance, abs(minVerticalDistance.1) <= threshold {
            dy = minVerticalDistance.1
            snappedAnchors.append(minVerticalDistance.0)
        }

        return .init(delta: .init(x: dx, y: dy), snappedAnchors: snappedAnchors)
    }
}

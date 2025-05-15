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
            (anchor: $0, delta: $0.point.x - proposedFrame.minX),
            ($0, $0.point.x - proposedFrame.maxX),
            ($0, $0.point.x - proposedFrame.midX)
        ]}.min { abs($0.delta) < abs($1.delta) }

        let minVerticalDistance = anchors.filter { $0.angle == .zero }.flatMap {[
            (anchor: $0, delta: $0.point.y - proposedFrame.minY),
            ($0, $0.point.y - proposedFrame.maxY),
            ($0, $0.point.y - proposedFrame.midY)
        ]}.min { abs($0.delta) < abs($1.delta) }

        if let minHorizontalDistance, abs(minHorizontalDistance.delta) <= threshold {
            dx = minHorizontalDistance.delta
            snappedAnchors.append(minHorizontalDistance.anchor)
        }

        if let minVerticalDistance, abs(minVerticalDistance.delta) <= threshold {
            dy = minVerticalDistance.delta
            snappedAnchors.append(minVerticalDistance.anchor)
        }

        return .init(delta: .init(x: dx, y: dy), snappedAnchors: snappedAnchors)
    }
}

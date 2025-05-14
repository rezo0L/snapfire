//
//  AxisSnapper.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import Foundation

struct AxisSnapper: Snapper {

    func calculateSnap(for proposedFrame: CGRect, anchors: [Anchor], threshold: CGFloat) -> CGRect {
        var dx: CGFloat = 0
        var dy: CGFloat = 0

        let minHorizontalDistance = anchors.filter { $0.angle == .zero }.flatMap { [$0.point.x - proposedFrame.minX,
                                                                                    $0.point.x - proposedFrame.maxX,
                                                                                    $0.point.x - proposedFrame.midX] }.min {
            abs($0) < abs($1)
        }
        let minVerticalDistance = anchors.filter { $0.angle == .pi / 2 }.flatMap { [$0.point.y - proposedFrame.minY,
                                                                                    $0.point.y - proposedFrame.maxY,
                                                                                    $0.point.y - proposedFrame.midY] }.min {
            abs($0) < abs($1)
        }

        if let minHorizontalDistance, abs(minHorizontalDistance) <= threshold {
            dx = minHorizontalDistance
        }

        if let minVerticalDistance, abs(minVerticalDistance) <= threshold {
            dy = minVerticalDistance
        }

        return proposedFrame.offsetBy(dx: dx, dy: dy)
    }
}

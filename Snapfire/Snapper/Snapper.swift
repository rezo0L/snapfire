//
//  Snapper.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import Foundation

/// Struct representing an anchor point and its angle.
public struct Anchor {
    /// The point of the anchor in the coordinate space.
    public let point: CGPoint

    /// The angle of the anchor in radians.
    public let angle: CGFloat
}

/// Protocol defining the snapping behavior.
///
/// This protocol is responsible for calculating the snapping behavior of a view based on its proposed frame and a set of anchor points.
public protocol Snapper {

    /// Calculates the snapping behavior for a given proposed frame and a set of anchor points.
    func calculateSnap(for proposedFrame: CGRect, anchors: [Anchor], threshold: CGFloat) -> CGRect
}

//
//  CanvasViewModel.swift
//  Snapfire
//
//  Created by Reza on 2025-05-15.
//

import UIKit

final class CanvasViewModel {
    private let snapper: Snapper
    private let canvasSize: CGSize

    private(set) var selectedItem: UIView?
    private(set) var anchors: [Anchor] = []

    private let snapThreshold: CGFloat = 1

    private var itemPickerViewModelReference: ItemPickerViewModel?

    init(snapper: Snapper = AxisSnapper(), canvasSize: CGSize) {
        self.snapper = snapper
        self.canvasSize = canvasSize
    }

    func itemPickerViewModel() -> ItemPickerViewModel {
        let viewModel = ItemPickerViewModel()
        itemPickerViewModelReference = viewModel
        return viewModel
    }

    func select(item: UIView, in canvasView: UIView) {
        guard selectedItem != item else { return }

        deselectItem()
        selectedItem = item

        canvasView.bringSubviewToFront(item)
        calculateAnchors(in: canvasView)

        item.layer.borderColor = UIColor.systemBlue.cgColor
        item.layer.borderWidth = 1
    }

    func deselectItem() {
        selectedItem?.layer.borderColor = nil
        selectedItem?.layer.borderWidth = 0
        selectedItem = nil
    }

    private func createItem(from image: UIImage) -> UIView {
        let itemHeight = canvasSize.height / 4
        let factor = itemHeight / image.size.height

        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0,
                                 width: image.size.width * factor,
                                 height: image.size.height * factor)
        imageView.isUserInteractionEnabled = true
        return imageView
    }

    func addItem(from image: UIImage, to canvas: UIView) {
        let item = createItem(from: image)
        canvas.addSubview(item)
        select(item: item, in: canvas)
    }

    func calculateAnchors(in canvasView: UIView) {
        guard let selectedItem else { return }

        var xAnchors = [0, canvasView.frame.width / 2, canvasView.frame.width]
        var yAnchors = [0, canvasView.frame.height / 2, canvasView.frame.height]

        for subview in canvasView.subviews where subview != selectedItem {
            xAnchors.append(contentsOf: [subview.frame.minX, subview.frame.midX, subview.frame.maxX])
            yAnchors.append(contentsOf: [subview.frame.minY, subview.frame.midY, subview.frame.maxY])
        }

        anchors = xAnchors.map { Anchor(point: CGPoint(x: $0, y: 0), angle: .pi / 2) } +
                  yAnchors.map { Anchor(point: CGPoint(x: 0, y: $0), angle: .zero) }
    }

    func snapFrame(_ frame: CGRect) -> (snappedFrame: CGRect, xAnchor: CGFloat?, yAnchor: CGFloat?) {
        let result = snapper.calculateSnap(for: frame, anchors: anchors, threshold: snapThreshold)
        let snappedFrame = frame.offsetBy(dx: result.delta.x, dy: result.delta.y)

        let xAnchor = result.snappedAnchors.first(where: { $0.angle == .pi / 2 })?.point.x
        let yAnchor = result.snappedAnchors.first(where: { $0.angle == 0 })?.point.y

        return (snappedFrame, xAnchor, yAnchor)
    }
}

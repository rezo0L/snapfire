//
//  ViewController.swift
//  Snapfire
//
//  Created by Reza on 2025-05-11.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Canvas properties

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.5 // Magic number: no specific requirement, feel free to play around with it
        scrollView.maximumZoomScale = 3.0 // Magic number: same as above
        scrollView.delegate = self
        scrollView.backgroundColor = .black
        return scrollView
    }()

    private lazy var canvasView: UIView = {
        let screenWidth = UIScreen.main.bounds.width * 0.8 // Magic number: no specific requirement, it just looks good
        let canvas = UIView(frame: CGRect(origin: .zero, size: .init(width: screenWidth, height: screenWidth)))
        canvas.backgroundColor = .white
        return canvas
    }()

    // MARK: Item selector properties

    private var selectedItem: UIView?

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCanvas()
        setupItemSelector()
        setupItemDragger()
    }

    // MARK: Canvas methods

    private func setupCanvas() {
        scrollView.frame = view.bounds
        view.addSubview(scrollView)

        scrollView.contentSize = canvasView.bounds.size
        scrollView.addSubview(canvasView)

        centerCanvas()
    }

    private func centerCanvas() {
        let bounds = scrollView.bounds
        let contentSize = scrollView.contentSize

        let offsetX = max((bounds.width - contentSize.width) / 2, 0)
        let offsetY = max((bounds.height - contentSize.height) / 2, 0)

        canvasView.frame.origin = CGPoint(x: offsetX, y: offsetY)
    }

    // MARK: Item selector methods

    private func setupItemSelector() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCanvasTap(_:)))
        canvasView.addGestureRecognizer(tapGesture)

        addTestItems()
    }

    @objc private func handleCanvasTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: canvasView)

        if let tappedItem = canvasView.subviews.first(where: { $0.frame.contains(location) }) {
            select(item: tappedItem)
        } else {
            deselectItem()
        }
    }

    private func select(item: UIView) {
        if selectedItem != item {
            deselectItem()
            selectedItem = item
            item.layer.borderColor = UIColor.yellow.cgColor
            item.layer.borderWidth = 3
        }
    }

    private func deselectItem() {
        selectedItem?.layer.borderWidth = 0
        selectedItem = nil
    }

    func addTestItems() {
        let item1 = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        item1.backgroundColor = .blue
        canvasView.addSubview(item1)

        let item2 = UIView(frame: CGRect(x: 250, y: 250, width: 50, height: 50))
        item2.backgroundColor = .green
        canvasView.addSubview(item2)
    }

    // MARK: Item dragger methods

    private func setupItemDragger() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        canvasView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let item = selectedItem else { return }

        let translation = gesture.translation(in: canvasView)

        switch gesture.state {
        case .changed, .ended:
            item.center = CGPoint(x: item.center.x + translation.x,
                                  y: item.center.y + translation.y)
            gesture.setTranslation(.zero, in: canvasView)

        default:
            break
        }
    }
}

extension ViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        canvasView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerCanvas()
    }
}

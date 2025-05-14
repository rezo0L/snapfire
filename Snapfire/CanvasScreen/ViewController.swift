//
//  ViewController.swift
//  Snapfire
//
//  Created by Reza on 2025-05-11.
//

import UIKit

class ViewController: UIViewController {

    init(snapper: Snapper = AxisSnapper()) {
        self.snapper = snapper
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.snapper = AxisSnapper()
        super.init(coder: coder)
    }
    
    // MARK: Canvas properties

    // Magic numbers: no specific requirement, it just looks good
    private let canvasSize = CGSize(width: UIScreen.main.bounds.width,
                                    height: UIScreen.main.bounds.width * 0.6)

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 0.5 // Magic number: no specific requirement, feel free to play around with it
        scrollView.maximumZoomScale = 3.0 // Magic number: same as above
        scrollView.delegate = self
        scrollView.backgroundColor = .black
        return scrollView
    }()

    private lazy var canvasView: UIView = {
        let canvas = UIView(frame: CGRect(origin: .zero, size: canvasSize))
        canvas.backgroundColor = .white
        return canvas
    }()

    // MARK: Item selector properties

    private var selectedItem: UIView?

    // MARK: Item dragger properties

    private let snapThreshold: CGFloat = 1 // Magic number: it just works well

    private var horizontalAnchors = [CGFloat]()
    private var verticalAnchors = [CGFloat]()

    private var initialTouchPoint: CGPoint = .zero
    private var initialItemFrame: CGRect = .zero

    private let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    private let horizontalGuide = UIView()
    private let verticalGuide = UIView()

    private let snapper: Snapper

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCanvas()
        setupItemSelector()
        setupItemDragger()
        setupItemAdder()
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
            calculateAnchors()

            item.layer.borderColor = UIColor.systemBlue.cgColor
            item.layer.borderWidth = 1
        }
    }

    private func deselectItem() {
        selectedItem?.layer.borderWidth = 0
        selectedItem = nil
    }

    // MARK: Item dragger methods

    private func setupItemDragger() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        canvasView.addGestureRecognizer(panGesture)

        hapticFeedbackGenerator.prepare()
        setupGuidelines()
    }

    private func setupGuidelines() {
        [horizontalGuide, verticalGuide].forEach {
            $0.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.8)
            canvasView.addSubview($0)
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let item = selectedItem else { return }

        let currentTouchPoint = gesture.location(in: canvasView)

        switch gesture.state {
        case .began:
            initialTouchPoint = currentTouchPoint
            initialItemFrame = item.frame

        case .changed:
            let dx = currentTouchPoint.x - initialTouchPoint.x
            let dy = currentTouchPoint.y - initialTouchPoint.y

            let proposedFrame = initialItemFrame.offsetBy(dx: dx, dy: dy)
            let adjustedFrame = snapper.calculateSnap(
                for: proposedFrame,
                anchors: horizontalAnchors.map { Anchor(point: CGPoint(x: $0, y: 0), angle: .zero) } +
                         verticalAnchors.map { Anchor(point: CGPoint(x: 0, y: $0), angle: .pi / 2) },
                threshold: snapThreshold
            )

            // Snap happened
            if adjustedFrame.minX != proposedFrame.minX {
                let x = horizontalAnchors.first(where: { [adjustedFrame.minX, adjustedFrame.maxX, adjustedFrame.midX].contains($0) }) ?? adjustedFrame.minX
                verticalGuide.isHidden = false
                verticalGuide.frame = CGRect(x: x, y: 0, width: 1, height: canvasView.bounds.height)

                // New snap
                if adjustedFrame.minX != item.frame.minX {
                    hapticFeedbackGenerator.impactOccurred()
                    hapticFeedbackGenerator.prepare()
                }
            } else {
                verticalGuide.isHidden = true
            }

            if adjustedFrame.minY != proposedFrame.minY {
                let y = verticalAnchors.first(where: { [adjustedFrame.minY, adjustedFrame.maxY, adjustedFrame.midY].contains($0) }) ?? adjustedFrame.minY
                horizontalGuide.isHidden = false
                horizontalGuide.frame = CGRect(x: 0, y: y, width: canvasView.bounds.width, height: 1)

                // New snap
                if adjustedFrame.minY != item.frame.minY {
                    hapticFeedbackGenerator.impactOccurred()
                    hapticFeedbackGenerator.prepare()
                }
            } else {
                horizontalGuide.isHidden = true
            }
            item.frame = adjustedFrame

        case .ended, .cancelled, .failed:
            initialTouchPoint = .zero
            initialItemFrame = .zero
            horizontalGuide.isHidden = true
            verticalGuide.isHidden = true

        default:
            break
        }
    }

    private func calculateAnchors() {
        horizontalAnchors = [0, canvasView.frame.width / 2, canvasView.frame.width]
        horizontalAnchors += canvasView.subviews.filter { $0 != selectedItem && $0 != horizontalGuide && $0 != verticalGuide }.flatMap { [$0.frame.minX, $0.frame.midX, $0.frame.maxX] }

        verticalAnchors = [0, canvasView.frame.height / 2, canvasView.frame.height]
        verticalAnchors += canvasView.subviews.filter { $0 != selectedItem && $0 != horizontalGuide && $0 != verticalGuide }.flatMap { [$0.frame.minY, $0.frame.midY, $0.frame.maxY] }
    }

    // MARK: Item adder methods

    private func setupItemAdder() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(showItemPicker), for: .touchUpInside)

        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48),
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    @objc private func showItemPicker() {
        let viewController = ItemPickerViewController()
        viewController.modalPresentationStyle = .pageSheet

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        viewController.onItemSelected = { [weak self] item in
            self?.addItem(item)
        }

        present(viewController, animated: true)
    }

    private func addItem(_ item: UIImage) {
        let itemHeight = canvasSize.height / 4
        let factor = itemHeight / item.size.height

        let imageView = UIImageView(image: item)
        imageView.frame = CGRect(x: 0, y: 0, width: item.size.width * factor, height: item.size.height * factor)
        imageView.isUserInteractionEnabled = true

        canvasView.addSubview(imageView)
        select(item: imageView)
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

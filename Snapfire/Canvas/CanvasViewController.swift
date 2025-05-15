//
//  CanvasViewController.swift
//  Snapfire
//
//  Created by Reza on 2025-05-11.
//

import UIKit

class CanvasViewController: UIViewController {

    private let viewModel: CanvasViewModel
    private var selectedItem: UIView? { viewModel.selectedItem }

    init(viewModel: CanvasViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.viewModel = .init()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCanvas()
        setupItemSelector()
        setupItemDragger()
        setupItemAdder()
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

    // MARK: Item dragger properties

    private var anchors = [Anchor]()
    private let snapThreshold: CGFloat = 1 // Magic number: it just works well

    private var initialTouchPoint: CGPoint = .zero
    private var initialItemFrame: CGRect = .zero

    private let hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    private let horizontalGuide = UIView()
    private let verticalGuide = UIView()

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
            viewModel.select(item: tappedItem, in: canvasView)
        } else {
            viewModel.deselectItem()
        }
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
            let (snappedFrame, xAnchor, yAnchor) = viewModel.snapFrame(proposedFrame)

            item.frame = snappedFrame
            updateGuides(xAnchor: xAnchor, yAnchor: yAnchor)

        case .ended, .cancelled, .failed:
            initialTouchPoint = .zero
            initialItemFrame = .zero
            horizontalGuide.isHidden = true
            verticalGuide.isHidden = true

        default:
            break
        }
    }

    private func updateGuides(xAnchor: CGFloat?, yAnchor: CGFloat?) {
        if let x = xAnchor {
            verticalGuide.isHidden = false
            verticalGuide.frame = CGRect(x: x, y: 0, width: 1, height: canvasView.bounds.height)
            hapticFeedbackGenerator.impactOccurred()
        } else {
            verticalGuide.isHidden = true
        }

        if let y = yAnchor {
            horizontalGuide.isHidden = false
            horizontalGuide.frame = CGRect(x: 0, y: y, width: canvasView.bounds.width, height: 1)
            hapticFeedbackGenerator.impactOccurred()
        } else {
            horizontalGuide.isHidden = true
        }
        hapticFeedbackGenerator.prepare()
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
        let viewModel = viewModel.itemPickerViewModel()
        let viewController = ItemPickerViewController(viewModel: viewModel)

        viewController.onItemSelected = { [weak self] item in
            guard let self else { return }
            self.viewModel.addItem(from: item, to: canvasView)
        }

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet

        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(navigationController, animated: true)
    }
}

extension CanvasViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        canvasView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerCanvas()
    }
}

#if DEBUG
extension CanvasViewController {
    // Helper method to add an item to the canvas at a specified location
    func addTestItem(_ item: UIView) {
        canvasView.addSubview(item)
        viewModel.select(item: item, in: canvasView)
    }

    // Helper method to simulate panning an item
    func simulatePan(from startPoint: CGPoint, to endPoint: CGPoint) {
        let panGesture1 = MockPanGestureRecognizer(translation: .zero, location: .init(x: startPoint.x, y: startPoint.y), state: .began)
        handlePan(panGesture1)

        let panGesture2 = MockPanGestureRecognizer(translation: .zero, location: .init(x: endPoint.x, y: endPoint.y), state: .changed)
        handlePan(panGesture2)
    }
}

class MockPanGestureRecognizer: UIPanGestureRecognizer {
    private let mockLocation: CGPoint
    private let mockState: UIGestureRecognizer.State

    init(translation: CGPoint, location: CGPoint, state: UIGestureRecognizer.State) {
        self.mockLocation = location
        self.mockState = state

        super.init(target: nil, action: nil)
    }

    override func location(in view: UIView?) -> CGPoint {
        return mockLocation
    }

    override var state: UIGestureRecognizer.State {
        get { mockState }
        set { /* ignore, static mock */ }
    }
}
#endif

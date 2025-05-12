//
//  ViewController.swift
//  Snapfire
//
//  Created by Reza on 2025-05-11.
//

import UIKit

class ViewController: UIViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCanvas()
    }

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

}

extension ViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        canvasView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerCanvas()
    }
}

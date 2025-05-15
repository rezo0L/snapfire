//
//  ItemPickerViewController.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import XCTest
import SnapshotTesting
import UIKit

@testable import Snapfire

class ItemPickerViewControllerTests: XCTestCase {

    private let sourceURL = Bundle.main.bundleURL

    func testViewController_moreThanOneCategory() {
        let categories: [Snapfire.Category] = [
            Category(title: "Category 1", items: Array(repeating: .init(sourceURL: sourceURL), count: 6)),
            Category(title: "Category 2", items: Array(repeating: .init(sourceURL: sourceURL), count: 12)),
            Category(title: "Category 3", items: Array(repeating: .init(sourceURL: sourceURL), count: 19)),
        ]
        let viewModel = ItemPickerViewModel(categories: categories)
        let viewController = ItemPickerViewController(viewModel: viewModel)
        assertSnapshot(of: viewController.view, as: .image)
    }

    func testViewController_onlyOneCategory() {
        let categories: [Snapfire.Category] = [
            Category(title: "Category 3", items: Array(repeating: .init(sourceURL: sourceURL), count: 19))
        ]
        let viewModel = ItemPickerViewModel(categories: categories)
        let viewController = ItemPickerViewController(viewModel: viewModel)
        assertSnapshot(of: viewController.view, as: .image)
    }
}

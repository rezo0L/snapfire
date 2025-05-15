//
//  ItemPickerViewModelTests.swift
//  Snapfire
//
//  Created by Reza on 2025-05-15.
//

import XCTest

@testable import Snapfire

final class ItemPickerViewModelTests: XCTestCase {

    private let sourceURL = Bundle.main.bundleURL

    func testSections_withSingleCategory_hasNoItemLimit() throws {
        let title = "Stickers"
        let items = Array(repeating: Category.Item(sourceURL: sourceURL), count: 50)
        let category = Category(title: title, items: items)

        let viewModel = ItemPickerViewModel(categories: [category])
        let section = try XCTUnwrap(viewModel.sections.first)

        XCTAssertEqual(section.title, title)
        XCTAssertEqual(section.items.count, items.count)

        for (index, content) in section.items.enumerated() {
            if case let .image(url) = content {
                XCTAssertEqual(url, category.items[index].sourceURL)
            } else {
                XCTFail("Expected .image for item at index \(index)")
            }
        }
    }

    func testSections_withMultipleCategories_appliesItemLimit() throws {
        let category1 = Category(title: "Cats", items: Array(repeating: .init(sourceURL: sourceURL), count: 20))
        let category2 = Category(title: "Dogs", items: Array(repeating: .init(sourceURL: sourceURL), count: 8))

        let viewModel = ItemPickerViewModel(categories: [category1, category2])

        XCTAssertEqual(viewModel.sections.count, 2)

        let firstSection = viewModel.sections[0]
        let secondSection = viewModel.sections[1]

        XCTAssertEqual(firstSection.items.count, 12)
        XCTAssertEqual(secondSection.items.count, 8)
    }

    func testSections_replacesLastItemWithLabel_whenExceedingMaxLimitForMultipleCategories() throws {
        let items = Array(repeating: Category.Item(sourceURL: sourceURL), count: 15)
        let category1 = Category(title: "Emojis", items: items)
        let category2 = Category(title: "Faces", items: items)

        let viewModel = ItemPickerViewModel(categories: [category1, category2])
        let section = try XCTUnwrap(viewModel.sections.first)

        XCTAssertEqual(section.items.count, 12)

        if case let .label(text) = section.items[11] {
            XCTAssertEqual(text, "+4")
        } else {
            XCTFail("Expected last item to be a .label")
        }
    }

    func testNavigationAction_returnsShowImage() throws {
        let items = [Category.Item(sourceURL: sourceURL)]
        let category = Category(title: "Icons", items: items)
        let image = UIImage()

        let viewModel = ItemPickerViewModel(categories: [category])
        let indexPath = IndexPath(item: 0, section: 0)
        let action = try XCTUnwrap(viewModel.navigationAction(for: indexPath, selectedImage: image))

        switch action {
        case .showImage(let selected):
            XCTAssertEqual(selected, image)
        default:
            XCTFail("Expected .showImage action")
        }
    }

    func testNavigationAction_returnsShowCategory_whenMultipleCategories() throws {
        let items = Array(repeating: Category.Item(sourceURL: sourceURL), count: 15)
        let category1 = Category(title: "More", items: items)
        let category2 = Category(title: "Other", items: items)

        let viewModel = ItemPickerViewModel(categories: [category1, category2])
        let indexPath = IndexPath(item: 11, section: 0)
        let action = try XCTUnwrap(viewModel.navigationAction(for: indexPath, selectedImage: nil))

        switch action {
        case .showCategory(let nextViewModel):
            let nextSection = try XCTUnwrap(nextViewModel.sections.first)
            XCTAssertEqual(nextSection.title, "More")
            XCTAssertEqual(nextSection.items.count, items.count)
        default:
            XCTFail("Expected .showCategory action")
        }
    }

    func testNavigationAction_returnsNil_whenImageIsMissing() {
        let items = [Category.Item(sourceURL: sourceURL)]
        let category = Category(title: "Stickers", items: items)

        let viewModel = ItemPickerViewModel(categories: [category])
        let indexPath = IndexPath(item: 0, section: 0)
        let action = viewModel.navigationAction(for: indexPath, selectedImage: nil)

        XCTAssertNil(action)
    }
}

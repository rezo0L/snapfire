//
//  ItemPickerViewModel.swift
//  Snapfire
//
//  Created by Reza on 2025-05-15.
//

import UIKit

final class ItemPickerViewModel {

    struct Section {
        enum Content {
            case image(URL)
            case label(String)
        }

        let title: String
        let items: [Content]
    }

    enum NavigationAction {
        case showImage(UIImage)
        case showCategory(ItemPickerViewModel)
    }

    private var categories: [Category] = []

    @Published private(set) var sections: [Section] = []

    init(overlayService: OverlayService = RemoteOverlayService()) {
        Task {
            categories = try await overlayService.fetchOverlays()
            setupSections()
        }
    }

    init(category: Category) {
        categories = [category]
        setupSections()
    }

    func setupSections() {
        let maximumItemsPerSection = categories.count > 1 ? 12 : .max

        sections = categories.map { category in
            let itemCount = category.items.count
            var items: [Section.Content] = category.items.prefix(maximumItemsPerSection).map {
                .image($0.sourceURL)
            }

            if itemCount > maximumItemsPerSection {
                items[maximumItemsPerSection - 1] = .label("+\(itemCount - maximumItemsPerSection + 1)")
            }
            return Section(title: category.title, items: items)
        }
    }

    func navigationAction(for indexPath: IndexPath, selectedImage: UIImage?) -> NavigationAction? {
        let item = sections[indexPath.section].items[indexPath.item]
        switch item {
        case .image:
            guard let image = selectedImage else {
                return nil
            }
            return .showImage(image)

        case .label:
            let category = categories[indexPath.section]
            let nextViewModel = ItemPickerViewModel(category: category)
            return .showCategory(nextViewModel)
        }
    }
}

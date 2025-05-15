//
//  MockOverlayService.swift
//  Snapfire
//
//  Created by Reza on 2025-05-15.
//

@testable import Snapfire

struct MockOverlayService: OverlayService {
    private let categories: [Snapfire.Category]

    init(categories: [Snapfire.Category]) {
        self.categories = categories
    }

    func fetchOverlays() async throws -> [Snapfire.Category] {
        categories
    }
}

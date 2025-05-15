//
//  OverlayService.swift
//  Snapfire
//
//  Created by Reza on 2025-05-15.
//

import Foundation

struct Category: Decodable {
    let title: String
    let items: [Item]

    struct Item: Decodable {
        let sourceURL: URL

        enum CodingKeys: String, CodingKey {
            case sourceURL = "source_url"
        }
    }
}

protocol OverlayService {
    func fetchOverlays() async throws -> [Category]
}

struct RemoteOverlayService: OverlayService {
    func fetchOverlays() async throws -> [Category] {
        guard let url = URL(string: "https://appostropheanalytics.herokuapp.com/scrl/test/overlays") else { return [] }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Category].self, from: data)
    }
}

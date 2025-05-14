//
//  Category.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
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

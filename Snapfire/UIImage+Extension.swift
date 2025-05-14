//
//  AsyncImage.swift
//  Snapfire
//
//  Created by Reza on 2025-05-14.
//

import UIKit

class ImageCache {
    static let shared = NSCache<NSURL, UIImage>()
}

extension UIImage {
    static func from(url: URL) async throws -> UIImage? {
        if let cached = ImageCache.shared.object(forKey: url as NSURL) {
            return cached
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            ImageCache.shared.setObject(image, forKey: url as NSURL)
            return image
        }

        return nil
    }
}

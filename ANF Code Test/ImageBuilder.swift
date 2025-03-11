//
//  ImageBuilder.swift
//  ANF Code Test
//
//  Created by Raghu Reddy on 3/10/25.
//

import UIKit

class ImageBuilder {
    static let shared = ImageBuilder()
    private let cache = NSCache<NSURL, UIImage>()

    // Loads an image from a URL and applies caching
    func loadImage(
        from urlString: String?, into imageView: UIImageView,
        placeholder: UIImage?
    ) {
        DispatchQueue.main.async {
            imageView.image = placeholder  // Sets placeholder immediately
        }

        guard let urlString = urlString, let url = URL(string: urlString),
            !urlString.isEmpty
        else {
            return
        }

        // Return cached image if available
        if let cachedImage = cache.object(forKey: url as NSURL) {
            DispatchQueue.main.async {
                imageView.image = cachedImage
            }
            return
        }

        // Fetch image asynchronously
        let task = URLSession.shared.dataTask(with: url) {
            [weak self] data, _, error in
            guard let self = self, let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }

            self.cache.setObject(image, forKey: url as NSURL)  // Cache the image

            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        task.resume()
    }
}

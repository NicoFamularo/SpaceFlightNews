//
//  UIImageView+Extensions.swift
//  SpaceFlightSpace
//
//  Created by Nico on 10/07/2025.
//

import UIKit

extension UIImageView: SkeletonizableView {
    private static let imageCache = NSCache<NSString, UIImage>()
    
    public func showSkeleton() {
        self.createSkeleton()
    }
    
    public func hideSkeleton() {
        self.dismissSkeletonsView()
    }
    
    func loadImage(from urlString: String) {
        self.showSkeleton()
        let urlString = urlString.replacingOccurrences(of: "http://", with: "https://")
        let cacheKey = NSString(string: urlString)
        
        if let cachedImage = UIImageView.imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            hideSkeleton()
            return
        }

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                return
            }
            UIImageView.imageCache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve) { [weak self] in
                    guard let self else { return }
                    self.image = image
                    self.hideSkeleton()
                }
            }
        }.resume()
    }
}


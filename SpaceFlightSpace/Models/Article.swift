//
//  Article.swift
//  SpaceFlightSpace
//
//  Created by Nico on 10/07/2025.
//

import UIKit

struct Article: Codable {
    let id: Int?
    let title: String?
    let summary: String?
    let image_url: String?
    let published_at: String?
    let url: String?
    let authors: [Authors]?
}

extension Article {
    var icon: UIImage {
        let icons: [UIImage] = [.planet1, .planet2, .planet3]
        return icons.randomElement() ?? .planet1
    }
    
    var publishedDate: Date {
        guard let published_at else { return .now }
        return ISO8601DateFormatter().date(from: published_at) ?? .now
    }
    
    var authorsFormatted: String {
        var authors = ""
        self.authors?.forEach({ author in
            if authors == "" {
                authors.append("by " + (author.name ?? ""))
            } else {
                authors.append(", " + (author.name ?? ""))
            }
        })
        return authors
    }
}


//
//  ArticleResponse.swift
//  SpaceFlightSpace
//
//  Created by Nico on 10/07/2025.
//

import Foundation

struct ArticleResponse: Codable {
    let results: [Article]?
    let count: Int?
    let previous: String?
    let next: String?
}

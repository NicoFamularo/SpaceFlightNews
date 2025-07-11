//
//  APIClient.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import Foundation
import UIKit

/// Protocol defining the main API client interface.
/// This protocol provides access to all service protocols,
/// acting as a centralized entry point for network operations.
protocol APIClientProtocol {
    /// Service for article-related network operations.
    var articles: ArticleServiceProtocol { get }
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()
    
    let articles: ArticleServiceProtocol = ArticleService()
    
    /// Private initializer for the singleton APIClient.
    /// This initializer is private to enforce the singleton pattern,
    /// ensuring only one instance of APIClient exists throughout the application lifecycle.
    /// - Note: Access the shared instance using `APIClient.shared`.
    private init() {}
}

enum APIError: Error {
    case invalidURL
    case noData
}


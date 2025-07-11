//
//  ArticleService.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import Foundation

/// Protocol defining the interface for article-related network operations.
/// This protocol abstracts the article service implementation,
/// allowing for easy testing and dependency injection.
protocol ArticleServiceProtocol {
    /// Fetches articles from the remote API.
    /// - Parameters:
    ///   - search: Optional search term to filter articles.
    ///   - pageURL: Optional URL for pagination.
    ///   - completion: Completion handler with Result containing ArticleResponse or Error.
    func fetchArticles(search: String?, pageURL: String?, completion: @escaping (Result<ArticleResponse, Error>) -> Void)
}

struct ArticleService: ArticleServiceProtocol {
    private let baseURL = "https://api.spaceflightnewsapi.net/v4/articles/"
    
    func fetchArticles(search: String? = nil, pageURL: String? = nil, completion: @escaping (Result<ArticleResponse, Error>) -> Void) {
        let url: URL?
        let limit = "10"

        if let pageURL = pageURL {
            url = URL(string: pageURL)
        } else {
            guard var urlComponents = URLComponents(string: baseURL) else {
                completion(.failure(APIError.invalidURL))
                return
            }

            var queryItems = [
                URLQueryItem(name: "ordering", value: "-published_at"),
                URLQueryItem(name: "limit", value: limit)
            ]

            if let search = search, !search.isEmpty {
                queryItems.append(URLQueryItem(name: "search", value: search))
            }

            urlComponents.queryItems = queryItems
            url = urlComponents.url
        }

        guard let finalURL = url else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let request = URLRequest(url: finalURL)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(APIError.noData))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(ArticleResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

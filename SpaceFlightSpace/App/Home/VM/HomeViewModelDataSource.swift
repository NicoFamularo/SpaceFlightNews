//
//  HomeViewModelDataSource.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import Foundation

/// Protocol defining the data source interface for the Home view model.
/// This protocol separates data management concerns from the view model logic,
/// following the single responsibility principle.
protocol HomeViewModelDataSourceProtocol {
    /// The current list of articles in the data source.
    var items: [Article] { get set }
    
    /// The URL for loading the next page of articles.
    var nextPageURL: String? { get set }
    
    /// Loads initial articles with optional search functionality.
    /// - Parameters:
    ///   - text: Optional search term to filter articles.
    ///   - onSuccess: Closure called when articles are successfully loaded.
    ///   - onError: Closure called when an error occurs during loading.
    func loadInitialArticles(text: String?, onSuccess: @escaping ([Article]) -> Void, onError: @escaping (Error) -> Void)
    
    /// Loads additional articles for pagination.
    /// - Parameters:
    ///   - onSuccess: Closure called when additional articles are successfully loaded.
    ///   - onError: Closure called when an error occurs during loading.
    func loadMoreArticles(onSuccess: @escaping ([Article]) -> Void, onError: @escaping (Error) -> Void)
}

final class HomeViewModelDataSource: HomeViewModelDataSourceProtocol {
    var items: [Article]
    var nextPageURL: String?
    var text: String?
    
    let apiClient: APIClientProtocol
    
    /// Creates a HomeViewModelDataSource with optional initial configuration.
    /// This initializer allows for flexible setup of the data source with
    /// optional pre-loaded items, pagination URL, and custom API client.
    /// - Parameters:
    ///   - items: Initial array of articles (defaults to empty array).
    ///   - nextPageURL: Optional URL for the next page of articles (defaults to nil).
    ///   - apiClient: The API client to use for network requests (defaults to APIClient.shared).
    init(items: [Article] = [], nextPageURL: String? = nil, apiClient: APIClientProtocol = APIClient.shared) {
        self.items = items
        self.nextPageURL = nextPageURL
        self.apiClient = apiClient
    }
    
    func loadInitialArticles(
        text: String?,
        onSuccess: @escaping ([Article]) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        nextPageURL = nil
        self.text = text
        apiClient.articles.fetchArticles(
            search: text,
            pageURL: nil,
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        guard let self else { return }
                        self.items = response.results ?? []
                        self.nextPageURL = response.next
                        onSuccess(self.items)
                    case .failure(let error):
                        onError(error)
                    }
                }
            })
    }
    
    func loadMoreArticles(
        onSuccess: @escaping ([Article]) -> Void,
        onError: @escaping (Error) -> Void
    ) {
        guard let nextPage = nextPageURL else { return }
        apiClient.articles.fetchArticles(
            search: text,
            pageURL: nextPage,
            completion: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        guard let self else { return }
                        let newArticles = response.results ?? []
                        
                        self.items += newArticles
                        self.nextPageURL = response.next
                        onSuccess(newArticles)
                    case .failure(let error):
                        onError(error)
                    }
                }
            })
    }
}

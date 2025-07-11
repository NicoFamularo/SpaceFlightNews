//
//  HomeViewModel.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import Foundation

/// Protocol defining the interface for the Home screen's view model.
/// This protocol abstracts the Home view model implementation,
/// enabling clean architecture and testability.
protocol HomeViewModelProtocol {
    /// Gets the current list of articles.
    /// - Returns: Array of Article objects currently loaded in the view model.
    func getItems() -> [Article]
    
    /// Loads the initial set of articles for the home screen.
    /// - Parameters:
    ///   - onSuccess: Closure called when articles are successfully loaded.
    ///   - onError: Closure called when an error occurs during loading.
    func loadInitialArticles(onSuccess: @escaping ([Article]) -> Void, onError: @escaping (Error) -> Void)
    
    /// Searches for articles based on the provided text.
    /// - Parameters:
    ///   - text: The search query text.
    ///   - onSuccess: Closure called when search results are successfully loaded.
    ///   - onError: Closure called when an error occurs during search.
    func searchArticles(text: String, onSuccess: @escaping ([Article]) -> Void, onError: @escaping (Error) -> Void)
    
    /// Loads more articles for pagination.
    /// - Parameters:
    ///   - onSuccess: Closure called when additional articles are successfully loaded.
    ///   - onError: Closure called when an error occurs during loading.
    func loadMoreArticles(onSuccess: @escaping ([Article]) -> Void, onError: @escaping (Error) -> Void)
}

final class HomeViewModel: HomeViewModelProtocol {
    var datasource: HomeViewModelDataSourceProtocol
    
    /// Creates a HomeViewModel with the specified data source.
    /// This initializer sets up the view model with its data source dependency,
    /// enabling the separation of concerns between view logic and data management.
    /// - Parameter datasource: The data source conforming to HomeViewModelDataSourceProtocol
    ///   that will handle data operations for the home screen.
    init(datasource: HomeViewModelDataSourceProtocol) {
        self.datasource = datasource
    }
    
    func getItems() -> [Article] {
        return datasource.items
    }

    func loadInitialArticles(onSuccess: @escaping ([Article]) -> Void, onError: @escaping (Error) -> Void) {
        datasource.loadInitialArticles(text: nil, onSuccess: onSuccess, onError: onError)
    }
    
    func loadMoreArticles(onSuccess: @escaping ([Article]) -> Void, onError: @escaping (Error) -> Void) {
        datasource.loadMoreArticles(onSuccess: onSuccess, onError: onError)
    }
    
    func searchArticles(text: String, onSuccess: @escaping ([Article]) -> Void, onError: @escaping (Error) -> Void) {
        datasource.loadInitialArticles(text: text, onSuccess: onSuccess, onError: onError)
    }
}

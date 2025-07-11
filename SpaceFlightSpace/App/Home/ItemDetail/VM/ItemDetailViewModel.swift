//
//  ItemDetailViewModel.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import Foundation
import UIKit

/// Protocol defining the interface for the Item Detail screen's view model.
/// This protocol provides access to article details and related functionality
/// for the detail view controller.
protocol ItemDetailViewModelProtocol {
    /// The data source containing the article information.
    var datasource: ItemDetailDataSourceProtocol { get }
    
    /// Helper for article-related operations.
    var articleHelper: ArticleHelper { get }
    
    func getItem() -> Article
    func openFullArticle(_ vc: UIViewController)
}

final class ItemDetailViewModel: ItemDetailViewModelProtocol {
    var datasource: ItemDetailDataSourceProtocol
    var articleHelper: ArticleHelper
    
    /// Creates an ItemDetailViewModel with the specified data source and article helper.
    /// This initializer sets up the detail view model with its required dependencies
    /// for displaying article information and handling related operations.
    /// - Parameters:
    ///   - datasource: The data source conforming to ItemDetailDataSourceProtocol
    ///     that contains the article to be displayed.
    ///   - articleHelper: Helper instance for article-related operations (defaults to new instance).
    init(datasource: ItemDetailDataSourceProtocol, articleHelper: ArticleHelper = .init()) {
        self.datasource = datasource
        self.articleHelper = articleHelper
    }

    func getItem() -> Article {
        return datasource.item
    }
    
    func openFullArticle(_ vc: UIViewController) {
        articleHelper.openFullArticle(from: datasource.item.url ?? "", in: vc)
    }
}


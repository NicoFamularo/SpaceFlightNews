//
//  ItemDetailDataSource.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import Foundation

/// Protocol defining the data source interface for item detail information.
/// This protocol encapsulates the data required for displaying article details.
protocol ItemDetailDataSourceProtocol {
    /// The article item to be displayed in the detail view.
    var item: Article { get }
}

struct ItemDetailDataSource: ItemDetailDataSourceProtocol {
    let item: Article
}

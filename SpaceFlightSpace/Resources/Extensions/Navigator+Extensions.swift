//
//  Navigator+Extensions.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import Foundation

enum NavigationScreens {
    case itemDetail(Article)
    
    func getViewController() -> any Navigable {
        switch self {
        case .itemDetail(let item):
            let ds = ItemDetailDataSource(item: item)
            let vm = ItemDetailViewModel(datasource: ds)
            return ItemDetailViewController(viewModel: vm)
        }
    }
}

extension Navigator {
    func goTo(_ screen: NavigationScreens) {
        push(viewController: screen.getViewController())
    }
}

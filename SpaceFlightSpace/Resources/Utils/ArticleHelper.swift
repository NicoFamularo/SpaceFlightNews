//
//  ArticleHelper.swift
//  SpaceFlightSpace
//
//  Created by Nico on 10/07/2025.
//

import Foundation
import SafariServices

final class ArticleHelper {
    func openFullArticle(from urlString: String, in viewController: UIViewController) {
        guard let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        viewController.present(safariVC, animated: true)
    }
}

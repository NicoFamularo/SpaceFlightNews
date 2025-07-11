//
//  ItemDetailViewController.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import UIKit

class ItemDetailViewController: UIViewController, Navigable {
    var navigator: Navigator?
    let viewModel: ItemDetailViewModelProtocol
    
    // MARK: - Outlets
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var publishedAtLabel: UILabel!
    @IBOutlet private weak var authorsLabel: UILabel!
    @IBOutlet private weak var summaryLabel: UILabel!
    @IBOutlet private weak var newsUrlButton: UIButton!
    
    // MARK: - Initializers
    
    /// Creates an ItemDetailViewController with the specified view model.
    /// This initializer sets up the detail screen with its associated view model
    /// and loads the corresponding XIB file for the user interface.
    /// - Parameter viewModel: The view model conforming to ItemDetailViewModelProtocol
    ///   that will provide the article data and handle business logic.
    /// - Note: This initializer automatically loads the "ItemDetailViewController" XIB file.
    init(viewModel: ItemDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: "ItemDetailViewController", bundle: nil)
    }
    
    /// Required initializer for NSCoder (Storyboard/XIB instantiation).
    /// This initializer is required by UIViewController but not implemented
    /// since this view controller is designed to be instantiated programmatically.
    /// - Parameter coder: The NSCoder object containing the view controller data.
    /// - Warning: This method triggers a fatal error with message "init(coder:) has not been implemented"
    ///   as this view controller should only be instantiated programmatically.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        configureUI()
        configureData()
    }
    
    private func setupNavigationBar() {
        addCustomNavigationBar(title: "Detalle del artículo")
    }
    
    private func configureUI() {
        newsUrlButton.setTitle("Ver noticia", for: .normal)
        newsUrlButton.setTitle("Ver noticia", for: .selected)
        newsUrlButton.roundCorners()
    }
    
    private func configureData() {
        itemImageView.loadImage(from: viewModel.getItem().image_url ?? "")
        titleLabel.text = viewModel.getItem().title
        authorsLabel.text = viewModel.getItem().authorsFormatted
        publishedAtLabel.text = viewModel.getItem().publishedDate.formattedString()
        summaryLabel.text = viewModel.getItem().summary
    }
    
    @IBAction func seeNewsAction(_ sender: Any) {
        viewModel.openFullArticle(self)
    }
}

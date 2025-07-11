//
//  ItemTableViewCell.swift
//  SpaceFlightSpace
//
//  Created by Nico on 10/07/2025.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var itemTitle: UILabel!
    @IBOutlet private weak var itemAuthors: UILabel!
    @IBOutlet private weak var itemDate: UILabel!
    @IBOutlet private weak var itemImage: UIImageView!
    
    // MARK: - Identifier
    static let identifier = "ItemTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        self.selectionStyle = .none
        itemTitle.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        itemTitle.textColor = UIColor.label
    }
    
    // MARK: - Configuration
    func configure(with article: Article) {
        itemTitle.text = article.title
        itemAuthors.text = article.authorsFormatted
        itemImage.image = article.icon
        itemDate.text = article.publishedDate.formattedString()
    }
}


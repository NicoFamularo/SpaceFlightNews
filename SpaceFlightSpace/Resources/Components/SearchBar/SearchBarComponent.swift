//
//  SearchBarComponent.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import UIKit

// MARK: - Protocol

/// Protocol for handling search bar component events.
/// Conforming objects receive notifications about user interactions
/// with the search bar component.
protocol SearchBarComponentDelegate: AnyObject {
    /// Called when the user performs a search action.
    /// - Parameters:
    ///   - component: The search bar component that triggered the event.
    ///   - text: The search text entered by the user.
    func searchBarComponent(_ component: SearchBarComponent, didSearch text: String)
    
    /// Called when the search text changes.
    /// - Parameters:
    ///   - component: The search bar component that triggered the event.
    ///   - text: The current text in the search bar.
    func searchBarComponent(_ component: SearchBarComponent, didChangeText text: String)
}

class SearchBarComponent: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: SearchBarComponentDelegate?
    private var contentView: UIView!
    
    // MARK: - Initializers
    
    /// Creates a SearchBarComponent with the specified frame.
    /// This initializer sets up a search bar component programmatically with
    /// the given frame rectangle and loads the associated XIB file.
    /// - Parameter frame: The frame rectangle for the view, measured in points.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    /// Creates a SearchBarComponent from a storyboard or XIB file.
    /// This initializer is called when the component is loaded from Interface Builder
    /// and automatically loads the associated XIB file.
    /// - Parameter coder: The NSCoder object containing the component data from Interface Builder.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        loadNib()
        setupSearchBar()
        setupSearchButton()
    }
    
    private func loadNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil).first as? UIView
        
        guard let contentView = contentView else { return }
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Buscar..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor.clear
        searchBar.barTintColor = UIColor.clear
        
        // Personalizar la apariencia
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.systemBackground
            textField.layer.cornerRadius = 8
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemGray4.cgColor
            textField.textColor = UIColor.label
        }
    }
    
    private func setupSearchButton() {
        // Agregar acción
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        
        // Efecto visual al presionar
        searchButton.addTarget(self, action: #selector(searchButtonTouchDown), for: .touchDown)
        searchButton.addTarget(self, action: #selector(searchButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // MARK: - Actions
    @objc private func searchButtonTapped() {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchBar.resignFirstResponder()
        delegate?.searchBarComponent(self, didSearch: searchText)
    }
    
    @objc private func searchButtonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.searchButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.searchButton.alpha = 0.8
        }
    }
    
    @objc private func searchButtonTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.searchButton.transform = CGAffineTransform.identity
            self.searchButton.alpha = 1.0
        }
    }
    
    // MARK: - Public Methods
    
    /// Configura el delegate del componente
    /// - Parameter delegate: El objeto que implementa SearchBarComponentDelegate
    func configureDelegate(delegate: SearchBarComponentDelegate) {
        self.delegate = delegate
    }
    
    /// Limpia el texto de búsqueda
    func clearSearchText() {
        searchBar.text = ""
    }
    
    /// Obtiene el texto actual de búsqueda
    /// - Returns: El texto actual en la search bar
    func getCurrentSearchText() -> String {
        return searchBar.text ?? ""
    }
    
    /// Establece el texto de búsqueda
    /// - Parameter text: El texto a establecer
    func setSearchText(_ text: String) {
        searchBar.text = text
    }
    
    /// Establece el placeholder de la search bar
    /// - Parameter placeholder: El texto del placeholder
    func setPlaceholder(_ placeholder: String) {
        searchBar.placeholder = placeholder
    }
    
    /// Muestra o oculta el teclado
    /// - Parameter show: true para mostrar, false para ocultar
    func showKeyboard(_ show: Bool) {
        if show {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.resignFirstResponder()
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchBarComponent: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBarComponent(self, didChangeText: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        searchBar.resignFirstResponder()
        delegate?.searchBarComponent(self, didSearch: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        delegate?.searchBarComponent(self, didChangeText: "")
    }
} 

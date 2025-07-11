//
//  HomeViewController.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import UIKit

class HomeViewController: UIViewController, Navigable {
    var navigator: Navigator?
    let viewModel: HomeViewModelProtocol

    
    // MARK: - Outlets
    @IBOutlet private weak var searchBar: SearchBarComponent!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Initializers
    
    /// Creates a HomeViewController with the specified view model.
    /// This initializer sets up the home screen with its associated view model
    /// and loads the corresponding XIB file for the user interface.
    /// - Parameter viewModel: The view model conforming to HomeViewModelProtocol
    ///   that will handle the business logic for this view controller.
    /// - Note: This initializer automatically loads the "HomeViewController" XIB file.
    init(viewModel: HomeViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: "HomeViewController", bundle: nil)
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDelegates()
        getInitialData()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: ItemTableViewCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ItemTableViewCell.identifier)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func configureDelegates() {
        searchBar.configureDelegate(delegate: self)
    }
    
    private func getInitialData() {
        self.showLoading()
        
        viewModel.loadInitialArticles(onSuccess: { [weak self] data in
            guard let self else { return }
            self.dismissLoading()
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }, onError: { [weak self] error in
            guard let self else { return }
            self.handleLog(error: error)
            self.dismissLoading()
            self.showErrorAlert(message: "No se pudo cargar la información.", retryHandler: { [weak self] in
                guard let self else { return }
                self.getInitialData()
            })
        })
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        getInitialData()
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifier, for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        
        let article = viewModel.getItems()[indexPath.row]
        cell.configure(with: article)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle = viewModel.getItems()[indexPath.row]
        navigator?.goTo(.itemDetail(selectedArticle))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.getItems().count - 5 {
            let startIndex = self.viewModel.getItems().count
            let retryLoadMore = { [weak self] in
                guard let self = self else { return }
                self.loadMoreArticles()
            }
            
            viewModel.loadMoreArticles(onSuccess: { [weak self] data in
                guard let self = self else { return }
                let indexPaths = (startIndex..<(startIndex + data.count)).map {
                    IndexPath(row: $0, section: 0)
                }
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.handleLog(error: error)
                self.dismissLoading()
                self.showErrorAlert(message: "No se pudo cargar más información.", retryHandler: retryLoadMore)
            })
        }
    }
    
    private func loadMoreArticles() {
        let startIndex = self.viewModel.getItems().count
        viewModel.loadMoreArticles(onSuccess: { [weak self] data in
            guard let self = self else { return }
            let indexPaths = (startIndex..<(startIndex + data.count)).map {
                IndexPath(row: $0, section: 0)
            }
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        }, onError: { [weak self] error in
            guard let self = self else { return }
            self.handleLog(error: error)
            self.dismissLoading()
            self.showErrorAlert(message: "No se pudo cargar más información.", retryHandler: { [weak self] in
                self?.loadMoreArticles()
            })
        })
    }
}


extension HomeViewController: SearchBarComponentDelegate {
    func searchBarComponent(_ component: SearchBarComponent, didSearch text: String) {
        self.showLoading()
        let retrySearch = { [weak self] in
            guard let self = self else { return }
            self.searchBarComponent(component, didSearch: text)
        }
        viewModel.searchArticles(text: text, onSuccess: { [weak self] data in
            guard let self else { return }
            self.dismissLoading()
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }, onError: { [weak self] error in
            guard let self else { return }
            self.handleLog(error: error)
            self.dismissLoading()
            self.showErrorAlert(message: "No se pudo cargar la información.", retryHandler: retrySearch)
        })
    }
    
    func searchBarComponent(_ component: SearchBarComponent, didChangeText text: String) { }
}

extension HomeViewController {
    func showError() {
        showErrorAlert(message: "Algo salio mal", retryHandler: { [weak self] in
            guard let self else { return }
            getInitialData()
        })
    }
}

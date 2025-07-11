//
//  SplashViewController.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import UIKit

class SplashViewController: UIViewController, Navigable {
    var navigator: Navigator?
    var firstViewController: UIViewController?
    
    // MARK: - IBOutlets
    @IBOutlet weak var spaceShipGifView: GifImageView!
    
    private struct LocalConstants {
        static let gifName = "earthMoving"
        static let gifSpeedMultiplier: Double = 4
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupGifAnimation()
    }
    
    // MARK: - Setup
    private func setupGifAnimation() {
        spaceShipGifView.configureDelegate(self)
        spaceShipGifView.loadGif(named: LocalConstants.gifName, speedMultiplier: LocalConstants.gifSpeedMultiplier, looping: false)
    }

    private func configureNavigation() {
        let vm = HomeViewModel(datasource: HomeViewModelDataSource())
        self.firstViewController = HomeViewController(viewModel: vm)
        
        // Create Navigator and set First view controller
        if let navigationController = self.navigationController {
            self.navigator = Navigator(navigationController: navigationController)
            if let vc = self.firstViewController {
                self.navigator?.start(with: vc)
            }
        }
    }
}

extension SplashViewController: GifImageViewProtocol {
    func gifEnded() {
        guard let homeVC = firstViewController,
              let nav = navigator?.navigationController else { return }
        
        UIView.transition(with: nav.view, duration: 0.4, options: .transitionCrossDissolve, animations: {
            nav.setViewControllers([homeVC], animated: false)
        })
    }
}

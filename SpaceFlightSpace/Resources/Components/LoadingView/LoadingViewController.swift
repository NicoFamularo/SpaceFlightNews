//
//  LoadingViewController.swift
//  SpaceFlightSpace
//
//  Created by Nico on 10/07/2025.
//

import UIKit

class LoadingViewController: UIViewController, Navigable {
    var navigator: Navigator?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.fadeIn()
    }

    func closeWithFadeOut(completion: (() -> Void)? = nil) {
        self.view.fadeOut { [weak self] in
            self?.dismiss(animated: false, completion: completion)
        }
    }
}


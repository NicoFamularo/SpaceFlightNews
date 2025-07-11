//
//  UIViewController+Extensions.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import UIKit



// MARK: - Embed & Descale View Controllers

public extension UIViewController {
    func embedViewController(_ targetViewController: UIViewController?) {
        guard let viewController = targetViewController, viewController.parent != self else { return }
        viewController.view.alpha = 0
        viewController.view.frame = self.view.bounds
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        
        UIView.animate(withDuration: 0.3, animations: {
            viewController.view.alpha = 1
        }, completion: { _ in
            viewController.didMove(toParent: self)
        })
    }
}

// MARK: - Custom Navigation Bar

public extension Navigable where Self: UIViewController {
    
    /// Agrega una barra de navegación personalizada con botón de back
    /// - Parameters:
    ///   - title: Título a mostrar en la barra de navegación
    ///   - backgroundColor: Color de fondo de la barra (por defecto: systemBackground)
    ///   - titleColor: Color del título (por defecto: label)
    ///   - backButtonColor: Color del botón de back (por defecto: systemBlue)
    func addCustomNavigationBar(title: String? = nil, 
                               backgroundColor: UIColor = .systemBackground,
                               titleColor: UIColor = .label,
                               backButtonColor: UIColor = .systemBlue) {
        
        // Crear la vista contenedora de la barra de navegación
        let navBarView = UIView()
        navBarView.backgroundColor = backgroundColor
        navBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBarView)
        
        // Botón de back
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.setTitle(" Atrás", for: .normal)
        backButton.tintColor = backButtonColor
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        // Usar closure en lugar de selector
        backButton.addAction(UIAction { [weak self] _ in
            self?.navigator?.goBack()
        }, for: .touchUpInside)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        navBarView.addSubview(backButton)
        
        // Label del título (opcional)
        var titleLabel: UILabel?
        if let title = title {
            let label = UILabel()
            label.text = title
            label.textColor = titleColor
            label.font = UIFont.boldSystemFont(ofSize: 17)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            navBarView.addSubview(label)
            titleLabel = label
        }
        
        // Línea separadora inferior
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.separator
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        navBarView.addSubview(separatorLine)
        
        // Constraints
        NSLayoutConstraint.activate([
            // NavBar constraints
            navBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarView.heightAnchor.constraint(equalToConstant: 44),
            
            // Back button constraints
            backButton.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: navBarView.centerYAnchor),
            
            // Separator line constraints
            separatorLine.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: navBarView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        // Title label constraints (si existe)
        if let titleLabel = titleLabel {
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: navBarView.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: navBarView.centerYAnchor),
                titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: navBarView.trailingAnchor, constant: -16)
            ])
        }
    }
}

extension UIViewController {
    func showLoading() {
        let vc = LoadingViewController()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }

    func dismissLoading() {
        if let loadingVC = self.presentedViewController as? LoadingViewController {
            loadingVC.closeWithFadeOut()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    func showErrorAlert(message: String, retryHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Ups", message: message, preferredStyle: .alert)
        
        if let retryHandler = retryHandler {
            let retryAction = UIAlertAction(title: "Reintentar", style: .default) { _ in
                retryHandler()
            }
            alert.addAction(retryAction)
        }
        
        let closeAction = UIAlertAction(title: "Cerrar", style: .cancel, handler: nil)
        alert.addAction(closeAction)
        
        present(alert, animated: true)
    }
}

extension UIViewController {
    func handleLog(
        logLevel: LogLevel,
        data: String,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        let message = "[\(file):\(function):\(line)] \(data)"
        switch logLevel {
        case .info:
            Logger.shared.info(message)
        case .warning:
            Logger.shared.warning(message)
        case .error:
            Logger.shared.error(message)
        case .debug:
            Logger.shared.debug(message)
        }
    }
    
    func handleLog(
        error: Error,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        let message = "[\(file):\(function):\(line)] Error: \(error.localizedDescription)"
        Logger.shared.error(message)
    }
}

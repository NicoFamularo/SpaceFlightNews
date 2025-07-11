//
//  NavigatorProtocol.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import UIKit


// MARK: - Navigable ViewControllers

/// A protocol that makes view controllers capable of using the Navigator system.
/// Conforming view controllers can navigate between screens programmatically.
/// - Note: This protocol has a constraint requiring conforming types to be UIViewController subclasses.
public protocol Navigable where Self: UIViewController {
    /// The navigator instance responsible for handling navigation from this view controller.
    var navigator: Navigator? { get set }
}


// MARK: - Navigator

/// Defines the core navigation functionality that Navigator classes must implement.
/// This protocol establishes the basic contract for navigation management,
/// including the navigation controller reference and startup functionality.
protocol NavigatorProtocol {
    /// The navigation controller used for managing view controller stack.
    var navigationController: UINavigationController { get set }
    
    /// Starts navigation with the specified view controller as the initial screen.
    /// - Parameter viewController: The initial view controller to display.
    func start(with viewController: UIViewController)
}


open class Navigator: NavigatorProtocol {
    
    internal var superNavigator: Navigator? = nil
    internal var navigationController: UINavigationController
    internal var isNavigating: Bool = false
    
    /// Creates a new Navigator instance with the specified navigation controller.
    /// This is the primary initializer for the Navigator class, establishing
    /// the navigation controller that will be used for all navigation operations.
    /// - Parameter navigationController: The UINavigationController to be used for navigation.
    /// - Note: The navigator maintains a strong reference to the navigation controller.
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: Main Methods
    
    // MARK: Start
    
    open func start(with viewController: UIViewController) {
        if let navigableViewController = viewController as? Navigable {
            self.setNavigator(navigator: self, for: navigableViewController)
        }
    }
    
    internal func startNavigator(from navigable: Navigable) {
        if let navigationController = navigable.navigationController {
            let newNavigator = Navigator(navigationController: navigationController)
            newNavigator.superNavigator = self.superNavigator ?? self
            self.setNavigator(navigator: newNavigator, for: navigable)
        }
    }
    
    
    // MARK: Push
    
    open func push(viewController: Navigable, animated: Bool = true) {
        guard !self.isNavigating else {
            return
        }
        
        self.isNavigating = true
        
        DispatchQueue.main.async {
            if !viewController.isBeingPresented, !viewController.isBeingDismissed {
                self.doPush(viewController, animated: animated)
            }
        }
    }
    
    private func doPush(_ viewController: Navigable, animated: Bool = true) {
        self.setNavigator(navigator: self, for: viewController)
        self.navigationController.pushViewController(viewController, animated: animated)
        self.isNavigating = false
    }
    
    
    // MARK: Go Back
    
    open func goBack(animated: Bool = true) {
        DispatchQueue.main.async {
            self.navigationController.popViewController(animated: animated)
        }
    }
    
    open func goBackToRoot(animated: Bool = true) {
        DispatchQueue.main.async {
            (self.superNavigator ?? self).navigationController.popToRootViewController(animated: animated)
        }
    }
    
    open func canGoBack(to navigable: Navigable) -> Bool {
        return self.navigationController.viewControllers.contains(navigable) || (self.superNavigator ?? self).navigationController.viewControllers.contains(navigable)
    }
    
    open func goBack(to navigable: Navigable, animated: Bool = true) {
        if self.navigationController.viewControllers.contains(navigable) {
            self.popToViewController(navigable, animated: animated)
        } else if let superNavigator = self.superNavigator,  superNavigator.navigationController.viewControllers.contains(navigable) {
            DispatchQueue.main.async {
                superNavigator.navigationController.popToViewController(navigable, animated: animated)
            }
        }
    }
    
    open func goBack(toType navigable: UIViewController.Type, animated: Bool = true) {
    
        for viewController in self.navigationController.viewControllers {
            if navigable == type(of: viewController)  {
                self.popToViewController(viewController, animated: animated)
                return
            }
        }
        
        if let superNavigator = self.superNavigator {
            for viewController in superNavigator.navigationController.viewControllers {
                if navigable == type(of: viewController)  {
                    self.popToViewController(viewController, animated: animated)
                    return
                }
            }
        }
    }
    
    func popToViewController(_ viewController: UIViewController, animated: Bool) {
        DispatchQueue.main.async {
            self.navigationController.popToViewController(viewController, animated: animated)
        }
    }
    
    
    // MARK: - Present / Dismiss
    
    open func present(_ viewController: Navigable, animated: Bool = true, completion: (() -> Void)?) {
        DispatchQueue.main.async {
            if !viewController.isBeingPresented {
                if let topVC = self.navigationController.topViewController {
                    topVC.present(viewController, animated: animated, completion: completion)
                } else if let topVC = self.navigationController.visibleViewController {
                    topVC.present(viewController, animated: animated, completion: completion)
                }
            }
        }
    }
    
    
    // MARK: - Set Navigator for navigation structures
    
    fileprivate func setNavigator(navigator: Navigator, for viewController: Navigable) {
        viewController.navigator = navigator
        
        // Set Navigator for TabBar
        if let tabBarViewController = viewController as? UITabBarController {
            self.setTabBarNavigator(navigator: navigator, controller: tabBarViewController)
        }
        
        // Set Navigator for NavigationController
        if let navigationViewController = viewController as? UINavigationController {
            self.setNavigationControllerNavigator(navigator: navigator, controller: navigationViewController)
        }
    }
    
    // Set Navigator for TabBar
    fileprivate func setTabBarNavigator(navigator: Navigator, controller: UITabBarController) {
        if let viewControllers = controller.viewControllers {
            
            for viewController in viewControllers {
                if let navigableViewController = viewController as? Navigable {
                    navigableViewController.navigator = navigator
                } else if let navigationViewController = viewController as? UINavigationController {
                    self.setNavigationControllerNavigator(navigator: navigator, controller: navigationViewController)
                }
            }
        }
    }
    
    // Set Navigator for NavigationController
    fileprivate func setNavigationControllerNavigator(navigator: Navigator, controller: UINavigationController) {
        if let viewController = controller.topViewController {
            if let navigableViewController = viewController as? Navigable {
                navigableViewController.navigator = navigator
            }
        }
    }
}


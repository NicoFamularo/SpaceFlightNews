//
//  SkeletonizableViews.swift
//  SpaceFlightSpace
//
//  Created by Nico on 09/07/2025.
//

import UIKit

/// Protocol for views that can display skeleton loading animations.
/// This protocol provides a standardized way to show loading states
/// across different UI components in the application.
public protocol SkeletonizableView: UIView {
    /// Shows a skeleton loading animation on the view.
    /// The skeleton animation provides visual feedback to users
    /// while content is being loaded from the network.
    func showSkeleton()
    
    /// Hides the skeleton loading animation.
    /// This method should be called when the actual content
    /// is ready to be displayed to the user.
    func hideSkeleton()
}

// MARK: SkeletonView

public struct SkeletonAxis {
    let startPoint: CGPoint
    let endPoint: CGPoint
}

open class SkeletonView: UIView {
    public enum SkeletonConstants {
        public static var cornerRadius: CGFloat = 3.0
        public static var colorA: CGColor = UIColor(red: 240.0 / 255.0, green: 239.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0).cgColor
        public static var colorB: CGColor = UIColor(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0).cgColor
        public static var skeletonVerticalAxis = SkeletonAxis(startPoint: CGPoint(x: 0.0, y: 0.0), endPoint:  CGPoint(x: 0.0, y: 1.0))
        public static var skeletonHorizontalAxis = SkeletonAxis(startPoint: CGPoint(x: 0.0, y: 1.0), endPoint:  CGPoint(x: 1.0, y: 1.0))
    }
    
    public var originalCornerRadius: CGFloat = 0.0
    
    func addGradientLayer(axis: SkeletonAxis? = nil) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.name = "ShimmerLayer"
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = axis?.startPoint ?? SkeletonConstants.skeletonHorizontalAxis.startPoint
        gradientLayer.endPoint = axis?.endPoint ?? SkeletonConstants.skeletonHorizontalAxis.endPoint
        
        gradientLayer.colors = [SkeletonConstants.colorA, SkeletonConstants.colorB, SkeletonConstants.colorA]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        
        self.layer.addSublayer(gradientLayer)
        
        return gradientLayer
    }
    
    func addAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.5
        return animation
    }
    
    public func startAnimation(corners: UIRectCorner, cornerRadius: CGFloat? = nil, axis: SkeletonAxis? = nil) {
        let cornerRadius = cornerRadius ?? SkeletonConstants.cornerRadius
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let gradientLayer = self.addGradientLayer(axis: axis)
            gradientLayer.roundCorners(corners: corners, radius: cornerRadius)
            
            self.originalCornerRadius = self.layer.cornerRadius
            self.layer.roundCorners(corners: corners, radius: cornerRadius + 1)
            
            let animation = self.addAnimation()
            
            gradientLayer.add(animation, forKey: animation.keyPath)
        }
    }
    
    public func dismissAnimation(with duration: Double = 0.5) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: duration, animations: {
                self.layer.sublayers?
                    .filter { $0.name == "ShimmerLayer" }
                    .forEach { $0.opacity = 0.0 }
            }, completion: { _ in
                self.layer.sublayers?
                    .filter { $0.name == "ShimmerLayer" }
                    .forEach { $0.removeFromSuperlayer() }
                self.layer.cornerRadius = self.originalCornerRadius
            })
        }
    }
}

// MARK: UIView extension

public extension UIView {
    var skeletonViews: [SkeletonView] {
        subviews.compactMap { $0 as? SkeletonView }
    }
    
    func dismissSkeletonsView() {
        for case let skeleton as SkeletonView in self.subviews {
            skeleton.dismissAnimation()
            skeleton.removeFromSuperview()
        }
    }
    
    func createSkeleton(for view: UIView? = nil, corners: UIRectCorner = .allCorners, cornerRadius: CGFloat = 0.0, axis: SkeletonAxis? = nil) {
        let referenceView = view ?? self
        
        let skView = SkeletonView(frame: referenceView.frame)
        
        self.addSubViewPinningEdges(skView)
        
        skView.startAnimation(corners: corners, cornerRadius: cornerRadius, axis: axis)
    }
}

// MARK: UILabel extension

public extension UILabel {
    enum Constants {
        static var cornerRadius: CGFloat = 3.0
        static var heightSpacingLines: CGFloat = 6
        static var lastLineWithPercentage: CGFloat = 0.46
    }
    
    private func calculateRemainingSpace(forLines numberOfLines: Int, lineBlockHeight: CGFloat) -> CGFloat {
        return bounds.height - lineBlockHeight * CGFloat(numberOfLines) + Constants.heightSpacingLines
    }
    
    private func calculateMaxLines(lineBlockHeight: CGFloat) -> Int {
        self.layoutIfNeeded()
        
        var numberOfLines = self.numberOfLines
        
        if numberOfLines == 0 {
            let estimatedNumberLines = bounds.height / lineBlockHeight
            numberOfLines = Int(floor(estimatedNumberLines))
        }
        
        return numberOfLines
    }
}


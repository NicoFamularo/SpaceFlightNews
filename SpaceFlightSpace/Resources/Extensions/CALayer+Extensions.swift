//
//  CALayer+Extensions.swift
//  SpaceFlightSpace
//
//  Created by Nico on 10/07/2025.
//

import UIKit

public extension CALayer {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.mask = mask
     }
}

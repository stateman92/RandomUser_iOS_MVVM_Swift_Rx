//
//  UIView+Extensions.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 12..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Hides the `UIView` with the change of its `alpha` value.
    /// - Parameters:
    ///   - seconds: the duration of the animation (default `0.0`).
    ///   - completion: will be called after the animation ended.
    func hide(_ seconds: Double = 0.0, completion: @escaping () -> () = { }) {
        UIView.animate(withDuration: seconds, animations: {
            self.alpha = 0.0
        }) { success in
            completion()
        }
    }
    
    /// Shows the `UIView` with the change of its `alpha` value.
    /// - Parameters:
    ///   - seconds: the duration of the animation (default `0.0`).
    ///   - completion: will be called after the animation ended.
    func show(_ seconds: Double = 0.0, completion: @escaping () -> () = { }) {
        UIView.animate(withDuration: seconds, animations: {
            self.alpha = 1.0
        }) { success in
            completion()
        }
    }
}

//
//  UIActivityIndicatorView+Extensions.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 12..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {
    
    /// Configurate a basic `UIActivityIndicatorView`.
    func configure(withColor color: UIColor = .white, withStyle style: UIActivityIndicatorView.Style = .large) {
        self.color = color
        self.style = style
    }
}

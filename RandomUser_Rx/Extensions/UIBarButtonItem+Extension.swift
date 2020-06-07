//
//  UIBarButtonItem+Extension.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 12..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    /// Create a basic `UIBarButtonItem`.
    static func create(title: String = "", style: UIBarButtonItem.Style = .plain, target: Any? = nil, action: Selector? = nil, isEnabled: Bool = true, tintColor: UIColor = .white) -> UIBarButtonItem {
        let uiBarButtonItem = UIBarButtonItem(title: title, style: style, target: target, action: action)
        uiBarButtonItem.tintColor = tintColor
        uiBarButtonItem.isEnabled = isEnabled
        return uiBarButtonItem
    }
}

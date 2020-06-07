//
//  TopLevel+Extensions.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 31..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import Foundation

/// Run something on the main thread asynchronously after a given delay
func run(_ delay: Double = 0.0, onCompletion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        onCompletion()
    }
}

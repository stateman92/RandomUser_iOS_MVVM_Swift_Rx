//
//  UITableView+Extensions.swift
//  RandomUser
//
//  Created by Kálai Kristóf on 2020. 05. 12..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit

extension UITableView {
    
    /// Animates a `UITableView` (flows in from the bottom to the top).
    /// - Parameters:
    ///   - completion: will be called after the animation ended.
    func animateUITableView(completion: @escaping () -> () = { }) {
        reloadData()
        let tableViewHeight = bounds.size.height
        var delayCounter = 0
        let animationTime = 1.75
        visibleCells.forEach { (cell) in
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
            UIView.animate(withDuration: animationTime, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = .identity
            })
            delayCounter += 1
        }
        run(animationTime) {
            completion()
        }
    }
    
    /// Shows all the visible cells.
    func showCells() {
        visibleCells.forEach { cell in
            cell.show()
        }
    }
    
    /// A more convinient method to dequeue a cell.
    /// - Note:
    /// This should (and can) be used only if the identifier of the cell equals with the cell's class' name.
    func cell<T>(indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
    }
    
    /// A more convinient method to get a cell.
    /// - Note:
    /// This should (and can) be used only if the identifier of the cell equals with the cell's class' name.
    func cell<T>(at: IndexPath) -> T {
        return cellForRow(at: at) as! T
    }
}

//
//  UserDetailsViewController.swift
//  RandomUser_Rx
//
//  Created by Kálai Kristóf on 2020. 06. 06..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit
import SkeletonView
import Hero

// MARK: - The main ViewController base part.
class UserDetailsViewController: UIViewController {
    
    var user: User!
    private let imageService: ImageServiceProtocol = ImageServiceContainer().service
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userAccessibilitiesLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    private let animationDuration = 3.5
    private let animationStartDate = Date()
}

// MARK: - UIViewController lifecycle part.
extension UserDetailsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillLayoutWithData()
    }
}

// MARK: - Additional UI-related functions, methods.
extension UserDetailsViewController {
    
    private func fillLayoutWithData() {
        view.isSkeletonable = true
        userImageView.isSkeletonable = true
        
        userImageView.backgroundColor = .darkGray
        
        // The placeholder will be a SkeletonView, something like Facebook.
        let gradient = SkeletonGradient(baseColor: .darkGray)
        userImageView.showAnimatedGradientSkeleton(usingGradient: gradient, transition: .crossDissolve(1))
        
        imageService.load(url: user.picture.large, into: userImageView, withDelay: 2.0) { [weak self] in
            guard let self = self else { return }
            self.userImageView.hideSkeleton()
        }
        
        navigationItem.title = "\(user.fullName) (\(user.gender))"
        userImageView.hero.id = HeroIDs.imageEnlarging.rawValue
        userAccessibilitiesLabel.hero.id = HeroIDs.textEnlarging.rawValue
        
        CADisplayLink(target: self, selector: #selector(self.handleUpdate)).add(to: .main, forMode: .default)
    }
    
    @objc private func handleUpdate() {
        let arrayOfUILabels: [(UILabel, String)] =
            [(userAccessibilitiesLabel, user.accessibilities),
             (userLocationLabel, user.expandedLocation)]
        
        arrayOfUILabels.forEach { tuple in
            let fullString = tuple.1
            let uiLabel = tuple.0
            
            let now = Date()
            let elapsedTime = now.timeIntervalSince(animationStartDate)
            if elapsedTime > animationDuration {
                uiLabel.text = fullString
            } else {
                let percentage = elapsedTime / animationDuration
                let index = fullString.index(fullString.startIndex, offsetBy: Int(percentage * Double(fullString.count)))
                uiLabel.text = String(fullString[..<index])
            }
        }
    }
}

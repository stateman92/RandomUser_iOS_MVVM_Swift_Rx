//
//  Protocols.swift
//  RandomUser_Rx
//
//  Created by Kálai Kristóf on 2020. 06. 06..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import Foundation
import RxSwift

// MVVM architecture presents a one-direct data flow, so
// - View contains ViewModel,
// - ViewModel contains Model,
// and no other containment or any other communication are not allowed.
// MARK: - ViewModel needs to implement this.
protocol RandomUserViewModelProtocol {
    
    /// The incoming users.
    var users: BehaviorSubject<[User]> { get set }
    
    /// Whether the refresh spinner should shown or not.
    var showRefreshView: BehaviorSubject<Bool> { get set }
    
    /// Self-check, that actually distinct users are fetched.
    var numberOfDistinctNamedPeople: BehaviorSubject<Int> { get }
    
    /// Returns the so far fetched data + number of users in a page.
    var currentMaxUsers: BehaviorSubject<Int> { get }
    
    /// Fetch some random users.
    func getRandomUsers(refresh: Bool)
    
    /// Signs that the refresh animation ended.
    func endRefreshing()
}

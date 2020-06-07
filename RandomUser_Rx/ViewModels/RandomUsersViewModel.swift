//
//  RandomUsersViewModel.swift
//  RandomUser_Rx
//
//  Created by Kálai Kristóf on 2020. 06. 06..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import Foundation
import RxRelay
import RxSwift
import RxCocoa

class RandomUsersViewModel {
    
    /// The service that implements the HTTP communication.
    private var apiService: ApiServiceProtocol
    /// The service that implements the persistence layer.
    private var persistenceService: PersistenceServiceProtocol
    /// Returns the number of the next page.
    private var nextPage: Int {
        return usersArray.count / numberOfUsersPerPage + 1
    }
    /// Number of users that will be downloaded at the same time.
    private var numberOfUsersPerPage = 10
    /// The initial seed value. Changed after all refresh / restart.
    private var seed = UUID().uuidString
    /// The Rx framework's `DisposeBag` component.
    private let disposeBag = DisposeBag()
    /// If fetch is in progress, no more network request will be executed.
    private var isFetching = false
    /// The so far fetched user data.
    private var usersArray = [User]()
    
    /// The incoming users.
    var users = BehaviorSubject<[User]>.init(value: [User]())
    
    /// Whether the refresh spinner should shown or not.
    var showRefreshView = BehaviorSubject<Bool>.init(value: false)
    
    /// Self-check, that actually distinct users are fetched.
    var numberOfDistinctNamedPeople = BehaviorSubject<Int>.init(value: 0)
    
    /// Returns the so far fetched data + number of users in a page.
    var currentMaxUsers = BehaviorSubject<Int>.init(value: 10)
    
    /// Initialize the ApiService, setup the Rx, and get some user data.
    init() {
        apiService = AppDelegate.container.resolve(ApiServiceProtocol.self)!
        persistenceService = PersistenceServiceContainer().service
        users.subscribe(onNext: { [weak self] users in
                   guard let self = self else { return }
            self.numberOfDistinctNamedPeople.on(.next(Set(self.usersArray.map { user -> String in
                user.fullName
            }).count))
            self.currentMaxUsers.on(.next((self.nextPage + 1) * self.numberOfUsersPerPage))
        }).disposed(by: disposeBag)
        getCachedUsers()
    }
}

extension RandomUsersViewModel: RandomUserViewModelProtocol {
    
    /// Retrieve the previously cached users.
    private func getCachedUsers() {
        isFetching = true
        run(1.0) { [weak self] in
            guard let self = self else { return }
            let users = self.persistenceService.objects(UserObject.self)
            for user in users {
                self.usersArray.append(User(managedObject: user))
            }
            if users.count == 0 {
                self.isFetching = false
                self.getRandomUsers()
            } else {
                self.users.on(.next(self.usersArray))
            }
        }
    }
    
    /// Signs that the refresh animation ended.
    func endRefreshing() {
        isFetching = false
    }
    
    /// Fetch some random users.
    /// - Parameters:
    ///   - refresh: whether the user wants a full refresh or just more data.
    func getRandomUsers(refresh: Bool = false) {
        guard isFetching == false else { return }
        isFetching = true
        showRefreshView.on(.next(true))
        
        var delay = 0.0
        if refresh {
            seed = UUID().uuidString
            usersArray.removeAll()
            users.on(.next([User]()))
            delay = 0.33
        }

        run(delay) { [weak self] in
            guard let self = self else { return }
            self.apiService.getUsers(page: self.nextPage, results: self.numberOfUsersPerPage, seed: self.seed) { [weak self] result in
                guard let self = self else { return }
                if self.usersArray.count != 0 {
                    self.isFetching = false
                }
                self.showRefreshView.on(.next(false))
                switch result {
                case .success(let users):
                    self.usersArray.append(contentsOf: users)
                    if self.usersArray.count > self.numberOfUsersPerPage {
                        self.persistenceService.deleteAndAdd(UserObject.self, self.usersArray)
                    }
                    self.users.on(.next(self.usersArray))
                case .failure(let errorType):
                    self.users.on(.error(errorType))
                }
            }
        }
    }
}

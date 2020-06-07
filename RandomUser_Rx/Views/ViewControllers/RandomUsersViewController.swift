//
//  RandomUsersViewController.swift
//  RandomUser_Rx
//
//  Created by Kálai Kristóf on 2020. 06. 06..
//  Copyright © 2020. Kálai Kristóf. All rights reserved.
//

import UIKit
import Lottie
import RxSwift

// MARK: - The main View base part.
class RandomUsersViewController: UIViewController {
    
    /// MVVM architecture element.
    var randomUsersViewModel: RandomUserViewModelProtocol = RandomUsersViewModel()
    
    private var users = [User]()
    private var currentMaxUsers: Int = 10
    private let disposeBag = DisposeBag()
    private var numberOfDistinctNamedPeople: Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    /// Shows weather the initial users' data downloaded (or retrieved from cache).
    private var animationView = AnimationView(name: "loading")
    
    /// After the user claims that wants to refresh, the cells dissolves with this delay.
    /// After that the Presenter can start the refresh.
    private let refreshDelay = 0.33
    private var selectedRow: Int? = nil
    private let detailsSegue = "showDetailsSegue"
}

// MARK: - UIViewController lifecycle (and all that related to it) part.
extension RandomUsersViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackButtonOnNextVC()
        setupLeftBarButton()
        
        animationView.configure(on: view)
        setupTableViewAndRefreshing()
        
        navigationController?.hero.isEnabled = true
        
        setupRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.visibleCells.forEach { cell in
            if let cell = cell as? RandomUserTableViewCell {
                cell.userImage.hero.id = HeroIDs.defaultValue.rawValue
                cell.userName.hero.id = HeroIDs.defaultValue.rawValue
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// If the segue is the `detailsSegue`, then store the selected user in the destintion ViewController.
        if segue.identifier == detailsSegue,
            let selectedRow = selectedRow,
            let destinationViewController = segue.destination as? UserDetailsViewController {
            destinationViewController.user = users[selectedRow]
        }
    }
}

// MARK: - Rx part.
extension RandomUsersViewController {
    
    /// Setup the subscriptions to the 
    func setupRx() {
        
        randomUsersViewModel.users.subscribe(onNext: { [weak self] users in
            guard let self = self else { return }
            self.tableView.alpha = 1.0
            if users.count == 0 {
                self.users = users
                self.tableView.hide(1)
                self.animationView.show()
                self.animationView.play()
            } else {
                self.stopAnimating()
                if self.users.count == 0 {
                    self.users = users
                    self.tableView.show(1)
                    self.tableView.animateUITableView {
                        self.randomUsersViewModel.endRefreshing()
                    }
                } else {
                    self.users = users
                    self.tableView.reloadData()
                }
            }
            }, onError: { [weak self] error in
                guard let self = self else { return }
                let alert = UIAlertController(title: "Error", message: (error as? ErrorTypes)?.rawValue ?? "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
        }).disposed(by: disposeBag)
        
        randomUsersViewModel.currentMaxUsers.subscribe(onNext: { [weak self] currentMaxUsers in
            guard let self = self else { return }
            self.currentMaxUsers = currentMaxUsers
        }).disposed(by: disposeBag)
        
        randomUsersViewModel.showRefreshView.subscribe(onNext: { [weak self] showRefreshView in
            guard let self = self else { return }
            if !showRefreshView {
                self.refreshControl.endRefreshing()
            }
        }).disposed(by: disposeBag)
        
        randomUsersViewModel.numberOfDistinctNamedPeople.subscribe(onNext: { [weak self] numberOfDistinctNamedPeople in
            guard let self = self else { return }
            self.numberOfDistinctNamedPeople = numberOfDistinctNamedPeople
        }).disposed(by: disposeBag)
    }
}

// MARK: - UITableView functions part.
extension RandomUsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// If currently refreshing or downloads the initial users, show `0` cells. Otherwise show the `currentMaxUsers`.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        refreshUserCounter()
        return currentMaxUsers
    }
    
    /// If the cell is ready to be displayed, then display it, otherwise show a loading animation (with hidden content).
    /// - SeeAlso:
    /// `RandomUsersPresenter`'s `currentMaxUsers` variable.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RandomUserTableViewCell = tableView.cell(indexPath: indexPath)
        cell.initialize()
        if indexPath.row < users.count {
            cell.showContent()
            cell.configureData(withUser: users[indexPath.row])
        } else {
            cell.hideContent()
            randomUsersViewModel.getRandomUsers(refresh: false)
        }
        return cell
    }
    
    /// After the initial download (while the `animationView` is animating), refresh the data.
    @objc func tableViewPullToRefresh() {
        if !animationView.isAnimationPlaying {
            tableView.hide(0.33)
            randomUsersViewModel.getRandomUsers(refresh: true)
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    /// If possible, go to the first cell.
    @objc func tableViewGoToTop() {
        if tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    /// After a cell get selected, perform a segue and deselect the cell.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        let cell: RandomUserTableViewCell = tableView.cell(at: indexPath)
        cell.userImage.heroID = HeroIDs.imageEnlarging.rawValue
        cell.userName.heroID = HeroIDs.textEnlarging.rawValue
        performSegue(withIdentifier: detailsSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Additional UI-related functions, methods.
extension RandomUsersViewController {
    
    /// Get called only once, setup the delegates, `UIRefreshControl`, etc.
    private func setupBackButtonOnNextVC() {
        navigationItem.backBarButtonItem = UIBarButtonItem.create()
    }
    
    /// In the top left corner write out "Top", and when the user clicks on it, the `UITableView` must go to the top.
    private func setupLeftBarButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem
            .create(title: "Top", target: self, action: #selector(tableViewGoToTop))
    }
    
    /// In the top right corner write out the number of the currently downloaded distinct named users.
    private func refreshUserCounter() {
        let title = "Users: \(numberOfDistinctNamedPeople)"
        navigationItem.rightBarButtonItem = UIBarButtonItem
            .create(title: title, isEnabled: false)
    }
    
    /// Get called only once, setup the delegates, `UIRefreshControl`, etc.
    private func setupTableViewAndRefreshing() {
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(tableViewPullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func stopAnimating(completion: @escaping () -> () = { }) {
        refreshControl.endRefreshing()
        animationView.hide(1) { [weak self] in
            guard let self = self else { return }
            self.animationView.stop()
            completion()
        }
    }
}

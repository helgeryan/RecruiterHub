//
//  NotificationViewController.swift
//  Instagram
//
//  Created by Ryan Helgeson on 11/24/20.
//

import UIKit
import NotificationBannerSwift

enum UserNotificationType {
    case like(post: UserPost)
    case follow(state: FollowState)
}

public struct UserNotification {
    let type: UserNotificationType
    let text: String
    let user: RHUser
    let date: Date
}

final class NotificationViewController: UIViewController {
 
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.isHidden = false
        tableView.register(NotificationLikeEventTableViewCell.self, forCellReuseIdentifier: NotificationLikeEventTableViewCell.identifier)
        tableView.register(NotificationFollowEventTableViewCell.self, forCellReuseIdentifier: NotificationFollowEventTableViewCell.identifier)
        return tableView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.tintColor = .label
        return spinner
    }()
    
    private lazy var noNotificationsView = NoNotificationsView()

    private var models = [UserNotification]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNotifications()
        navigationItem.title = "Notifications"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        spinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner.center = view.center
    }
    
    private func fetchNotifications() {
        
        guard let user = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        DatabaseManager.shared.getUserNotifications(user: user, completion: { [weak self] notifications in
            
            guard let notifications = notifications else {
                print("Failed to get Notifications")
                return
            }
            let model = notifications[0]
            if model.date >= Date().addingTimeInterval(TimeInterval(-10)) {
                let banner = NotificationBanner(title: "\(model.text)", subtitle: nil, leftView: nil, rightView: nil, style: .info, colors: nil)
                
                banner.dismissOnTap = true
                banner.show()
            }
            
            DispatchQueue.main.async {
                self?.models = notifications
                self?.tableView.reloadData()
            }
            
        })
    }
    
    private func addNoNotificationsView() {
        tableView.isHidden = true
        view.addSubview(tableView)
        noNotificationsView.frame = CGRect(x: 0, y: 0, width: view.width/2, height: view.width/4)
        noNotificationsView.center = view.center
    }
    
}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {3
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        switch model.type {
        case .like(_):
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationLikeEventTableViewCell.identifier, for: indexPath) as! NotificationLikeEventTableViewCell
            cell.configure(with: model)
            cell.delegate = self
            return cell
        case .follow:
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationFollowEventTableViewCell.identifier, for: indexPath) as! NotificationFollowEventTableViewCell
            cell.configure(with: model)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}

extension NotificationViewController: NotificationLikeEventTableViewCellDelegate {
    func didTapRelatedPostButton(model: UserNotification) {
        print("Tapped Related Post. Type: \(model.type)")
        switch model.type {
        case .like(let post):
            DatabaseManager.shared.getUserPost(with: post.owner.safeEmail, url: post.postURL.absoluteString, completion: { [weak self] post in
                
                guard let post = post else {
                    print("Post is bad")
                    return
                }
                let vc = ViewPostViewController(post: post, user: post.owner, postNumber: post.identifier)
                self?.navigationController?.pushViewController(vc, animated: false)
            })
            break
        case .follow(_):
            fatalError("Dev Issue: Should never get called")
        }
    }
    
    func didTapProfilePic(model: UserNotification) {
        switch model.type {
        case .like(_):
            let vc = OtherUserViewController(user: model.user)
            navigationController?.pushViewController(vc, animated: false)
            break
        case .follow(_):
            let vc = OtherUserViewController(user: model.user)
            navigationController?.pushViewController(vc, animated: false)
            break
        }
    }
}

extension NotificationViewController: NotificationFollowEventTableViewCellDelegate {
    func didTapFollowUnfollowButton(model: UserNotification) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        DatabaseManager.shared.follow(email: model.user.safeEmail, followerEmail: email.safeDatabaseKey(), completion: {})
    }
    
   
}


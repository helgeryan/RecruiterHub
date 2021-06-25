//
//  ListsViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/31/21.
//

import UIKit

class ManageUsersViewController: UIViewController {

    private var data: [[String:String]]
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchUsersTableViewCell.self, forCellReuseIdentifier: SearchUsersTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - Init
    
    init(data: [[String:String]]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension ManageUsersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchUsersTableViewCell.identifier, for: indexPath) as! SearchUsersTableViewCell
        
        guard let email = data[indexPath.row]["email"] else {
            return cell
        }
        
        DatabaseManager.shared.getDataForUserSingleEvent(user: email.safeDatabaseKey(), completion: {
            user in
            guard let user = user else {
                return
            }
            
            cell.nameLabel.text = user.name
            cell.usernameLabel.text = user.username
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let email = data[indexPath.row]["email"] else {
            return
        }
        DatabaseManager.shared.getDataForUserSingleEvent(user: email.safeDatabaseKey(), completion: {
            [weak self] user in
            guard let user = user else {
                return
            }
            let vc = OtherUserViewController(user: user)
            vc.title = user.name
            self?.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //begin delete
            tableView.beginUpdates()
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            DatabaseManager.shared.deleteUser(index: indexPath.row, completion: {
                success in
                if !success {
                    print("Failed to delete")
                }
            })

            tableView.endUpdates()
        }
    }

}



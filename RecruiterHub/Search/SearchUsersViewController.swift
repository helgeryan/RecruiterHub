//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by Ryan Helgeson on 10/14/20.
//  Copyright © 2020 Ryan Helgeson. All rights reserved.
//

import UIKit

class SearchUserViewController: UIViewController {

    public var completion: ((SearchResult) -> (Void))?
    
    private var users = [[String: String]]()
    
    // Variable to store search results
    private var results = [SearchResult]()
    
    // Whether the table has fetched
    private var hasFetched = false
    
    // Initialize search bar
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Searching for Users.. "
        return searchBar
    }()
    
    // Initialize tableView
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(SearchUsersTableViewCell.self, forCellReuseIdentifier: SearchUsersTableViewCell.identifier)
       
        return table
    }()
    
    // Initialize the no results label
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No results.. "
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add search bar to the navigation bar
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        //
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Adv.", style: .plain, target: self, action: #selector(didTapAdvanced))
        
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: view.width,
                                 height: view.height - searchBar.height)
        noResultsLabel.frame = CGRect(x: view.width / 4, y: (view.height-200) / 2, width: view.width / 2, height: 200)
    }
    
    @objc private func didTapAdvanced() {
        let vc = AdvSearchUserViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension SearchUserViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            results.removeAll()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            tableView.isHidden = true
            noResultsLabel.isHidden = false
            return
        }
        
        noResultsLabel.isHidden = true
        tableView.isHidden = false

        results.removeAll()
        
        searchUsers(query: text)
    }
    
    private func searchUsers(query: String) {
        //Check if array has firebase result
        if hasFetched {
            //if it does: filter
            filterUsers(with: query)
        }
        else {
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.filterUsers(with: query)
                    break
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        results = []
        searchBar.text = ""
        searchBar.resignFirstResponder()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func filterUsers(with term: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            print("Failed to Filter")
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let results: [SearchResult] = users.filter( {
            guard let email = $0["email"], email != safeEmail,
                  let name = $0["name"]?.lowercased(),
                  let username = $0["username"]?.lowercased()  else {
                return false
            }
            
            return name.contains(term.lowercased()) || username.contains(term.lowercased())
        }).compactMap({
            guard let email = $0["email"], let name = $0["name"] else {
                return nil
            }
            
            return SearchResult(name: name, email: email)
        })
        self.results = results
        
        updateUI()
    }
    
    private func updateUI() {
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        }
        else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

struct SearchResult {
    let name: String
    let email: String
}

struct AdvSearchResult {
    let name: String
    let email: String
    let value: Double
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchUsersTableViewCell.identifier, for: indexPath) as! SearchUsersTableViewCell
        
        DatabaseManager.shared.getDataForUserSingleEvent(user: model.email.safeDatabaseKey(), completion: {
            user in
            guard let user = user else {
                return
            }
            cell.configure(user: user)
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Start Conversation
        let targetUserData  = results[indexPath.row]
        DatabaseManager.shared.getDataForUserSingleEvent(user: targetUserData.email.safeDatabaseKey(), completion: { [weak self] user in
            
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
}


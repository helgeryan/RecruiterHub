//
//  CoachProspectsViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 7/12/21.
//

import UIKit

public struct Prospect {
    let email: String
    let name: String
    let notes: [ProspectNote]
}

public struct ProspectNote {
    let date: Date
    let note: String
}

class CoachProspectsViewController: UIViewController {

    private var data: [Prospect] = []
    private let user: RHUser
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchUsersTableViewCell.self, forCellReuseIdentifier: SearchUsersTableViewCell.identifier)
        return tableView
    }()
    
    init(user: RHUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .done, target: self, action: #selector(didTapAdd))
        navigationItem.rightBarButtonItem = barButtonItem
        getProspects()
    }
    
    private func getProspects() {
        
        DatabaseManager.shared.getUserProspects(email: user.safeEmail, completion: { [weak self]
            prospects in
            
            guard let prospects = prospects else {
                self?.data = []
                self?.tableView.reloadData()
                return
            }
            
            self?.data = prospects
            self?.tableView.reloadData()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 100, width: view.width, height: view.height - view.safeAreaInsets.top - 100)
    }
    
    @objc private func didTapAdd() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            let prospect = Prospect(email: result.email, name: result.name, notes: [])
            DatabaseManager.shared.addProspect(with: strongSelf.user.safeEmail, prospect: prospect, completion: {
            })
            
            
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}

extension CoachProspectsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = data[indexPath.row]
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
        let model = data[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ProspectViewController(prospect: model)
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //begin delete
            let model = data[indexPath.row]
            let prospect = Prospect(email: model.email, name: model.name, notes: [])
            
            tableView.beginUpdates()
            data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            DatabaseManager.shared.deleteProspect(prospect: prospect, completion: {
                success in
                if !success {
                    print("Failed to delete")
                }
            })

            tableView.endUpdates()
        }
    }
}

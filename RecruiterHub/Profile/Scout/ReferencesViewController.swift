//
//  ReferencesViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 6/11/21.
//

import UIKit

class ReferencesViewController: UIViewController {
    
    private let user: RHUser
    
    private var references: [Reference] = []
    
    private let referencesTableView: UITableView = {
        let table = UITableView()
        table.register(ReferenceTableViewCell.self, forCellReuseIdentifier: ReferenceTableViewCell.identifier)
        table.separatorStyle = .singleLine
        return table
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
        title = "References"
        view.addSubview(referencesTableView)
        referencesTableView.dataSource = self
        referencesTableView.delegate = self
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if user.safeEmail == email {
            let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.square"), style: .done, target: self, action: #selector(didTapAddButton))
            barButtonItem.accessibilityLabel = "barButtonItem"
            navigationItem.rightBarButtonItem = barButtonItem
        }
        
        fetchReferences()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc private func didTapAddButton(){
        print("it's pressed")
        let vc = AddReferenceViewController()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        referencesTableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
    }
    
    private func fetchReferences(){
        print("Getting References")
        DatabaseManager.shared.getUserReferences(email: user.safeEmail, completion: { [weak self] references in
            guard let references = references else {
                return
            }
            
            self?.references = references
            
            DispatchQueue.main.async {
                self?.referencesTableView.reloadData()
            }
            
        })
    }
}

// MARK: - Table View Delegate and Data Source Methods

extension ReferencesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return references.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = references[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ReferenceTableViewCell.identifier, for: indexPath) as! ReferenceTableViewCell
        cell.configure(reference: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = references[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("selected row")
        
        DatabaseManager.shared.getDataForUserSingleEvent(user: model.safeEmail, completion: {
            [weak self] user in
            guard let user = user else {
                return
            }
            
            let vc = OtherUserViewController(user: user)
            self?.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //begin delete
            let reference = references[indexPath.row]
            tableView.beginUpdates()
            references.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            DatabaseManager.shared.deleteReference(reference: reference, completion: {
                success in
                if !success {
                    print("Failed to delete")
                }
            })

            tableView.endUpdates()
        }
    }
}

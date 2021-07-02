//
//  ContactInformationViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/15/21.
//

import UIKit

public struct ContactInfoModel {
    let label: String
    let value: String
}

class ContactInformationViewController: UIViewController {

    private let user: RHUser
    
    private var models: [ContactInfoModel] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.layer.masksToBounds = true
        table.register(ContactInfoCell.self, forCellReuseIdentifier: ContactInfoCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    init(user: RHUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.title = "\(user.firstName) \(user.lastName)"
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureModels() {
        var model = ContactInfoModel(label: "Name", value: "\(user.firstName) \(user.lastName)")
        models.append(model)
        model = ContactInfoModel(label: "Username", value: "\(user.username)")
        models.append(model)
        model = ContactInfoModel(label: "Phone", value: "\(user.phone)")
        models.append(model)
        model = ContactInfoModel(label: "School", value: "\(user.school)")
        models.append(model)
        
        if user.profileType == "coach" {
            // Do nothing
        }
        else {
            model = ContactInfoModel(label: "State", value: "\(user.state)")
            models.append(model)
            model = ContactInfoModel(label: "GPA", value: "\(user.gpa)")
            models.append(model)
        }
        tableView.reloadData()
    }
}

extension ContactInformationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactInfoCell.identifier, for: indexPath) as! ContactInfoCell
        cell.configure(with: models[indexPath.row])
        return cell
    }
}

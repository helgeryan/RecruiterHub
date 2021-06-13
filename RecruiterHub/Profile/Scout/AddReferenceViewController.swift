//
//  AddReferenceViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 6/11/21.
//

import UIKit

class AddReferenceViewController: UIViewController {

    private var models = [EditProfileFormModel]()

    private var reference = Reference(emailAddress: "", phone: "", name: "")
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        return tableView
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        tableView.dataSource = self
        view.addSubview(tableView)
        title = "Add Reference"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapGesture)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func configureModels() {
        var model = EditProfileFormModel(label: "Name", placeholder: "First Last", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Phone", placeholder: "###-###-####", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Email", placeholder: "name@gmail.com", value: nil)
        models.append(model)
    }
    
    @objc private func didTap() {
        tableView.frame = view.bounds
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else {
            return nil
        }
        return "Reference Info"
    }
    
    // MARK: -Action
    
    @objc private func didTapSave() {
        print("Tapped Save")
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print(reference)
        guard reference.name != "",
              reference.phone != "",
              reference.emailAddress != "" else {
            let alert = UIAlertController(title: "Failed to add refrence", message: "One or more fields may be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            print("Failed to save user")
            return
        }
        
        print("Adding References")
        DatabaseManager.shared.addReferenceForUser(email: email.safeDatabaseKey(), reference: reference)

        navigationController?.popViewController(animated: true)
    }
}

// MARK: - TableViewDelegate and TableViewDataSource Methods

extension AddReferenceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier, for: indexPath) as! FormTableViewCell
        cell.configure(with: model)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

}

// MARK: - FormTableViewCellDelegate Methods

extension AddReferenceViewController: FormTableViewCellDelegate {
    func formTableViewCell(_ cell: FormTableViewCell) {
        if tableView.top < view.top {
            return
        }
        
        if cell.center.y > (view.height / 2) {
            tableView.frame = CGRect(x: tableView.left, y: tableView.top - (view.height / 2), width: tableView.width, height: tableView.height)
        }
    }

    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel) {
        
        guard let value = updatedModel.value else {
            return
        }
        switch updatedModel.label {
        case "Name":
            reference.name = value
            break
        case "Phone":
            reference.phone = value
            break
        case "Email":
            reference.emailAddress = value.lowercased()
            break
        default:
            print("Field doesn't exist")
            break
        }
        //Update the mdoel
        print(updatedModel.value ?? "nil")
    }
}


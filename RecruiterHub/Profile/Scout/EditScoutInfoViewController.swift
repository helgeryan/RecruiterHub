//
//  EditScoutInfoViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 3/7/21.
//

import UIKit

class EditScoutInfoViewController: UIViewController {

    private var models = [EditProfileFormModel]()
    
    private var scoutInfo: ScoutInfo
    
    private var data: Data?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        return tableView
    }()
    
    init(scoutInfo: ScoutInfo) {
        self.scoutInfo = scoutInfo
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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
    }
    
    private func configureModels() {
        // name, username, website, bio
        var model = EditProfileFormModel(label: "Fastball", placeholder: "\(scoutInfo.fastball)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Curveball", placeholder: "\(scoutInfo.curveball)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Slider", placeholder: "\(scoutInfo.slider)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Changeup", placeholder: "\(scoutInfo.changeup)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "60", placeholder: "\(scoutInfo.sixty)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Infield", placeholder: "\(scoutInfo.infield)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Outfield", placeholder: "\(scoutInfo.outfield)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Exit Velo", placeholder: "\(scoutInfo.exitVelo)", value: nil)
        models.append(model)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else {
            return nil
        }
        return "Scout Info"
    }
    
    // MARK: -Action
    @objc private func didTap() {
        tableView.frame = view.bounds
        view.endEditing(true)
    }
    
    @objc private func didTapSave() {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        DatabaseManager.shared.updateScoutInfoForUser(email: email, scoutInfo: scoutInfo)
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TableView

extension EditScoutInfoViewController: UITableViewDataSource {
    
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

extension EditScoutInfoViewController: FormTableViewCellDelegate {
    func formTableViewCell(_ cell: FormTableViewCell) {
        if tableView.top < view.top {
            return
        }
        
        if cell.center.y > (view.height / 2) {
            tableView.frame = CGRect(x: tableView.left, y: tableView.top - (view.height / 2), width: tableView.width, height: tableView.height)
        }
    }
    
    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel) {
        
        tableView.frame = view.bounds
        guard let value = updatedModel.value else {
            return
        }
        switch updatedModel.label {
        case "Fastball":
            scoutInfo.fastball = Double(value) ?? 0
            break
        case "Curveball":
            scoutInfo.curveball = Double(value) ?? 0
            break
        case "Slider":
            scoutInfo.slider = Double(value) ?? 0
            break
        case "Changeup":
            scoutInfo.changeup = Double(value) ?? 0
            break
        case "60":
            scoutInfo.sixty = Double(value) ?? 0
            break
        case "Infield":
            scoutInfo.infield = Double(value) ?? 0
            break
        case "Outfield":
            scoutInfo.outfield = Double(value) ?? 0
            break
        case "Exit Velo":
            scoutInfo.exitVelo = Double(value) ?? 0
            break
        default:
            print("Field doesn't exist")
            break
        }
        
        //Update the mdoel
        print(updatedModel.value ?? "nil")
    }
}

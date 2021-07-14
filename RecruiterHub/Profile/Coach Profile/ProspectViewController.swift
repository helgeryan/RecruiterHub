//
//  ProspectViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 7/12/21.
//

import UIKit

class ProspectViewController: UIViewController {

    private var prospect: Prospect
    private var prospectUser: RHUser = RHUser()
    private let index: Int
    
    private let profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        imageView.layer.borderWidth = 5
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let yearPositionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let schoolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let handLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configure()
        addSubviews()
        tableView.delegate = self
        tableView.dataSource = self
        listenForUpdates()
    }
    
    init(prospect: Prospect, index: Int) {
        self.prospect = prospect
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let profilePhotoSize = view.width/3
        profilePhotoImageView.frame = CGRect(x: profilePhotoSize,
                                             y: 5,
                                             width: profilePhotoSize,
                                             height: profilePhotoSize).integral
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.width / 4.0
        
        nameLabel.frame = CGRect(x: 10,
                                 y: profilePhotoImageView.bottom + 5,
                                 width: view.width - 20 ,
                                 height: 20)
        nameLabel.textAlignment = .center
        yearPositionLabel.frame = CGRect(x: 10,
                                     y: nameLabel.bottom + 5,
                                     width: view.width - 20,
                                     height: 20)
        yearPositionLabel.textAlignment = .center
        bodyLabel.frame = CGRect(x: 10,
                                 y: yearPositionLabel.bottom + 5,
                                 width: view.width - 20,
                                 height: 20)
        bodyLabel.textAlignment = .center
        schoolLabel.frame = CGRect(x: 10,
                                 y: bodyLabel.bottom + 5,
                                 width: view.width - 20,
                                 height: 20)
        schoolLabel.textAlignment = .center
        
        handLabel.frame = CGRect(x: 10,
                                 y: schoolLabel.bottom + 5,
                                 width: view.width - 20,
                                 height: 20)
        handLabel.textAlignment = .center
        
        tableView.frame = CGRect(x: 0, y: handLabel.bottom + 10, width: view.width, height: view.height - handLabel.bottom - 10)
        
    }
    
    private func addSubviews() {
        view.addSubview(profilePhotoImageView)
        view.addSubview(nameLabel)
        view.addSubview(yearPositionLabel)
        view.addSubview(schoolLabel)
        view.addSubview(bodyLabel)
        view.addSubview(handLabel)
        view.addSubview(tableView)
    }
    
    private func configure() {
        DatabaseManager.shared.getDataForUserSingleEvent(user: prospect.email.safeDatabaseKey(), completion: { [weak self] user in
            
            guard let user = user else {
                return
            }
            self?.prospectUser = user
            
            self?.nameLabel.text = user.firstName + " " + user.lastName
            self?.schoolLabel.text = "School: \(user.school)"
            
            let heightFeet = user.heightFeet
            let heightInches = user.heightInches
            let weight = user.weight
            let arm = user.arm
            let bats = user.bats
            self?.bodyLabel.text = String(heightFeet) + "'" + String(heightInches) + "  "  + String(weight) + " lbs"
            self?.handLabel.text = "Throws: " + String(arm) + "   Bats: " + String(bats)

            self?.yearPositionLabel.text = "Year: \(user.gradYear)   Pos: \(user.positions)"
            if let url = URL(string: user.profilePicUrl) {
                self?.profilePhotoImageView.sd_setImage(with: url, completed: nil)
            }
        })
    }
    
    private func listenForUpdates() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        DatabaseManager.shared.getProspectInfo(email: email, index: index, completion: {
            [weak self] prospect in
            
            guard let prospect = prospect else {
                return
            }
            
            self?.prospect = prospect
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
    }
    
    private func didTapAdd() {
        let alert = UIAlertController(title: "Add Note", message: "Add a note to a prospect", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            textfield in
            textfield.placeholder = "Note.."
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in 
            
        }))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let email = UserDefaults.standard.value(forKey: "email") as? String,
                  let note = alert.textFields?[0].text else {
                return
            }
            DatabaseManager.shared.newProspectNote(email: email, prospectNote: note, index: self.index)
        }))
        present(alert, animated: true, completion: nil)
    }
}
extension ProspectViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prospect.notes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == prospect.notes.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = "+ Prospect Note"
            return cell
        }
        let model = prospect.notes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = ChatViewController.dateFormatter.string(from: model.date) + "\n\n\(model.note)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if prospect.notes.count == indexPath.row {
            return 30
        }
        let model = prospect.notes[indexPath.row]
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: view.width - 20 , height: 10))
        label.text = ChatViewController.dateFormatter.string(from: model.date) + "\n\n\(model.note)"
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = false
        label.preferredMaxLayoutWidth = view.width - 20
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label.height + 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == prospect.notes.count {
            didTapAdd()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //begin delete
            let model = prospect.notes[indexPath.row]
            
            tableView.beginUpdates()
            prospect.notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            DatabaseManager.shared.deleteProspectNote(prospectNote: model, index: index, completion: {
                success in
                if !success {
                    print("Failed to delete")
                }
            })

            tableView.endUpdates()
        }
    }
}

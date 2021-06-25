//
//  SettingsViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 1/26/21.
//

import SafariServices
import UIKit

struct SettingCellModel {
    let title:String
    let handler:(() -> Void)
}

class SettingsViewController: UIViewController {

    private let user: RHUser
    
    private let table:UITableView = {
        let tableView = UITableView (frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var data = [[SettingCellModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        view.backgroundColor = .systemBackground
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    init(user: RHUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    private func configureModels() {
        data.append([
            SettingCellModel(title: "Edit Profile") { [weak self] in
                self?.didTapEditProfile()
            },
            SettingCellModel(title: "Invite Friends") { [weak self] in
                self?.didTapInviteFriends()
            },
            SettingCellModel(title: "Manage Posts") { [weak self] in
                self?.didTapManagePosts()
            }
        ])

        data.append([
            SettingCellModel(title: "Terms of Service") { [weak self] in
                self?.openURL(type: .terms)
            },
            SettingCellModel(title: "Privacy Policy") { [weak self] in
                self?.openURL(type: .privacy)
            },
            SettingCellModel(title: "Help / Feedback") { [weak self] in
                self?.openURL(type: .help)
            }
        ])
        
        data.append([
            SettingCellModel(title: "Log Out") { [weak self] in
                self?.didTapLogOut()
            }
        ])
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if "ryanhelgeson14-gmail-com" == email {
            data.append([
                SettingCellModel(title: "Manage Users") { [weak self] in
                    self?.didTapManageUsers()
                }
            ])
            return
        }
    }
    
    private func didTapEditProfile() {
        let vc = EditProfileViewController(user: user)
        vc.title = "Edit Profile"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func didTapInviteFriends() {
        
    }
    
    private func didTapManageUsers() {
        DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
            switch result {
            case .success(let userCollection):
                let vc = ManageUsersViewController(data: userCollection)
                self?.navigationController?.pushViewController(vc, animated: true)
                break
            case .failure(let error):
                print("Failed to get users: \(error)")
            }
        })
    }
    
    private func didTapManagePosts() {
        let vc = ManagePostsViewController(user: user)
        vc.title = "Manage Posts"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    enum SettingsURLType {
        case terms, privacy, help
    }
    
    private func openURL(type: SettingsURLType) {
        let document: String
        switch type {
            case .terms:
                document = "Terms and Conditions.pdf"
                break
            case .privacy:
                document = "Privacy Policy.pdf"
                break
            case .help:
                document = "Help.pdf"
                break
        }
        
        StorageManager.shared.downloadURL(for: document, completion: { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let url):
                let vc = SFSafariViewController(url: url)
                self?.present(vc, animated: true)
                break
            }
        })
    }
    
    private func didTapLogOut() {
        let actionSheet = UIAlertController(title: "Log Out",
                                            message: "Are you sure you want to log out?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            AuthManager.shared.logout( completion: { success in
                DispatchQueue.main.async {
                    if success {
                        // present log in
                        let loginVc = LoginViewController()
                        loginVc.modalPresentationStyle = .fullScreen
                        self.present(loginVc, animated: true) {
                            self.navigationController?.popToRootViewController(animated: false)
                            self.tabBarController?.selectedIndex = 0
                        }
                        UserDefaults.standard.setValue("", forKey: "email")
                    }
                    else {
                        // Error Occurred
                        fatalError("Could not log out user")
                    }
                }
                
            })
        }))
        
        actionSheet.popoverPresentationController?.sourceView = table
        actionSheet.popoverPresentationController?.sourceRect = table.bounds
        
        present(actionSheet, animated: true, completion: nil)

    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.section][indexPath.row].handler()
    }
    
}

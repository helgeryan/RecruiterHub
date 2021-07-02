//
//  EditProfileViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/1/21.
//

import UIKit
import SDWebImage
import NotificationBannerSwift

struct EditProfileFormModel {
    let label: String
    let placeholder: String
    var value: String?
}

final class EditProfileViewController: UIViewController {

    private var models = [EditProfileFormModel]()
    
    private var user: RHUser
    
    private var data: Data?
    
    private var image = UIImage()
    
    private let profilePicButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.layer.masksToBounds = true
        button.tintColor = .label
        button.addTarget(self,
                                     action: #selector(didTapChangeProfilePicture),
                                     for: .touchUpInside)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
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
        view.backgroundColor = .systemBackground
        
        configureModels()
        tableView.dataSource = self
        view.addSubview(profilePicButton)
        view.addSubview(tableView)
        
        guard let url = URL(string: user.profilePicUrl) else {
            return
        }
        
        profilePicButton.sd_setImage(with: url, for: .normal, completed: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapGesture)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tableView.tableHeaderView = createTableHeaderView()
    }
    
    private func configureModels() {
        
        // name, username, website, bio
        var model = EditProfileFormModel(label: "Name", placeholder: "\(user.firstName) \(user.lastName)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Phone", placeholder: "\(user.phone)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "School", placeholder: "\(user.school)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "State", placeholder: "\(user.state)", value: nil)
        models.append(model)
        
        if user.profileType == "coach" {
            model = EditProfileFormModel(label: "Title", placeholder: "\(user.title)", value: nil)
            models.append(model)
        }
        else {
            model = EditProfileFormModel(label: "Grad Year", placeholder: "\(user.gradYear)", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Height Feet", placeholder: "\(user.heightFeet)", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Height Inches", placeholder: "\(user.heightInches)", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Weight", placeholder: "\(user.weight)", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Arm", placeholder: "\(user.arm)", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Bats", placeholder: "\(user.bats)", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "GPA", placeholder: "\(user.gpa)", value: nil)
            models.append(model)
            model = EditProfileFormModel(label: "Positions", placeholder: "ex. RHP, CF, 1B", value: nil)
            models.append(model)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profilePicButton.frame = CGRect(x: view.width / 3, y: view.safeAreaInsets.top + 20, width: view.width / 3, height: view.width / 3)
        profilePicButton.layer.cornerRadius = profilePicButton.height / 2
        tableView.frame = CGRect(x: 0, y: profilePicButton.bottom + 20, width: view.width, height: view.height - profilePicButton.bottom - 40)
    }
    
    @objc private func didTap() {
        tableView.frame = view.bounds
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else {
            return nil
        }
        return "Private Information"
    }
    
    private func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    /// Presents the photo library to select a photo
    private func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    // MARK: -Action
    
    @objc private func didTapSave() {
        // Save info to database
        
        if let data = data {
            let fileName = user.emailAddress.safeDatabaseKey()
            
            StorageManager.shared.uploadProfilePic(with: data, email: fileName, completion: { [weak self] result in
                switch result {
                case .success(let urlString):
                    DatabaseManager.shared.setProfilePic(with: fileName, url: urlString)
                    
                    guard let user = self?.user else {
                        return
                    }
                
                    DatabaseManager.shared.updateUserInfor(user: user)
                    
                    self?.navigationController?.popViewController(animated: true)
                    let banner = NotificationBanner(title: "Successfully updated profile!", subtitle: nil, leftView: nil, rightView: nil, style: .success, colors: nil)
                    
                    banner.dismissOnTap = true
                    banner.show()
                case .failure(let error):
                    let banner = NotificationBanner(title: "Failed to update profile. Could not upload profile picture.", subtitle: nil, leftView: nil, rightView: nil, style: .danger, colors: nil)
                    
                    banner.dismissOnTap = true
                    banner.show()
                    print(error)
                }
            })
        }
        else {
            print("Data is nil")
            DatabaseManager.shared.updateUserInfor(user: user)
            
            navigationController?.popViewController(animated: true)
            let banner = NotificationBanner(title: "Successfully updated profile!", subtitle: nil, leftView: nil, rightView: nil, style: .success, colors: nil)
            
            banner.dismissOnTap = true
            banner.show()
        }
    }
    
    @objc private func didTapChangeProfilePicture() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "Change Profile Picture",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        
        present(actionSheet, animated: true)
    }

}

// MARK: - TableView

extension EditProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func createTableHeaderView() -> UIView {
        let header = UIView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: view.width,
                                          height: view.height/4).integral)
        let size = header.height/1.5
        let profilePhotoButton = UIButton(frame: CGRect(x: (view.width-size)/2,
                                                        y: (header.height-size)/2,
                                                        width: size,
                                                        height: size))
        header.addSubview(profilePhotoButton)
        profilePhotoButton.layer.masksToBounds = true
        profilePhotoButton.layer.cornerRadius = size/2.0
        profilePhotoButton.tintColor = .label
        profilePhotoButton.addTarget(self,
                                     action: #selector(didTapChangeProfilePicture),
                                     for: .touchUpInside)
        profilePhotoButton.layer.borderWidth = 1
        profilePhotoButton.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        
        guard let url = URL(string: user.profilePicUrl) else {
            return header
        }
        
        profilePhotoButton.sd_setImage(with: url, for: .normal, completed: nil)
        
        return header
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

extension EditProfileViewController: FormTableViewCellDelegate {
    func formTableViewCell(_ cell: FormTableViewCell) {
        if tableView.top < view.top {
            tableView.frame = view.bounds
            return
        }
        
        if (tableView.top + cell.center.y) > (view.height / 2) {
            tableView.frame = CGRect(x: tableView.left, y: tableView.top - (view.height / 2), width: tableView.width, height: tableView.height)
        }
    }
    
    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel) {
//        tableView.frame = view.bounds
        guard let value = updatedModel.value else {
            return
        }
        switch updatedModel.label {
        case "Name":
            let names = value.split(separator: " ")
            if names.count == 2 {
                user.firstName = String((names[0]))
                user.lastName = String((names[1]))
            }
            break
        case "Phone":
            user.phone = value
            break
        case "High School":
            user.school = value
            break
        case "State":
            user.state = value
            break
        case "Grad Year":
            user.gradYear = Int(value) ?? 0
            break
        case "Height Feet":
            user.heightFeet = Int(value) ?? 0
            break
        case "Height Inches":
            user.heightInches = Int(value) ?? 0
            break
        case "Weight":
            user.weight = Int(value) ?? 0
            break
        case "Arm":
            user.arm = value
            break
        case "Bats":
            user.bats = value
            break
        case "Positions":
            user.positions = value
            break
        case "Title":
            user.title = value
            break
        default:
            print("Field doesn't exist")
            break
        }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        profilePicButton.setImage(selectedImage, for: .normal)
        
        data = selectedImage.pngData()
    }
}

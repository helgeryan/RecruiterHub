//
//  EditProfileViewController.swift
//  RecruiterHub
//
//  Created by Ryan Helgeson on 2/1/21.
//

import UIKit
import SDWebImage

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
        tableView.tableHeaderView = createTableHeaderView()
        configureModels()
        tableView.dataSource = self
        view.addSubview(tableView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableHeaderView = createTableHeaderView()
    }
    
    private func configureModels() {
        
        // name, username, website, bio
        var model = EditProfileFormModel(label: "Name", placeholder: "\(user.firstName) \(user.lastName)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Username", placeholder: "\(user.username)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "Phone", placeholder: "N/A", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "High School", placeholder: "\(user.highSchool)", value: nil)
        models.append(model)
        model = EditProfileFormModel(label: "State", placeholder: "\(user.state)", value: nil)
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
        model = EditProfileFormModel(label: "GPA", placeholder: "\(user.bats)", value: nil)
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
            
            StorageManager.shared.uploadProfilePic(with: data, filename: fileName, completion: { result in
                switch result {
                case .success(let urlString):
                    DatabaseManager.shared.setProfilePic(with: fileName, url: urlString)
                case .failure(let error):
                    print(error)
                }
            })
        }
        else {
            print("Data is nil")
        }
    
        DatabaseManager.shared.updateUserInfor(user: user)
        
        dismiss(animated: true, completion: nil)
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
        
        guard let url = URL(string: user.profilePicUrl) else {
            return header
        }
        
        profilePhotoButton.sd_setImage(with: url, for: .normal, completed: nil)
        profilePhotoButton.layer.borderWidth = 1
        profilePhotoButton.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        
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
    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel) {
        
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
        case "Username":
            user.username = value
            break
        case "Phone":
            user.phone = value
            break
        case "High School":
            user.highSchool = value
            break
        case "State":
            user.state = value
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
        default:
            print("Field doesn't exist")
            break
        }
        
        //Update the mdoel
        print(updatedModel.value ?? "nil")
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        data = selectedImage.pngData()
    }
}

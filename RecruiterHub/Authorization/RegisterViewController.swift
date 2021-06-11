//
//  RegisterViewController.swift
//  Instagram
//
//  Created by Ryan Helgeson on 11/24/20.
//

import UIKit

class RegisterViewController: UIViewController {

    struct Constants {
        static let cornerRadius:CGFloat = 8.0
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email Address..."
        textField.returnKeyType = .next
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let usernameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username..."
        textField.returnKeyType = .next
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let firstNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Firstname..."
        textField.returnKeyType = .next
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let lastNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Lastname..."
        textField.returnKeyType = .next
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password..."
        textField.returnKeyType = .continue
        textField.leftViewMode = .always
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.isSecureTextEntry = true
        textField.backgroundColor = .secondarySystemBackground
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0) )
        textField.leftViewMode = .always
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return textField
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = .systemGreen
        return button
    }()
    
    private let imageBackgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LaunchScreen")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .done, target: self, action: #selector(didTapBack))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapGesture)
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        view.addSubview(imageBackgroundView)
        view.addSubview(imageView)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(registerButton)
        view.addSubview(lastNameField)
        view.addSubview(firstNameField)
        
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageBackgroundView.frame = view.bounds
        imageView.frame = CGRect(x: view.width/3, y: view.top + 130, width: view.width/3, height: view.width/3)
        imageView.layer.cornerRadius = imageView.width/2
        
        firstNameField.frame = CGRect(x: 20,
                                     y: imageView.bottom + 10,
                                     width: view.width - 40,
                                     height: 52)
        lastNameField.frame = CGRect(x: 20,
                                     y: firstNameField.bottom + 10,
                                     width: view.width - 40,
                                     height: 52)
        usernameField.frame = CGRect(x: 20,
                                     y: lastNameField.bottom + 10,
                                     width: view.width - 40,
                                     height: 52)
        emailField.frame = CGRect(x: 20,
                                  y: usernameField.bottom + 10,
                                  width: view.width - 40,
                                  height: 52)
        passwordField.frame = CGRect(x: 20,
                                     y: emailField.bottom + 10,
                                     width: view.width - 40,
                                     height: 52)

        registerButton.frame = CGRect(x: 20,
                                      y: passwordField.bottom + 10,
                                      width: view.width - 40,
                                      height: 52)
    }
    
    /// Handles a general tap on the view
    @objc private func didTap() {
        view.endEditing(true)
    }
    
    /// Handles a profile image button
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if firstNameField.isFirstResponder || lastNameField.isFirstResponder || usernameField.isFirstResponder  {
            return
        }
        Keyboard.keyboardWillShow(vc: self, notification: notification)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        Keyboard.keyboardWillHide(vc: self)
    }
    
    private func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        } ) )
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    /// Presents the camera to take a photo
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
    
    @objc func didTapRegisterButton() {
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        usernameField.resignFirstResponder()
        
        guard let email = emailField.text, !email.isEmpty,
              let firstname = firstNameField.text, !firstname.isEmpty,
              let lastname = lastNameField.text, !lastname.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8,
              let username = usernameField.text, !username.isEmpty else {
            return
        }
        
        var user = RHUser()
        user.username = username
        user.firstName = firstname
        user.lastName = lastname
        user.emailAddress = email
        user.highSchool = "High School"
        user.state = "State"
        user.arm = "R"
        user.bats = "R"
        
        AuthManager.shared.registerNewUser(username: username, email: email, password: password, user: user) { [weak self] registered in
            if registered {
                // Good to go
                guard let data = self?.imageView.image?.pngData() else {
                    return
                }
                
                let fileName = DatabaseManager.safeEmail(emailAddress: email)
                    
                StorageManager.shared.uploadProfilePic(with: data, filename: fileName, completion: { [weak self] result in
                    switch result {
                    case .success(let urlString):
                        DatabaseManager.shared.setProfilePic(with: email, url: urlString)
                    case .failure(let error):
                        print(error)
                    }
                    
                    self?.dismiss(animated: true, completion: nil)
                    
                    UserDefaults.standard.setValue(email.safeDatabaseKey(), forKey: "email")
                    UserDefaults.standard.setValue(user.username, forKey: "username")
                    UserDefaults.standard.setValue("\(user.firstName) \(user.lastName)", forKey: "name")
                    UserDefaults.standard.setValue("Yes", forKey: "isLoggedIn")
                    
                })
            }
            else {
                // Failed
            }
        }
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            didTapRegisterButton()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resignFirstResponder()
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        imageView.image = selectedImage
    }
}

//
//  RegisterViewController.swift
//  Instagram
//
//  Created by Ryan Helgeson on 11/24/20.
//

import UIKit
import JGProgressHUD

class RegisterViewController: UIViewController {

    struct Constants {
        static let cornerRadius:CGFloat = 8.0
    }
    
    private let profileTypes = ["player", "coach"]
    
    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD(automaticStyle: ())
        
        return spinner
    }()
    
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
    
    private let profileType: UIPickerView = {
        let spinner = UIPickerView(frame: .zero)
        spinner.backgroundColor = .lightGray
        spinner.layer.cornerRadius = Constants.cornerRadius
        return spinner
    }()
    
    private let imageBackgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LaunchScreen")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Left Bar Button Item
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .done, target: self, action: #selector(didTapBack))
        
        // Add Keyboard Observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Add Register Buttons
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        view.addGestureRecognizer(tapGesture)
        
        // Add Image Views
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        imageView.addGestureRecognizer(gesture)
        
        // Add Delegates and Data Sources
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        profileType.delegate = self
        profileType.dataSource = self
        
        // Add Subviews
        view.addSubview(imageBackgroundView)
        view.addSubview(imageView)
        view.addSubview(usernameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(registerButton)
        view.addSubview(lastNameField)
        view.addSubview(firstNameField)
        view.addSubview(profileType)
        view.addSubview(spinner)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        spinner.dismiss()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageBackgroundView.frame = view.bounds
        imageView.frame = CGRect(x: view.width/3, y: view.safeAreaInsets.top + 10, width: view.width/3, height: view.width/3)
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
        profileType.frame = CGRect(x: 20,
                                  y: emailField.bottom + 10,
                                  width: view.width - 40,
                                  height: 52)
        passwordField.frame = CGRect(x: 20,
                                     y: profileType.bottom + 10,
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
        
        // Resign First Responders
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        usernameField.resignFirstResponder()
        
        spinner.show(in: view)
        
        // Check to make sure the fields are not empty or invalid
        guard let email = emailField.text?.lowercased(), !email.isEmpty,
              let firstname = firstNameField.text, !firstname.isEmpty,
              let lastname = lastNameField.text, !lastname.isEmpty,
              let password = passwordField.text, !password.isEmpty, password.count >= 8,
              let username = usernameField.text, !username.isEmpty, !username.contains(" ")
              else {
            spinner.dismiss()
            alertUserRegisterError(message: "Make sure fields aren't empty and/or username contains no spaces. Passwords must be 8 or more characters in length.")
            return
        }
        
        var user = RHUser()
        user.username = username
        user.firstName = firstname
        user.lastName = lastname
        user.emailAddress = email
        user.positions = ""
        user.school = "School"
        user.state = "State"
        user.arm = "R"
        user.bats = "R"
        user.profileType = profileTypes[profileType.selectedRow(inComponent: 0)]
        
        AuthManager.shared.registerNewUser(username: username, email: email, password: password, user: user) { [weak self] registered in
            if registered {
                // Good to go
                guard let data = self?.imageView.image?.pngData() else {
                    self?.spinner.dismiss()
                    return
                }
                
                let fileName = email.safeDatabaseKey()
                    
                StorageManager.shared.uploadProfilePic(with: data, email: fileName, completion: { [weak self] result in
                    switch result {
                    case .success(let urlString):
                        DatabaseManager.shared.setProfilePic(with: email, url: urlString)
                    case .failure(let error):
                        print(error)
                    }
                    
                    self?.spinner.dismiss()
                    self?.dismiss(animated: true, completion: nil)
                    
                    UserDefaults.standard.setValue(email.safeDatabaseKey(), forKey: "email")
                    UserDefaults.standard.setValue(user.username, forKey: "username")
                    UserDefaults.standard.setValue("\(user.firstName) \(user.lastName)", forKey: "name")
                })
            }
            else {
                // Failed
                self?.spinner.dismiss()
                self?.alertUserRegisterError(message: "Email or username already in use or connection lost.")
            }
        }
    }
    
    @objc private func didTapBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func alertUserRegisterError(message: String) {
        let alert = UIAlertController(title: "Failed to Register", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
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

extension RegisterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return profileTypes[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        2
    }
}

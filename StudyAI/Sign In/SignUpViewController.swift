//
//  SignUpViewController.swift
//  Waited
//
//  Created by Anthony Fasano on 12/14/20.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var eightCharacters: UILabel!
    @IBOutlet weak var numberPass: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var specialCharacter: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        eightCharacters.isHidden = true
        numberPass.isHidden = true
        specialCharacter.isHidden = true
        
        errorLabel.alpha = 0
        
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        
        Utilities.styleFillButton(signUpButton)
        Utilities.styleTextField(firstNameTextField, color: nil)
        Utilities.styleTextField(lastNameTextField, color: nil)
        Utilities.styleTextField(emailTextField, color: nil)
        Utilities.styleTextField(passwordTextField, color: nil)
        Utilities.styleTextField(confirmPasswordTextField, color: nil)
    }
    
    //clean password and make sure the two passwords are equal. Want to add a feature with a checkmark to know that the passwords match
    func validateFields() -> String? {
        // Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||    confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields"
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPasswordConfirmed = confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        

        
        if Utilities.isPasswordValid(cleanedPassword) == false{
            return "Please type in a more secure password add at least 8 characters, a number, and a special character"
        }
        
        if cleanedPassword.elementsEqual(cleanedPasswordConfirmed){
            return nil
        }
        
        else {
            return "passwords do not match"
        }
    }
    
    @IBAction func signUpOnTapped(_ sender: Any) {
        let error = validateFields()
        
        let indicator = Indicator()
        
        indicator.showIndicator()
        if error != nil {
            //there is an error, show error message
            indicator.hideIndicator {
                self.showError(error!)
            }
            
        }
        else{
            // Create cleaned version of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                //check for erros
                
                if err != nil {
                    //there was an error if inside this loop
                    indicator.hideIndicator {
                        self.showError("Error creating user")
                    }

                }
                else{
                    let db = Firestore.firestore()
                    let fireBaseUser = result?.user
                    

                    _  = User.init(id: fireBaseUser?.uid ?? "", firstName: firstName, lastName: lastName, email: email)
                    
                    //I want to document id and the UID to be the same because its just easier
                    let newUserRef =  db.collection("users").document(result!.user.uid)
                    newUserRef.setData(["firstName": firstName,
                                        "lastName": lastName,
                                        "email": email,
                                        "uid": result!.user.uid,
                                        "stripeID": "",
                                        "subscribed":0,
                                        "tokensRemaining":0,
                                        "tokensMonthly":0,
                                        "receivedTokens":false
                                       ]) { (error) in
                        if error != nil {
                            //show error message
                            indicator.hideIndicator {
                                self.showError("User data didn't save to database")
                            }
                        }
                        else {
                            result?.user.sendEmailVerification { err in
                                if let err = err {
                                    indicator.hideIndicator {
                                        let cancel = UIAlertAction(title: "OK", style: .cancel){ (action) in
                                            
                                        }
                                        
                                        let ac1 = UIAlertController(title: "Error: Could not send Verification Email Sent", message: "Please have one resent in User Settings to recieve free 50,000 tokens.", preferredStyle: .alert)
                                        ac1.addAction(cancel)
                                        self.present(ac1, animated: true)
                                    }
                                }
                                else {
                                    indicator.hideIndicator {
                                        let cancel = UIAlertAction(title: "OK", style: .cancel){ (action) in
                                            
                                        }
                                        
                                        let ac1 = UIAlertController(title: "Verification Email Sent", message: "Recieve free 50,000 tokens by verifying your email.", preferredStyle: .alert)
                                        ac1.addAction(cancel)
                                        self.present(ac1, animated: true)
                                    }
                                }
                            }
                        }
                    }
                    indicator.hideIndicator {
                        UserService.getCurrentUser()
                        UserService.getCurrentUserSetRoot(x: self.view.center.x, y: self.view.center.y)
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField == firstNameTextField {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.becomeFirstResponder()
      }
      else if textField == lastNameTextField {
        lastNameTextField.resignFirstResponder()
        emailTextField.becomeFirstResponder()
      }
      else if textField == emailTextField {
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
      }
      else if textField == passwordTextField {
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.becomeFirstResponder()
      }
      else if textField == confirmPasswordTextField {
        confirmPasswordTextField.resignFirstResponder()
      }
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if textField == confirmPasswordTextField ||  textField == passwordTextField{
            eightCharacters.isHidden = true
            numberPass.isHidden = true
            specialCharacter.isHidden = true
        }
        
        if textField == confirmPasswordTextField ||  textField == passwordTextField{
            if Utilities.isPasswordValid(password) {
                Utilities.styleTextField(passwordTextField, color: UIColor(red: 0, green: 1, blue: 0, alpha: 1))

                if password.elementsEqual(confirmPassword ) {
                        Utilities.styleTextField(confirmPasswordTextField, color: UIColor(red: 0, green: 1, blue: 0, alpha: 1))
                        
                }
                else {
                    Utilities.styleTextField(confirmPasswordTextField, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))

                }
            }
            else {
                Utilities.styleTextField(confirmPasswordTextField, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
                Utilities.styleTextField(passwordTextField, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))

            }
        }
      }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if textField == confirmPasswordTextField ||  textField == passwordTextField{
            if Utilities.isPasswordValid(password) {
                Utilities.styleTextField(passwordTextField, color: UIColor(red: 0, green: 1, blue: 0, alpha: 1))

                if password.elementsEqual(confirmPassword) {
                        Utilities.styleTextField(confirmPasswordTextField, color: UIColor(red: 0, green: 1, blue: 0, alpha: 1))
                        
                }
                else {
                    Utilities.styleTextField(confirmPasswordTextField, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))

                }
            }
            let decimalCharacters = CharacterSet.decimalDigits
            let decimalRange = password.rangeOfCharacter(from: decimalCharacters)
            let specialCharactersCheck = CharacterSet(charactersIn: "$@$#!%*?&")
            
            let specialRange = password.rangeOfCharacter(from: specialCharactersCheck)
            specialCharacter.textColor = .systemRed
            eightCharacters.textColor = .systemRed
            numberPass.textColor = .systemRed

            
            if (specialRange != nil){
                specialCharacter.textColor = .systemGreen
            }
            if password.count > 7 {
                eightCharacters.textColor = .systemGreen
            }
            if (decimalRange != nil) {
                numberPass.textColor = .systemGreen
            }
            
            else {
                Utilities.styleTextField(confirmPasswordTextField, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
                Utilities.styleTextField(passwordTextField, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))

            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordTextField{
            eightCharacters.isHidden = false
            numberPass.isHidden = false
            specialCharacter.isHidden = false
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let decimalCharacters = CharacterSet.decimalDigits
            let decimalRange = password.rangeOfCharacter(from: decimalCharacters)
            let specialCharactersCheck = CharacterSet(charactersIn: "$@$#!%*?&")
            
            let specialRange = password.rangeOfCharacter(from: specialCharactersCheck)
            specialCharacter.textColor = .systemRed
            eightCharacters.textColor = .systemRed
            numberPass.textColor = .systemRed

            
            if (specialRange != nil){
                specialCharacter.textColor = .systemGreen
            }
            if password.count > 7 {
                eightCharacters.textColor = .systemGreen
            }
            if (decimalRange != nil) {
                numberPass.textColor = .systemGreen
            }
                
            
            
        }
        
    }
    
    func chan (_ textField: UITextField) {
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let confirmPassword = confirmPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        if textField == confirmPasswordTextField ||  textField == passwordTextField{
            if Utilities.isPasswordValid(password) {
                Utilities.styleTextField(passwordTextField, color: UIColor(red: 0, green: 1, blue: 0, alpha: 1))

                if password.elementsEqual(confirmPassword ) {
                        Utilities.styleTextField(confirmPasswordTextField, color: UIColor(red: 0, green: 1, blue: 0, alpha: 1))
                        
                }
                else {
                    Utilities.styleTextField(confirmPasswordTextField, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))

                }
            }
            else {
                Utilities.styleTextField(confirmPasswordTextField, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))
                Utilities.styleTextField(passwordTextField, color: UIColor(red: 1, green: 0, blue: 0, alpha: 1))

            }
        }
      }
    
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    //transitioning to the tabVC for the normal home view controller
    func transitionToHome(){
       let homeViewController = storyboard?.instantiateViewController(identifier: "MainVC")
        if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 15, minorVersion: 0, patchVersion: 0)) {
            UIApplication
                .shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first {
                    $0.rootViewController = homeViewController
                    $0.makeKeyAndVisible()
                    return true
                }
        }
        else {
            UIApplication.shared.windows.first?.rootViewController = homeViewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }

    }
    

}

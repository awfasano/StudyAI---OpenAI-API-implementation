//
//  LoginViewController.swift
//  Waited
//
//  Created by Anthony Fasano on 12/14/20.
//
import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self

        errorLabel.alpha = 0
        Utilities.styleHollowButton(loginButton)
        Utilities.styleTextField(emailTextField, color: nil)
        Utilities.styleTextField(passwordTextField, color: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField == emailTextField {
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
      }
      else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
      }
        return true
    }
    
    @IBAction func forgtoButtonOnTap(_ sender: Any) {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

        let indicator = Indicator()
        indicator.showIndicator()
        
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            if let err = err {
                indicator.hideIndicator {
                    self.errorLabel.text = err.localizedDescription
                    self.errorLabel.alpha = 1
                }
            }
            else {
                indicator.hideIndicator {
                    
                    let alertController = UIAlertController(title: "Reset Password Email Sent", message: "Please check your email for a resent link", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default)
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func loginOnTap(_ sender: Any) {
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        let indicator = Indicator()
        indicator.showIndicator()
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                indicator.hideIndicator {
                    self.errorLabel.text = error!.localizedDescription
                    self.errorLabel.alpha = 1
                }
            }
            else{
                
                let db = Firestore.firestore()
                
                let ref = db.collection("users").document(result?.user.uid ?? "")
                
                ref.getDocument { snapshot, err in
                    if let err = err {
                        self.errorLabel.text = err.localizedDescription
                        self.errorLabel.alpha = 1
                    }
                    else {
                        indicator.hideIndicator {
                            UserService.getCurrentUser()
                            UserService.getCurrentUserSetRoot(x: self.view.center.x, y: self.view.center.y)
                        }
                    }
                }
            }
        }
    }
    
    func transitionToHome(){

       let homeViewController = storyboard?.instantiateViewController(identifier: "MainVC")
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()

    }

    
    
}
//https://studyai-a9aaf.firebaseapp.com/__/auth/handler
//aidcademy17514dahdah

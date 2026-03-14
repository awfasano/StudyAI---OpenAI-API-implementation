//
//  LoginViewController.swift
//  Waited
//
//  Created by Anthony Fasano on 12/14/20.
//
import UIKit
import FirebaseAuth
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let formCard = UIView()
    private let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        emailTextField.delegate = self
        passwordTextField.delegate = self

        errorLabel.alpha = 0
        Utilities.styleFillButton(loginButton)
        Utilities.styleLinkButton(forgotButton)
        Utilities.styleTextField(emailTextField, color: nil)
        Utilities.styleTextField(passwordTextField, color: nil)
        configureChrome()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let top = max(view.safeAreaInsets.top + 24, emailTextField.frame.minY - 92)
        let height = passwordTextField.frame.maxY - top + 110
        formCard.frame = CGRect(x: 18, y: top, width: view.bounds.width - 36, height: height)
        titleLabel.frame = CGRect(x: formCard.frame.minX + 24, y: formCard.frame.minY + 20, width: formCard.frame.width - 48, height: 36)
        view.sendSubviewToBack(formCard)
    }

    private func configureChrome() {
        AIcademyTheme.styleSurface(formCard)
        view.insertSubview(formCard, at: 1)
        AIcademyTheme.styleTitle(titleLabel, size: 30)
        titleLabel.text = "Welcome back"
        view.addSubview(titleLabel)
        errorLabel.textColor = AIcademyTheme.magenta
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
        guard let emailText = emailTextField.text, !emailText.isEmpty else {
            self.errorLabel.text = "Please enter your email address."
            self.errorLabel.alpha = 1
            return
        }
        let email = emailText.trimmingCharacters(in: .whitespacesAndNewlines)

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
        guard let emailText = emailTextField.text, let passText = passwordTextField.text,
              !emailText.isEmpty, !passText.isEmpty else {
            self.errorLabel.text = "Please enter email and password."
            self.errorLabel.alpha = 1
            return
        }
        let email = emailText.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passText.trimmingCharacters(in: .whitespacesAndNewlines)

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

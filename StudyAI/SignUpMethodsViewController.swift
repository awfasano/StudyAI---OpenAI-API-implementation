//
//  SignUpMethodsViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 8/18/23.
//

import UIKit
import FBSDKLoginKit

class SignUpMethodsViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let loginButton = FBLoginButton()
        loginButton.permissions = ["public_profile", "email"]


        let signUpWithEmail = UIButton()
        
        Utilities.styleFillButton(signUpWithEmail)
        
        view.center = loginButton.center
        
        view.center.x = signUpWithEmail.center.x
        
        stackView.addSubview(loginButton)
        stackView.addSubview(signUpWithEmail)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

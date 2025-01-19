//
//  FirstViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 5/10/23.
//

import UIKit

class FirstViewController: UIViewController {
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var signUp: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utilities.styleFillButton(signUp)
        Utilities.styleHollowButton(signIn)
        UserService.getCurrentUser()
        UserService.getCurrentUserSetRoot(x: view.center.x, y: view.center.y)
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

    @IBAction func signUpOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toSignUpMethods", sender: self)
    }
    
    

    @IBAction func logIn(_ sender: Any) {
        performSegue(withIdentifier: "toSignIn", sender: self)
    }
    
}

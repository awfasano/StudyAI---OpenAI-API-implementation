//
//  ViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/14/23.
//

import UIKit

class ViewInitialController: UIViewController {
    
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var signUp: UIButton!
    
    @IBOutlet weak var signIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logInOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toSignIn", sender: self)
    }
    @IBAction func signUpOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
}


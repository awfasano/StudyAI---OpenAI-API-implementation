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
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        Utilities.styleFillButton(signUp)
        Utilities.styleHollowButton(signIn)
        Utilities.applyHeroImage(logo)
        AIcademyTheme.styleTitle(titleLabel, size: 32)
        titleLabel.text = "Meet Carlisle"
        titleLabel.textAlignment = .center
        subtitleLabel.text = "Turn any topic into bright, interactive study material."
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.textColor = AIcademyTheme.ink.withAlphaComponent(0.78)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.frame = CGRect(x: 28, y: logo.frame.maxY + 12, width: view.bounds.width - 56, height: 44)
        subtitleLabel.frame = CGRect(x: 34, y: titleLabel.frame.maxY + 6, width: view.bounds.width - 68, height: 48)
    }
    
    @IBAction func logInOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toSignIn", sender: self)
    }
    @IBAction func signUpOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
}

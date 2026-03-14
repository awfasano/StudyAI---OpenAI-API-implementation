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
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        Utilities.styleFillButton(signUp)
        Utilities.styleHollowButton(signIn)
        Utilities.applyHeroImage(logo)
        configureCopy()
        UserService.getCurrentUser()
        UserService.getCurrentUserSetRoot(x: view.center.x, y: view.center.y)
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.frame = CGRect(x: 28, y: logo.frame.maxY + 12, width: view.bounds.width - 56, height: 48)
        subtitleLabel.frame = CGRect(x: 32, y: titleLabel.frame.maxY + 4, width: view.bounds.width - 64, height: 54)
    }

    private func configureCopy() {
        AIcademyTheme.styleTitle(titleLabel, size: 34)
        titleLabel.textAlignment = .center
        titleLabel.text = "Study Smarter"

        subtitleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = AIcademyTheme.ink.withAlphaComponent(0.78)
        subtitleLabel.text = "Build quizzes, flashcards, and explanations with Carlisle."

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
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
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
    
    

    @IBAction func logIn(_ sender: Any) {
        performSegue(withIdentifier: "toSignIn", sender: self)
    }
    
}

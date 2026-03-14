//
//  ProfileViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/28/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, reloadUserDelegate {
    private let profileHeaderTag = 8_701
    private let profilePlanPillTag = 8_702
    private var planSummary = "Plan: Free"

    private func buildSettings() -> [String: [String]] {
        ["User Settings":[
            "Change First Name: \(UserService.user.firstName)",
            "Change Last Name: \(UserService.user.lastName)",
            "Update Email Address: \(UserService.user.email)",
            "Verify Email Address",
            "Change Password",
            "Delete Account",
            planSummary,
            "Support: anthony@aicademy.us"
        ]]
    }
    
    func reload() {
        settings = buildSettings()
        refreshPlanSummary()
        tableView.reloadData()
    }
    

    lazy var settings = buildSettings()
    let settingsKeys = ["User Settings"]

    
    var userServ:_UserService?

    @IBOutlet weak var email: UITextView!
    @IBOutlet weak var phone: UITextView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        view.backgroundColor = .clear
        userServ = UserService
        userServ?.delegate = self
        
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(self.logOutUser))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        installProfileHeaderIfNeeded()
        refreshPlanSummary()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshPlanSummary()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = AIcademyTheme.surface
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.borderWidth = 2
        cell.contentView.layer.borderColor = AIcademyTheme.border.cgColor
        cell.contentView.layer.masksToBounds = true
        
        if indexPath.row == 6 {
            let setting = planSummary
            var config = UIListContentConfiguration.cell()
            config.text = setting
            config.textProperties.color = AIcademyTheme.ink
            config.textProperties.font = .systemFont(ofSize: 16, weight: .bold)
            //config.secondaryText = ""
            cell.contentConfiguration = config
            cell.isUserInteractionEnabled = false
            cell.accessoryType = .none
            return cell
        }
       else if indexPath.row == 3 {
           if Auth.auth().currentUser?.isEmailVerified ?? false {
               let setting = "Email is already Verified"
               var config = UIListContentConfiguration.cell()
               config.text = setting
               config.textProperties.color = AIcademyTheme.ink
               cell.isUserInteractionEnabled = false
               cell.accessoryType = .checkmark

               //config.secondaryText = ""
               cell.contentConfiguration = config
               return cell
           }
           else {

               let setting = "Verify Email Address"
               var config = UIListContentConfiguration.cell()
               config.text = setting
               config.textProperties.color = AIcademyTheme.ink
               //config.secondaryText = ""
               cell.contentConfiguration = config
               return cell
           }
        }
        
        else{
            guard let setting = settings[settingsKeys[indexPath.section]]?[indexPath.row] else{

                return cell
            }
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .none
            var config = UIListContentConfiguration.cell()
            config.text = setting
            config.textProperties.color = AIcademyTheme.ink
            config.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
            //config.secondaryText = ""
            cell.contentConfiguration = config

        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[settingsKeys[section]]?.count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys = Array(settings.keys)
        return keys[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        header.textLabel?.frame = header.bounds
        header.textLabel?.textAlignment = .left
        header.textLabel?.textColor = AIcademyTheme.ink
        header.tintColor = .clear
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        54
    }

    private func installProfileHeaderIfNeeded() {
        guard tableView.tableHeaderView?.tag != profileHeaderTag else { return }

        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 196))
        header.tag = profileHeaderTag
        header.backgroundColor = .clear

        let card = UIView(frame: CGRect(x: 20, y: 12, width: header.bounds.width - 40, height: 168))
        AIcademyTheme.styleSurface(card, tint: AIcademyTheme.magenta)
        card.autoresizingMask = [.flexibleWidth]

        let avatar = UIImageView(frame: CGRect(x: 18, y: 18, width: 84, height: 84))
        Utilities.applyHeroImage(avatar)
        card.addSubview(avatar)

        let title = UILabel(frame: CGRect(x: 118, y: 28, width: card.bounds.width - 136, height: 32))
        title.autoresizingMask = [.flexibleWidth]
        title.text = "\(UserService.user.firstName) \(UserService.user.lastName)"
        AIcademyTheme.styleTitle(title, size: 26)
        card.addSubview(title)

        let subtitle = UILabel(frame: CGRect(x: 118, y: 64, width: card.bounds.width - 136, height: 50))
        subtitle.autoresizingMask = [.flexibleWidth]
        subtitle.numberOfLines = 0
        subtitle.text = "Manage your account, verify your email, and keep your study access ready for the next Carlisle session."
        AIcademyTheme.styleSubtitle(subtitle, size: 14)
        card.addSubview(subtitle)

        let pill = UILabel(frame: CGRect(x: 18, y: 120, width: card.bounds.width - 36, height: 30))
        pill.tag = profilePlanPillTag
        pill.autoresizingMask = [.flexibleWidth]
        pill.text = " \(planSummary) "
        pill.font = .systemFont(ofSize: 13, weight: .bold)
        pill.textColor = AIcademyTheme.ink
        pill.backgroundColor = AIcademyTheme.yellow.withAlphaComponent(0.28)
        pill.layer.cornerRadius = 15
        pill.clipsToBounds = true
        pill.textAlignment = .center
        card.addSubview(pill)

        header.addSubview(card)
        tableView.tableHeaderView = header
    }

    private func refreshPlanSummary() {
        IAPManager.shared.getSubscriptionStatus { isPremium in
            DispatchQueue.main.async {
                self.planSummary = isPremium ? "Plan: Premium Active" : "Plan: Free"
                self.settings = self.buildSettings()
                self.tableView.reloadData()
                if let pill = self.tableView.tableHeaderView?.viewWithTag(self.profilePlanPillTag) as? UILabel {
                    pill.text = " \(self.planSummary) "
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row{
            case 0:
                promptForAnswer(fieldUpdating: "First Name", field: "firstName")
          
            case 1:
                promptForAnswer(fieldUpdating: "Last Name", field: "lastName")

            case 2:
               
                promptForAnswerWithPassword(fieldUpdating: "Email", field: "email", type: "email", title: "Update your Email")


            case 3:

                
                promptForAnswerWithPassword(fieldUpdating: "Verify", field: "email", type: "verify", title: "Send Verification Email")

            
            case 4:
                promptForAnswerWithPassword(fieldUpdating: "Password", field: "password", type: "password", title: "Reset Password")

            case 5:
                
                promptForAnswerWithPassword(fieldUpdating: "Password", field: "password", type: "delete", title: "Enter Email and Password to Delete your Account")
                
            default:
                break
            }
        }
    }
    
    func deleteAccount() {
        let indicator = Indicator()
        indicator.showIndicator()
        Auth.auth().currentUser?.delete { err in
            if let err = err {
                self.displayAlertviewController(title: "Error", msg: "Was unable to delete your account.  Please check your internet connection and try again")
            }
            else {
                let cancel = UIAlertAction(title: "OK", style: .cancel){ (action) in
                    let story = UIStoryboard(name: "Main", bundle:nil)
                    let vc = story.instantiateViewController(withIdentifier: "FirstVC")
                }
                let ac1 = UIAlertController(title: "Success", message: "Your account was successfully deleted.", preferredStyle: .alert)
                ac1.addAction(cancel)
                self.present(ac1, animated: true)
            }
        }
    }
    
    @objc func logOutUser(){
        UserService.userListener?.remove()

        let indicator = Indicator()
        indicator.showIndicator()
            do { try Auth.auth().signOut()}
            catch { }
        indicator.hideIndicator(completion: nil)
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "firstVC")
        
        if #available(iOS 15, *) {
            UIApplication
                .shared
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first {
                    $0.rootViewController = vc
                    $0.makeKeyAndVisible()
                    return true
                }
        }
        else {
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
    func promptForAnswer(fieldUpdating:String, field:String) {
        let ac = UIAlertController(title: "Enter New \(fieldUpdating)", message: nil, preferredStyle: .alert)

        ac.addTextField(configurationHandler: { textField in
            textField.placeholder = "\(fieldUpdating)"
            
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields?[0]
            
            let trimmedAnswer = answer?.text?.trimmingCharacters(in: .whitespacesAndNewlines)

            if let trimmedAnswer, !trimmedAnswer.isEmpty {
                    let db = Firestore.firestore()
                    let UserRef =  db.collection("users").document(UserService.user.id)
                    let indicator = Indicator()
                    
                    indicator.showIndicator()
                    UserRef.updateData([field: trimmedAnswer]) { (error) in
                        if error != nil {
                            //show error message

                            indicator.hideIndicator {
                                self.displayAlertviewController(title: "Error", msg: "couldn't update your information")
                            }
                        }
                        else {
                            indicator.hideIndicator {
                                self.displayAlertviewController(title: "Success!", msg: "Successfully updated your information")
                            }
                        }
                    }
            }
        }

        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    
    func promptForAnswerWithPassword(fieldUpdating:String, field:String, type:String, title:String) {
        let ac = UIAlertController(title: "Enter New \(fieldUpdating)", message: nil, preferredStyle: .alert)

        ac.addTextField(configurationHandler: { textField in

            if type.elementsEqual("password") {
                textField.placeholder = "Enter Password"
                textField.textContentType = .password
                textField.isSecureTextEntry = true

            }
            else if type.elementsEqual("email"){
                textField.placeholder = "Enter New Email"
            }
            else {
                textField.placeholder = "Enter Email"
            }
            
        })
                        
        if !type.elementsEqual("password") {
            
            ac.addTextField(configurationHandler: { textField in
                    textField.placeholder = "Enter Password"
                    textField.textContentType = .password
                    textField.isSecureTextEntry = true
            })
        }


        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            
            var trimmedAnswer:String?
            var trimmedAnswerPassword:String?

            if ac.textFields?.count ?? 0 > 1 {
                let answer = ac.textFields?[0]
                let answer1 = ac.textFields?[1]
                trimmedAnswer = answer?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                trimmedAnswerPassword = answer1?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            else {
                let answer = ac.textFields?[0]
                trimmedAnswerPassword = answer?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }


            
            guard let userAuth = Auth.auth().currentUser else {
                self.displayAlertviewController(title: "Error", msg: "Unable to update your email. Check your internet connection and try again.")

                return
            }
            let credential = EmailAuthProvider.credential(withEmail: userAuth.email ?? "", password: trimmedAnswerPassword ?? "")
            
            if trimmedAnswer != nil && trimmedAnswer != ""{
                
                let indicator = Indicator()
                indicator.showIndicator()
                userAuth.reauthenticate(with: credential) { result, err in
                    if let err = err {
                        indicator.hideIndicator {
                            self.displayAlertviewController(title: "Error", msg: "Unable to update your email. Make sure your password was input correctly.")
                        }
                    }
                    else {
                        if type.elementsEqual("email") {
                            
                            Auth.auth().currentUser?.updateEmail(to: trimmedAnswer!) { (error) in
                                if let error = error {

                                    indicator.hideIndicator {
                                        self.displayAlertviewController(title: "Error", msg: error.localizedDescription)
                                    }
                                }
                                else {
                                    let db = Firestore.firestore()
                                    
                                    let UserRef =  db.collection("users").document(UserService.user.id)
                                    UserRef.updateData([field:trimmedAnswer!,"isVerifiable":false]) { (error) in
                                        if error != nil {
                                            //show error message
                                            indicator.hideIndicator {
                                                self.displayAlertviewController(title: "Error", msg: error!.localizedDescription)
                                            }
                                        }
                                        else {
                                            indicator.hideIndicator {
                                            //settings = ["User Settings":["Change First Name: \(UserService.user.firstName)","Change Last Name: \(UserService.user.lastName)","Update Email Address: \(UserService.user.email)","Verify Email Address","Change Password", "Delete Account", "Number of Tokens: \(UserService.user.tokensRemaining)"]]
                                                self.displayAlertviewController(title: "Success!", msg: "Successfully updated your information.")

                                                //print(settings)
        
                                                //self.tableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        else if type.elementsEqual("verify") {
                            
                            indicator.hideIndicator {
                                self.displayAlertviewController(title: "Success", msg: "Please check your email for the link to update your password.  It will be from a firebase.com link.")
                            }
                            
                            if !userAuth.isEmailVerified {
                                
                                userAuth.sendEmailVerification { err in
                                    if let err = err {
                                        indicator.hideIndicator {
                                            self.displayAlertviewController(title: "Err", msg: "Could not send your verification email as this time. Please check your internet connection and try again.")
                                        }
                                    }
                                    else {
                                        indicator.hideIndicator {
                                            self.displayAlertviewController(title: "Link Sent!", msg: "Your verification email was been successfully sent!")
                                        }
                                    }
                                }
                            }
                            else {
                                let cancel = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
                                    
                                }
                                let ac1 = UIAlertController(title: "Verified", message: "Your Email is already verified ", preferredStyle: .alert)
                                ac1.addAction(cancel)
                                self.present(ac1, animated: true)
                            }
                        }
                        else if type.elementsEqual("password"){
                            Auth.auth().sendPasswordReset(withEmail: UserService.user.email) { error in
                                if let error = error {
                                    indicator.hideIndicator {
                                        self.displayAlertviewController(title: "Error", msg: error.localizedDescription)
                                    }
                                }
                                else {

                                    indicator.hideIndicator {
                                        self.displayAlertviewController(title: "Success", msg: "Please check your email for the link to update your password.  It will be from a firebase.com link.")
                                    }
                                }
                            }
                        }
                        
                        else {
                            self.deleteAccount()
                        }
                        
                        
                    }
                }
            }
        }

        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    
    

    
    
    func displayAlertviewController(title:String,msg:String){
        let alert = UIAlertController(title:title, message: msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { UIAlertAction in
        }))
        self.present(alert, animated: true, completion: nil)
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

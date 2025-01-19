//
//  ProfileViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/28/23.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, reloadUserDelegate {
    
    func reload() {
        
        settings = ["User Settings":["Change First Name: \(UserService.user.firstName)","Change Last Name: \(UserService.user.lastName)","Update Email Address: \(UserService.user.email)","Verify Email Address","Change Password", "Delete Account", "Number of Tokens: \(UserService.user.tokensRemaining)","Support: anthony@aicademy.us"]]
        
        tableView.reloadData()
    }
    

    var settings = ["User Settings":["Change First Name: \(UserService.user.firstName)","Change Last Name: \(UserService.user.lastName)","Update Email Address: \(UserService.user.email)","Verify Email Address","Change Password", "Delete Account", "Number of Tokens: \(UserService.user.tokensRemaining)","Support: anthony@aicademy.us"]]
    let settingsKeys = ["User Settings"]

    
    var userServ:_UserService?

    @IBOutlet weak var email: UITextView!
    @IBOutlet weak var phone: UITextView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        userServ = UserService
        userServ?.delegate = self
        
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(self.logOutUser))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.row == 6 {
            let setting = "Number of Tokens: \(UserService.user.tokensRemaining)"
            var config = UIListContentConfiguration.cell()
            config.text = setting
            //config.secondaryText = ""
            cell.contentConfiguration = config
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .none
            return cell
        }
       else if indexPath.row == 3 {
           print(indexPath.row)
           if Auth.auth().currentUser?.isEmailVerified ?? false {
               print("do i enter here?")
               let setting = "Email is already Verified"
               print(setting)
               var config = UIListContentConfiguration.cell()
               config.text = setting
               cell.isUserInteractionEnabled = false
               cell.accessoryType = .checkmark

               //config.secondaryText = ""
               cell.contentConfiguration = config
               return cell
           }
           else {
               print("or here")

               let setting = "Please Verify Email Address"
               var config = UIListContentConfiguration.cell()
               config.text = setting
               //config.secondaryText = ""
               cell.contentConfiguration = config
               return cell
           }
        }
        
        else{
            guard let setting = settings[settingsKeys[indexPath.section]]?[indexPath.row] else{
                print("or here")

                return cell
            }
            cell.isUserInteractionEnabled = true
            cell.accessoryType = .none
            var config = UIListContentConfiguration.cell()
            config.text = setting
            //config.secondaryText = ""
            cell.contentConfiguration = config

        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(section)
        print(settingsKeys)
        print(settings)
        return settings[settingsKeys[section]]?.count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        print("settings sections")
        print(settings.keys.count)
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
        header.textLabel?.textAlignment = .center
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

                
                promptForAnswerWithPassword(fieldUpdating: "Verify", field: "email", type: "verify", title: "Verify Email")

            
            case 4:
                promptForAnswerWithPassword(fieldUpdating: "Password", field: "password", type: "password", title: "Reset Password")

            case 5:
                
                promptForAnswerWithPassword(fieldUpdating: "Password", field: "password", type: "delete", title: "Enter Email and Password to Delete your Account")
                
            default:
                print("error")
            }
        }
        else {
            
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
            catch { print("already logged out") }
        indicator.hideIndicator(completion: nil)
        let story = UIStoryboard(name: "Main", bundle:nil)
        let vc = story.instantiateViewController(withIdentifier: "firstVC")
        
        if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 15, minorVersion: 0, patchVersion: 0)) {
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
            let answer = ac.textFields![0]
            
            let trimmedAnswer = answer.text?.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmedAnswer != nil || trimmedAnswer != ""{
                    let db = Firestore.firestore()
                    let UserRef =  db.collection("users").document(UserService.user.id)
                    let indicator = Indicator()
                    
                    indicator.showIndicator()
                    UserRef.updateData([field:trimmedAnswer!]) { (error) in
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
                let answer = ac.textFields![0]
                let answer1 = ac.textFields![1]
                trimmedAnswer = answer.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                trimmedAnswerPassword = answer1.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            else {
                let answer = ac.textFields![0]
                trimmedAnswerPassword = answer.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }


            
            guard let userAuth = Auth.auth().currentUser else {
                self.displayAlertviewController(title: "Error", msg: "Unable to update your email. Check your internet connection and try again.")

                return
            }
            let credential = EmailAuthProvider.credential(withEmail: userAuth.email ?? "", password: trimmedAnswerPassword ?? "")
            
            if trimmedAnswer != nil || trimmedAnswer != ""{
                
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
                                    print("this is the trimmed email")
                                    print(error.localizedDescription)

                                    print(trimmedAnswer)
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

//
//  SubjectTableViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/14/23.
//

import UIKit
import Firebase

class SubjectTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var subjects = ["Math", "Science", "Social Sciences", "English","History"]
    
    var colors = ["Math":UIColor.init(red: 0, green: 71/255, blue: 171/255, alpha: 1),
                  "Science":UIColor.init(red: 0, green: 204/255, blue: 102/255, alpha: 1),
                  "Social Sciences":UIColor.init(red: 178/255, green: 102/255, blue: 255/255, alpha: 1),
                  "English":UIColor.init(red: 253/255, green: 229/255, blue: 65/255, alpha: 1),
                  "History":UIColor.init(red: 1, green: 128/255, blue: 0, alpha: 1)]
    
    //                  "Foreign Languages":UIColor.init(red: 1, green: 102/255, blue: 102/255, alpha: 1),

    var selectedSubject:String?
    var selectedColor:UIColor?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let userAuth = Auth.auth().currentUser else {
            return
        }
        
        print(userAuth.isEmailVerified)
        print(userAuth.email)

                
        if !userAuth.isEmailVerified && !UserService.user.receivedTokens {
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
                
            }
            let sendLink = UIAlertAction(title: "Send Link", style: .default){ (action) in
                userAuth.sendEmailVerification { err in
                    if let err = err {
                        self.showAlert(title: "Error", msg: "Was not able to send the email verification at this time. Please check your internet connection and Try again.")
                    }
                    else {
                        self.showAlert(title: "Success", msg: "The verfication email was sent.  Please check your inbox for the email")
                    }
                }
            }
            
            let ac1 = UIAlertController(title: "Unverified Email", message: "Your email is not currenlty verified. Please verify your email to 50,000 tokens.", preferredStyle: .alert)
            ac1.addAction(cancel)
            ac1.addAction(sendLink)

            self.present(ac1, animated: true)
        }
        else {
            if (!UserService.user.isVerifiable && !UserService.user.receivedTokens){
                let db = Firestore.firestore()
                let ref = db.collection("users").document(UserService.user.id)
                ref.updateData(["isVerifiable":true, "tokensRemaining":UserService.user.tokensRemaining+50000,"receivedTokens":true]) { err in
                    if let err = err {
                        self.showAlert(title: "Error", msg: "Was not able to update the tokens and your status.  Please send us an email at awfasano@gmail.com. And we will get this issue fixed.")

                    }
                    else {
                        self.showAlert(title: "Success", msg: "Your tokens for verifying your email have been provided to you.")

                    }
                }
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell

        //cell.frame = CGRectMake(0, 0, tableView.frame.size.width-10, cell.frame.size.height)
        
        let view = UIView()
        view.layer.cornerRadius = 0
        
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height)
        cell.subject.frame = cell.frame
        
        cell.subject.text = subjects[indexPath.section]
        //cell.subjectImage.image = subjects[keys[indexPath.row]]
        
        
        let color = colors[subjects[indexPath.section]]

        switch subjects[indexPath.section] {
            
            
        case "Math":
            
            
            cell.subject.textColor = color
            view.backgroundColor = color?.adjustBrightness(by: 65)
            cell.selectedBackgroundView = view
            



        case "Science":
                        
            cell.subject.textColor  = color
            view.backgroundColor = color?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view


            

        case "Foreign Languages":
                        
            cell.subject.textColor  = color
            view.backgroundColor  = color?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view


            

        case "Social Sciences":
                        
            cell.subject.textColor = color
            view.backgroundColor = color?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view
            cell.layer.borderColor = color?.cgColor

            
        case "English":
            
            cell.subject.textColor = color
            view.backgroundColor = color?.adjustBrightness(by: 100).withAlphaComponent(0.5)
            cell.selectedBackgroundView = view
            cell.layer.borderColor = color?.cgColor


        case "History":

            cell.subject.textColor = color
            view.backgroundColor = color?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view
            cell.layer.borderColor = color?.cgColor
            
        default:
            print("error")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return subjects.count
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:CustomTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        performSegue(withIdentifier: "toFields", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell:CustomTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        

        
        selectedSubject = subjects[indexPath.section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toFields"){
            let viewcontroller = segue.destination as! FieldViewController
            viewcontroller.subject = selectedSubject
            viewcontroller.uiColor = colors[selectedSubject ?? ""]

        }
    }
    
    
    func showAlert(title:String,msg:String) {
        let cancel1 = UIAlertAction(title: "OK", style: .cancel){ (action) in
            
        }
        let ac1 = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac1.addAction(cancel1)
        self.present(ac1, animated: true)
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




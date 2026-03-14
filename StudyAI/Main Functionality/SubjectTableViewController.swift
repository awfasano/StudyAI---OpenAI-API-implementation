//
//  SubjectTableViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/14/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SubjectTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let subjectHeaderTag = 8_401
    
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
        AIcademyTheme.applyBackground(to: view)
        view.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        installHeaderIfNeeded()
        
        guard let userAuth = Auth.auth().currentUser else {
            return
        }
        

                
        if !userAuth.isEmailVerified {
            
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
            
            let ac1 = UIAlertController(title: "Verify Your Email", message: "Verify your email so account recovery and premium access stay reliable across devices.", preferredStyle: .alert)
            ac1.addAction(cancel)
            ac1.addAction(sendLink)

            self.present(ac1, animated: true)
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomTableViewCell else { return UITableViewCell() }
        let color = colors[subjects[indexPath.section]]

        //cell.frame = CGRectMake(0, 0, tableView.frame.size.width-10, cell.frame.size.height)
        
        let view = UIView()
        view.layer.cornerRadius = 0
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = AIcademyTheme.surface
        cell.contentView.layer.cornerRadius = 26
        cell.contentView.layer.borderWidth = 2
        cell.contentView.layer.borderColor = (color ?? AIcademyTheme.border).cgColor
        cell.contentView.layer.shadowColor = AIcademyTheme.ink.cgColor
        cell.contentView.layer.shadowOpacity = 0.08
        cell.contentView.layer.shadowRadius = 12
        cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 8)

        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, cell.frame.size.height)
        cell.subject.frame = cell.frame

        cell.subject.text = subjects[indexPath.section]
        cell.subject.font = .systemFont(ofSize: 26, weight: .heavy)
        //cell.subjectImage.image = subjects[keys[indexPath.row]]

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
            break
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
        performSegue(withIdentifier: "toFields", sender: self)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        selectedSubject = subjects[indexPath.section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        92
    }

    private func installHeaderIfNeeded() {
        guard tableView.tableHeaderView?.tag != subjectHeaderTag else { return }

        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 212))
        header.tag = subjectHeaderTag
        header.backgroundColor = .clear

        let card = UIView(frame: CGRect(x: 20, y: 12, width: header.bounds.width - 40, height: 184))
        AIcademyTheme.styleSurface(card, tint: AIcademyTheme.cyan)
        card.autoresizingMask = [.flexibleWidth]

        let imageView = UIImageView(frame: CGRect(x: 18, y: 22, width: 96, height: 96))
        Utilities.applyHeroImage(imageView)
        card.addSubview(imageView)

        let title = UILabel(frame: CGRect(x: 128, y: 26, width: card.bounds.width - 146, height: 34))
        title.autoresizingMask = [.flexibleWidth]
        title.numberOfLines = 0
        title.text = "Pick your study lane"
        AIcademyTheme.styleTitle(title, size: 28)
        card.addSubview(title)

        let subtitle = UILabel(frame: CGRect(x: 128, y: 66, width: card.bounds.width - 146, height: 56))
        subtitle.autoresizingMask = [.flexibleWidth]
        subtitle.numberOfLines = 0
        subtitle.text = "Carlisle will shape the generator around the subject you choose first."
        AIcademyTheme.styleSubtitle(subtitle, size: 14)
        card.addSubview(subtitle)

        let footer = UILabel(frame: CGRect(x: 18, y: 136, width: card.bounds.width - 36, height: 28))
        footer.autoresizingMask = [.flexibleWidth]
        footer.text = " Tap a card to keep building "
        footer.font = .systemFont(ofSize: 13, weight: .bold)
        footer.textColor = AIcademyTheme.ink
        footer.textAlignment = .center
        footer.backgroundColor = AIcademyTheme.orange.withAlphaComponent(0.22)
        footer.layer.cornerRadius = 14
        footer.clipsToBounds = true
        card.addSubview(footer)

        header.addSubview(card)
        tableView.tableHeaderView = header
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toFields"){
            guard let viewcontroller = segue.destination as? FieldViewController else { return }
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

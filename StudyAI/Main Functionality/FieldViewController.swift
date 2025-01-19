//
//  FieldViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/15/23.
//

import UIKit

class FieldViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var subject:String?
    var selectedField:String?
    var uiColor:UIColor?
    var fields = ["Math":["Algebra", "Geometry", "Trigonometry","Calculus","Statistics and Probability"],
                  "Science":["Biology", "Chemistry", "Physics", "Earth Science", "Environmental Science"],
                  "Social Sciences":["Macroeconomics", "Microeconomics", "Pyschology", "Government", "Geography"],
                  "History":["US History", "European History","World History", "Art History"],
                  "English":["Poetry", "Essays", "Grammar"]
    ]
    //Foriegn Languages":["Spanish","French","Japanese","Chinese","German","Korean"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if subject == nil || uiColor == nil {
            let alertController = UIAlertController(title: "Error", message: "Getting your information", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let subjectCell = subject else {
                return CustomTableViewCell()
            }
        let cell:CustomTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        
        let view = UIView()
        view.layer.cornerRadius = 0

        cell.subject.text = fields[subjectCell]?[indexPath.section]
        cell.layer.cornerRadius = 0
        view.backgroundColor = uiColor?.adjustBrightness(by: 25)
        cell.subject.textColor = uiColor
        cell.selectedBackgroundView = view
        
        switch subjectCell {
        case "Math":
            view.backgroundColor = uiColor?.adjustBrightness(by: 65)
            cell.selectedBackgroundView = view
      
        case "Science":
            view.backgroundColor = uiColor?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view
            
        case "Foreign Languages":
            view.backgroundColor  = uiColor?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view

        case "Social Sciences":
            view.backgroundColor = uiColor?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view
            
        case "English":
            view.backgroundColor = uiColor?.adjustBrightness(by: 100).withAlphaComponent(0.5)
            cell.selectedBackgroundView = view
            
        case "History":
            view.backgroundColor = uiColor?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view

        default:
            print("error")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let subjectCell = subject else {
                return 0
            }
        guard fields[subjectCell] != nil else {
            return 0
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fields[subject!]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell:CustomTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        selectedField = fields[subject!]?[indexPath.section]
    
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if subject == "English" && selectedField == "Grammar"{
            performSegue(withIdentifier: "toFixGrammar", sender: self)
        }
        else {
            performSegue(withIdentifier: "toMain", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if(segue.identifier == "toMain"){
            let viewcontroller = segue.destination as! MainViewController
            viewcontroller.subject = subject
            viewcontroller.field = selectedField
            viewcontroller.uiColor = uiColor

        }
        else if(segue.identifier == "tofixGrammar") {
            let viewcontroller = segue.destination as! FixGrammarViewController
        }
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

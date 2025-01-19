//
//  PastCallsViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/28/23.
//

import UIKit
import Firebase
class PastCallsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,reloadDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var fields = ["Math":["Algebra", "Geometry", "Trigonometry","Calculus","Statistics and Probability"],
                  "Science":["Biology", "Chemistry", "Physics", "Earth Science", "Environmental Science"],
                  "Social Sciences":["Macroeconomics", "Microeconomics", "Pyschology", "Government", "Geography"],
                  "History":["US History", "European History","World History", "Art History"],
                  "English":["Poetry", "Essays", "Grammar"],
                  "Foriegn Languages":["Spanish","French","Japanese","Chinese","German","Korean"]
    ]
    var selectedSubject:String?
    var selectedField:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let keys = Array(fields.keys)
        guard let fields = fields[keys[indexPath.section]]?[indexPath.row] else{
            return cell
        }
        
        var config = UIListContentConfiguration.cell()
        
        print("in cell for row at")
        print(fields)
        
        config.text = fields
        //config.secondaryText = ""
        cell.contentConfiguration = config
            return cell
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fieldsKeys = Array(fields.keys)
        return fields[fieldsKeys[section]]?.count ?? 0
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let fieldsKeys = Array(fields.keys)
        return fieldsKeys[section]
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
            return fields.keys.count
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let keys = Array(fields.keys)
        selectedField = fields[keys[indexPath.section]]?[indexPath.row]
        selectedSubject = keys[indexPath.section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toPastQuestionsView", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        header.textLabel?.frame = header.bounds
        header.textLabel?.textAlignment = .center
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toPastQuestionsView"){
            let viewcontroller = segue.destination as! PastDocumentListViewController
            viewcontroller.subject = selectedSubject
            viewcontroller.field = selectedField
        }
    }
    
    func showAlert(title:String,msg:String) {
        let cancel1 = UIAlertAction(title: "OK", style: .cancel){ (action) in
            
        }
        let ac1 = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac1.addAction(cancel1)
        self.present(ac1, animated: true)
    }
    
    func reload(success: Bool) {
        if success {

        }
        else {
            
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

//
//  PastDocumentListViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/4/23.
//

import UIKit
import Firebase

class PastDocumentListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,reloadDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var subject:String?
    var field:String?
    var docTypesArray:[docInfo] = []
    var selectedDocInformation:docInfo?
    var delegate:reloadDelegate?
    
    var sorting = "date"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if subject == nil || field == nil{
            let alertController = UIAlertController(title: "Error", message: "Getting your information", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            
            print(subject)
            print(field)
            
            docTypesArray = DocumentService.fields[subject ?? ""]?[field ?? ""] ?? []
            
            print(docTypesArray.count)
            print(docTypesArray)
            
            if docTypesArray.count == 0 && DocumentService.updated {
                let alertController = UIAlertController(title: "No Questions for this subject!", message: "Asks some questions on this field to access the this view.", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
            
            let questionTypeHandler: UIActionHandler = { [self] action in
                print(action.title)
                sorting = "questionType"
                sortingMech(criteria: sorting)
                
            }
            let questionTopicHandler: UIActionHandler = { [self] action in
                print(action.title)
                sorting = "questionTopic"
                sortingMech(criteria: sorting)
            }
            let dateHandler: UIActionHandler = { [self] action in
                print(action.title)
                sorting = "date"
                sortingMech(criteria: sorting)
            }
            
            let barButtonMenu = UIMenu(title: "", children: [
                UIAction(title: NSLocalizedString("Question Type", comment: ""), image: UIImage(systemName: "questionmark.circle"), handler: questionTypeHandler),
                UIAction(title: NSLocalizedString("Question Topic", comment: ""), image: UIImage(systemName: "questionmark.app"), handler: questionTopicHandler),
                UIAction(title: NSLocalizedString("Date", comment: ""), image: UIImage(systemName: "calendar"), handler: dateHandler),
            ])
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItem?.menu = barButtonMenu
            
            // or using the initializer
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", image: nil, primaryAction: nil, menu: barButtonMenu)
            
            tableView.dataSource = self
            tableView.delegate = self
            DocumentService.delegate = self
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        if DocumentService.listener == nil {
            DocumentService.getData()
            DocumentService.movedTobackground()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PastQuestionsTableViewCell
        let question = docTypesArray[indexPath.row]
        
        cell?.dateLabel.text = question.dateString
        cell?.questionTopic.text = question.questionTopic
        cell?.typeOfQuestion.text = question.questionType
        
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docTypesArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDocument", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDocument"){
            let viewcontroller = segue.destination as! DocumentViewController
            viewcontroller.docInformation = selectedDocInformation
        }
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        selectedDocInformation = docTypesArray[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let db = Firestore.firestore()
        if editingStyle == .delete {
            let ref = db.collection("users").document(UserService.user.id).collection("Past Questions").document(docTypesArray[indexPath.row].subject)
            let indicator = Indicator()
            indicator.showIndicator()
            ref.updateData([docTypesArray[indexPath.row].id:FieldValue.delete()]) { error in
                if let error = error {
                    self.delegate?.reload(success: false)
                    indicator.hideIndicator(completion: nil)
                }
                else {
                    //self.docTypesArray.remove(at: indexPath.row)
                    indicator.hideIndicator(completion: nil)
                }
            }
        }
    }
    
    func reload(success: Bool) {
        if success{
            
            sortingMech(criteria: sorting)
            print(docTypesArray.count)
            print(docTypesArray)
            
            if docTypesArray.count == 0 {
                let alertController = UIAlertController(title: "No Questions for this subject!", message: "Asks some questions on this field to access the this view.", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                    self.navigationController?.popViewController(animated: true)
                }
                
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        else {
            let alertController = UIAlertController(title: "Error", message: "Unable to retrieve your information from database. Please check your internet connection", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func sortingMech(criteria: String) {
        switch criteria {
        case "date":
            docTypesArray = DocumentService.fields[subject ?? ""]?[field ?? ""]?.sorted(by: {
                return $0.date.compare($1.date) == .orderedDescending
            }) ?? []
        case "questionTopic":
            docTypesArray = DocumentService.fields[subject ?? ""]?[field ?? ""]?.sorted(by: {
                return $0.questionTopic < $1.questionTopic}) ?? []
        case "questionType":
            docTypesArray = DocumentService.fields[subject ?? ""]?[field ?? ""]?.sorted(by: {
                return $0.questionType < $1.questionType}) ?? []
        default:
            print("Have you done something new?")
        }
        DocumentService.fields[subject ?? ""]?[field ?? ""] = docTypesArray
        tableView.reloadData()
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

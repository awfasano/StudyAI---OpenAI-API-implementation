//
//  PastDocumentListViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/4/23.
//

import UIKit
import FirebaseFirestore

class PastDocumentListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,reloadDelegate {
    private let historyHeaderTag = 8_112
    
    @IBOutlet weak var tableView: UITableView!
    var subject:String?
    var field:String?
    var docTypesArray:[docInfo] = []
    var selectedDocInformation:docInfo?
    var delegate:reloadDelegate?
    
    var sorting = "date"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        view.backgroundColor = .clear
        
        if subject == nil || field == nil{
            let alertController = UIAlertController(title: "Error", message: "Getting your information", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            
            
            docTypesArray = DocumentService.fields[subject ?? ""]?[field ?? ""] ?? []
            
            
            if docTypesArray.count == 0 && DocumentService.updated {
                let alertController = UIAlertController(title: "No Questions for this subject!", message: "Asks some questions on this field to access the this view.", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
            
            let questionTypeHandler: UIActionHandler = { [self] action in
                sorting = "questionType"
                sortingMech(criteria: sorting)
                
            }
            let questionTopicHandler: UIActionHandler = { [self] action in
                sorting = "questionTopic"
                sortingMech(criteria: sorting)
            }
            let dateHandler: UIActionHandler = { [self] action in
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
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
            DocumentService.delegate = self
            installHeaderIfNeeded()
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
        cell?.backgroundColor = .clear
        cell?.contentView.backgroundColor = AIcademyTheme.surface
        cell?.contentView.layer.cornerRadius = 22
        cell?.contentView.layer.borderWidth = 2
        cell?.contentView.layer.borderColor = AIcademyTheme.border.cgColor
        cell?.questionTopic.textColor = AIcademyTheme.ink
        cell?.questionTopic.font = .systemFont(ofSize: 18, weight: .heavy)
        cell?.typeOfQuestion.textColor = AIcademyTheme.magenta
        cell?.typeOfQuestion.font = .systemFont(ofSize: 13, weight: .bold)
        cell?.dateLabel.textColor = AIcademyTheme.ink.withAlphaComponent(0.6)
        
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docTypesArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDocument", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDocument"){
            guard let viewcontroller = segue.destination as? DocumentViewController else { return }
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
            break
        }
        DocumentService.fields[subject ?? ""]?[field ?? ""] = docTypesArray
        tableView.reloadData()
    }

    private func installHeaderIfNeeded() {
        guard tableView.tableHeaderView?.tag != historyHeaderTag else { return }

        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 182))
        header.tag = historyHeaderTag
        header.backgroundColor = .clear

        let card = UIView(frame: CGRect(x: 20, y: 12, width: header.bounds.width - 40, height: 154))
        AIcademyTheme.styleSurface(card, tint: AIcademyTheme.magenta)
        card.autoresizingMask = [.flexibleWidth]

        let title = UILabel(frame: CGRect(x: 18, y: 22, width: card.bounds.width - 36, height: 32))
        title.autoresizingMask = [.flexibleWidth]
        title.text = "\(field ?? "Study") history"
        AIcademyTheme.styleTitle(title, size: 28)
        card.addSubview(title)

        let subtitle = UILabel(frame: CGRect(x: 18, y: 60, width: card.bounds.width - 36, height: 52))
        subtitle.autoresizingMask = [.flexibleWidth]
        subtitle.numberOfLines = 0
        subtitle.text = "Saved questions, guides, quizzes, and explanations live here so users can keep studying later."
        AIcademyTheme.styleSubtitle(subtitle, size: 14)
        card.addSubview(subtitle)

        header.addSubview(card)
        tableView.tableHeaderView = header
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
